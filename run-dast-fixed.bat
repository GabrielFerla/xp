@echo off
echo ========================================
echo Executando DAST - Versão Corrigida
echo ========================================

echo.
echo [1/7] Verificando dependências...

REM Verificar se Docker está instalado
docker --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERRO: Docker não está instalado ou não está no PATH
    echo Instale o Docker Desktop e tente novamente
    pause
    exit /b 1
)

REM Verificar se Java está instalado
java -version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERRO: Java não está instalado ou não está no PATH
    echo Instale o Java 8+ e tente novamente
    pause
    exit /b 1
)

echo ✅ Docker e Java encontrados

echo.
echo [2/7] Verificando se aplicação já está rodando...
curl -f http://localhost:8082/actuator/health >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo ✅ Aplicação já está rodando na porta 8082
    goto :app_ready
)

echo.
echo [3/7] Iniciando aplicação Spring Boot...
echo Iniciando aplicação em background...
start /B mvn spring-boot:run -Dspring-boot.run.profiles=test

echo Aguardando aplicação inicializar (pode levar até 2 minutos)...
timeout /t 120 /nobreak >nul

echo.
echo [4/7] Verificando se aplicação está rodando...
for /L %%i in (1,1,15) do (
    echo Testando conectividade... tentativa %%i/15
    curl -f http://localhost:8082/actuator/health >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo ✅ Aplicação está rodando e pronta para testes
        goto :app_ready
    )
    echo Aguardando aplicação... (15 segundos)
    timeout /t 15 /nobreak >nul
)

echo ❌ ERRO: Aplicação não está respondendo após 5 minutos
echo.
echo Verificando se há algum processo Java rodando...
tasklist /FI "IMAGENAME eq java.exe" 2>NUL | find /I /N "java.exe" >NUL
if %ERRORLEVEL% equ 0 (
    echo ✅ Processo Java encontrado - aplicação pode estar iniciando
    echo Aguardando mais 2 minutos...
    timeout /t 120 /nobreak >nul
    
    curl -f http://localhost:8082/actuator/health >nul 2>&1
    if %ERRORLEVEL% equ 0 (
        echo ✅ Aplicação finalmente está rodando!
        goto :app_ready
    )
)

echo ❌ Aplicação não conseguiu iniciar
echo.
echo Possíveis soluções:
echo 1. Verifique se a porta 8082 está livre: netstat -an ^| findstr 8082
echo 2. Verifique os logs da aplicação
echo 3. Tente executar manualmente: mvn spring-boot:run -Dspring-boot.run.profiles=test
echo.
pause
exit /b 1

:app_ready
echo.
echo [5/7] Executando Dastardly (Burp Suite)...
echo Baixando e executando Dastardly para varredura rápida...
docker run --rm -v "%cd%":/dastardly/reports ^
  public.ecr.aws/portswigger/dastardly:latest ^
  --url http://host.docker.internal:8082 ^
  --report-file /dastardly/reports/dastardly-report.json ^
  --report-format json

if %ERRORLEVEL% neq 0 (
    echo ⚠️ AVISO: Dastardly encontrou problemas, mas continuando...
)

echo.
echo [6/7] Executando OWASP ZAP Baseline Scan...
echo Executando ZAP para análise mais detalhada...
docker run -t --rm -v "%cd%":/zap/wrk/:rw zaproxy/zap-stable zap-baseline.py ^
  -t http://host.docker.internal:8082 ^
  -J zap-baseline-report.json ^
  -x zap-baseline-report.xml ^
  -r zap-baseline-report.html ^
  -I ^
  -j ^
  -z "config api.disablekey=true; config scanner.attackOnStart=true; config view.mode=attack; config connection.dnsTtlSuccessfulQueries=-1"

if %ERRORLEVEL% neq 0 (
    echo ⚠️ AVISO: OWASP ZAP encontrou problemas, mas continuando...
)

echo.
echo [7/7] Executando testes de segurança customizados...
if exist "scripts\security-tests.py" (
    echo Executando script Python de testes customizados...
    python scripts/security-tests.py http://localhost:8082
    if %ERRORLEVEL% neq 0 (
        echo ⚠️ AVISO: Testes customizados encontraram vulnerabilidades
    )
) else (
    echo ℹ️ Script de testes customizados não encontrado, pulando...
)

echo.
echo ========================================
echo Gerando relatório consolidado DAST...
echo ========================================

echo # Relatório de Testes Dinâmicos de Segurança (DAST) > dast-fixed-report.md
echo Data: %date% %time% >> dast-fixed-report.md
echo. >> dast-fixed-report.md
echo ## Resumo dos Testes DAST >> dast-fixed-report.md
echo. >> dast-fixed-report.md

