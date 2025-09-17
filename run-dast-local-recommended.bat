@echo off
echo ========================================
echo Executando DAST Local (RECOMENDADO)
echo ========================================
echo.
echo Este script executa DAST localmente, garantindo conectividade
echo sem problemas de rede Docker.
echo.

echo [1/6] Verificando dependências...

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
echo [2/6] Iniciando aplicação localmente...
echo Iniciando aplicação Spring Boot em background...
start /B mvn spring-boot:run -Dspring-boot.run.profiles=test

echo Aguardando aplicação inicializar...
timeout /t 90 /nobreak >nul

echo.
echo [3/6] Verificando se aplicação está rodando...
for /L %%i in (1,1,5) do (
    curl -f http://localhost:8082/actuator/health >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo ✅ Aplicação está rodando e pronta para testes
        goto :app_ready
    )
    echo Aguardando aplicação... tentativa %%i/5
    timeout /t 10 /nobreak >nul
)

echo ❌ ERRO: Aplicação não está respondendo após 5 minutos
echo Verifique se a aplicação iniciou corretamente
pause
exit /b 1

:app_ready
echo.
echo [4/6] Executando Dastardly (Burp Suite) - PRINCIPAL...
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
echo [5/6] Executando OWASP ZAP Baseline Scan (complementar)...
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
echo [6/6] Executando testes de segurança customizados...
echo Executando script Python de testes customizados...
python scripts/security-tests.py http://localhost:8082

if %ERRORLEVEL% neq 0 (
    echo ⚠️ AVISO: Testes customizados encontraram vulnerabilidades
)

echo.
echo ========================================
echo Gerando relatório consolidado DAST...
echo ========================================

echo # Relatório de Testes Dinâmicos de Segurança (DAST) - Local > dast-local-report.md
echo Data: %date% %time% >> dast-local-report.md
echo. >> dast-local-report.md
echo ## Resumo dos Testes DAST (Execução Local) >> dast-local-report.md
echo. >> dast-local-report.md

if exist "dastardly-report.json" (
    echo ✅ Dastardly (Burp Suite): SUCESSO >> dast-local-report.md
    echo - Relatório JSON: dastardly-report.json >> dast-local-report.md
    echo - **Vantagem**: Varredura rápida e eficiente do Burp Suite >> dast-local-report.md
) else (
    echo ❌ Dastardly (Burp Suite): FALHOU >> dast-local-report.md
)
echo. >> dast-local-report.md

if exist "zap-baseline-report.html" (
    echo ✅ OWASP ZAP Baseline Scan: SUCESSO >> dast-local-report.md
    echo - Relatório HTML: zap-baseline-report.html >> dast-local-report.md
    echo - Relatório JSON: zap-baseline-report.json >> dast-local-report.md
    echo - Relatório XML: zap-baseline-report.xml >> dast-local-report.md
) else (
    echo ❌ OWASP ZAP Baseline Scan: FALHOU >> dast-local-report.md
)
echo. >> dast-local-report.md

if exist "security-tests-report.json" (
    echo ✅ Testes de Segurança Customizados: SUCESSO >> dast-local-report.md
    echo - Relatório: security-tests-report.json >> dast-local-report.md
) else (
    echo ❌ Testes de Segurança Customizados: FALHOU >> dast-local-report.md
)
echo. >> dast-local-report.md

echo ## Vantagens da Execução Local >> dast-local-report.md
echo. >> dast-local-report.md
echo 1. **Conectividade Garantida**: Sem problemas de rede Docker >> dast-local-report.md
echo 2. **Performance Superior**: Aplicação roda nativamente >> dast-local-report.md
echo 3. **Debugging Fácil**: Logs diretos da aplicação >> dast-local-report.md
echo 4. **Controle Total**: Início/parada manual da aplicação >> dast-local-report.md
echo 5. **Burp Suite**: Dastardly executa com máxima eficiência >> dast-local-report.md
echo. >> dast-local-report.md

echo ## Vulnerabilidades Identificadas >> dast-local-report.md
echo. >> dast-local-report.md

if exist "dastardly-report.json" (
    echo ### Dastardly (Burp Suite) - Vulnerabilidades: >> dast-local-report.md
    echo - **Alta**: Verificar relatório JSON para detalhes >> dast-local-report.md
    echo - **Média**: Verificar relatório JSON para detalhes >> dast-local-report.md
    echo - **Baixa**: Verificar relatório JSON para detalhes >> dast-local-report.md
    echo - **Informativa**: Verificar relatório JSON para detalhes >> dast-local-report.md
)
echo. >> dast-local-report.md

echo ## Recomendações de Mitigação >> dast-local-report.md
echo. >> dast-local-report.md
echo 1. **Prioridade Alta**: Corrigir vulnerabilidades identificadas pelo Dastardly >> dast-local-report.md
echo 2. **Prioridade Média**: Revisar vulnerabilidades do ZAP >> dast-local-report.md
echo 3. **Configuração**: Implementar headers de segurança >> dast-local-report.md
echo 4. **Monitoramento**: Configurar alertas de segurança >> dast-local-report.md
echo 5. **Testes Regulares**: Executar este script em cada deploy >> dast-local-report.md

echo.
echo ========================================
echo Análise DAST Local Concluída!
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
    echo - Testes Customizados: Não gerado
)
echo - dast-local-report.md (Consolidado)
echo.

echo Parando aplicação Spring Boot...
taskkill /F /IM java.exe >nul 2>&1

echo.
echo Abrindo relatório consolidado...
start dast-local-report.md

echo.
echo ✅ Análise DAST local concluída com sucesso!
echo 📄 Verifique os relatórios gerados para detalhes das vulnerabilidades
echo 🚀 Execução local garante conectividade e performance máximas
echo.
echo 💡 Dica: Use este script para testes regulares - é mais confiável que Docker
pause