if exist "dastardly-report.json" (
    echo ✅ Dastardly (Burp Suite): SUCESSO >> dast-fixed-report.md
    echo - Relatório JSON: dastardly-report.json >> dast-fixed-report.md
    echo - **Vantagem**: Varredura rápida e eficiente do Burp Suite >> dast-fixed-report.md
) else (
    echo ❌ Dastardly (Burp Suite): FALHOU >> dast-fixed-report.md
)
echo. >> dast-fixed-report.md

if exist "zap-baseline-report.html" (
    echo ✅ OWASP ZAP Baseline Scan: SUCESSO >> dast-fixed-report.md
    echo - Relatório HTML: zap-baseline-report.html >> dast-fixed-report.md
    echo - Relatório JSON: zap-baseline-report.json >> dast-fixed-report.md
    echo - Relatório XML: zap-baseline-report.xml >> dast-fixed-report.md
) else (
    echo ❌ OWASP ZAP Baseline Scan: FALHOU >> dast-fixed-report.md
)
echo. >> dast-fixed-report.md

if exist "security-tests-report.json" (
    echo ✅ Testes de Segurança Customizados: SUCESSO >> dast-fixed-report.md
    echo - Relatório: security-tests-report.json >> dast-fixed-report.md
) else (
    echo ℹ️ Testes de Segurança Customizados: Não executado >> dast-fixed-report.md
)
echo. >> dast-fixed-report.md

echo ## Configuração da Aplicação >> dast-fixed-report.md
echo. >> dast-fixed-report.md
echo - **Porta**: 8082 (ambiente de teste) >> dast-fixed-report.md
echo - **Perfil**: test >> dast-fixed-report.md
echo - **Banco**: H2 em memória >> dast-fixed-report.md
echo - **SSL**: Desabilitado para testes >> dast-fixed-report.md
echo. >> dast-fixed-report.md

echo ## Vulnerabilidades Identificadas >> dast-fixed-report.md
echo. >> dast-fixed-report.md

if exist "dastardly-report.json" (
    echo ### Dastardly (Burp Suite) - Vulnerabilidades: >> dast-fixed-report.md
    echo - **Alta**: Verificar relatório JSON para detalhes >> dast-fixed-report.md
    echo - **Média**: Verificar relatório JSON para detalhes >> dast-fixed-report.md
    echo - **Baixa**: Verificar relatório JSON para detalhes >> dast-fixed-report.md
    echo - **Informativa**: Verificar relatório JSON para detalhes >> dast-fixed-report.md
)
echo. >> dast-fixed-report.md

echo ## Recomendações de Mitigação >> dast-fixed-report.md
echo. >> dast-fixed-report.md
echo 1. **Prioridade Alta**: Corrigir vulnerabilidades identificadas pelo Dastardly >> dast-fixed-report.md
echo 2. **Prioridade Média**: Revisar vulnerabilidades do ZAP >> dast-fixed-report.md
echo 3. **Configuração**: Implementar headers de segurança >> dast-fixed-report.md
echo 4. **Monitoramento**: Configurar alertas de segurança >> dast-fixed-report.md
echo 5. **Testes Regulares**: Executar este script em cada deploy >> dast-fixed-report.md

echo.
echo ========================================
echo Análise DAST Concluída!
echo ========================================
echo.
echo Relatórios gerados:
if exist "dastardly-report.json" (
    echo - dastardly-report.json (Dastardly - Burp Suite)
) else (
    echo - Dastardly: Não gerado
)
if exist "zap-baseline-report.html" (
    echo - zap-baseline-report.html (OWASP ZAP)
) else (
    echo - OWASP ZAP: Não gerado
)
if exist "security-tests-report.json" (
    echo - security-tests-report.json (Testes Customizados)
) else (
    echo - Testes Customizados: Não executado
)
echo - dast-fixed-report.md (Consolidado)
echo.

echo Parando aplicação Spring Boot...
taskkill /F /IM java.exe >nul 2>&1

echo.
echo Abrindo relatório consolidado...
start dast-fixed-report.md

echo.
echo ✅ Análise DAST concluída com sucesso!
echo 📄 Verifique os relatórios gerados para detalhes das vulnerabilidades
echo 🚀 Script corrigido para funcionar com a porta 8082
echo.
echo 💡 Dica: Se a aplicação não iniciar, execute manualmente:
echo    mvn spring-boot:run -Dspring-boot.run.profiles=test
pause
