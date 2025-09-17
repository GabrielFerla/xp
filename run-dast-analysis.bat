@echo off
echo ========================================
echo Executando Análise DAST (Dynamic Application Security Testing)
echo ========================================
echo.
echo ℹ️  NOTA: Para uma análise mais eficiente, considere usar:
echo    - run-dast-burp.bat (com Burp Suite Dastardly)
echo    - run-burp-docker.bat (ambiente completo via Docker)
echo ========================================

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

REM Verificar se Python está instalado
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERRO: Python não está instalado ou não está no PATH
    echo Instale o Python 3.x e tente novamente
    pause
    exit /b 1
)

echo ✅ Docker e Python encontrados

echo.
echo [2/6] Iniciando aplicação para testes...
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
echo [4/6] Executando OWASP ZAP Baseline Scan...
echo Baixando e executando OWASP ZAP...
docker run -t --rm -v "%cd%":/zap/wrk/:rw owasp/zap2docker-stable zap-baseline.py ^
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
echo [5/6] Executando Nikto Web Vulnerability Scanner...
echo Executando Nikto...
docker run --rm -v "%cd%":/tmp/reports ^
  sullo/nikto -h http://host.docker.internal:8082 ^
  -output /tmp/reports/nikto-report.html ^
  -Format htm ^
  -Tuning 1,2,3,4,5,6,7,8,9,0,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z

if %ERRORLEVEL% neq 0 (
    echo ⚠️ AVISO: Nikto encontrou problemas, mas continuando...
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

echo # Relatório de Testes Dinâmicos de Segurança (DAST) > dast-report.md
echo Data: %date% %time% >> dast-report.md
echo. >> dast-report.md
echo ## Resumo dos Testes DAST >> dast-report.md
echo. >> dast-report.md

if exist "zap-baseline-report.html" (
    echo ✅ OWASP ZAP Baseline Scan: SUCESSO >> dast-report.md
    echo - Relatório HTML: zap-baseline-report.html >> dast-report.md
    echo - Relatório JSON: zap-baseline-report.json >> dast-report.md
    echo - Relatório XML: zap-baseline-report.xml >> dast-report.md
) else (
    echo ❌ OWASP ZAP Baseline Scan: FALHOU >> dast-report.md
)
echo. >> dast-report.md

if exist "nikto-report.html" (
    echo ✅ Nikto Web Vulnerability Scanner: SUCESSO >> dast-report.md
    echo - Relatório: nikto-report.html >> dast-report.md
) else (
    echo ❌ Nikto Web Vulnerability Scanner: FALHOU >> dast-report.md
)
echo. >> dast-report.md

if exist "security-tests-report.json" (
    echo ✅ Testes de Segurança Customizados: SUCESSO >> dast-report.md
    echo - Relatório: security-tests-report.json >> dast-report.md
) else (
    echo ❌ Testes de Segurança Customizados: FALHOU >> dast-report.md
)
echo. >> dast-report.md

echo ## Vulnerabilidades Identificadas >> dast-report.md
echo. >> dast-report.md

REM Analisar relatório ZAP JSON se disponível
if exist "zap-baseline-report.json" (
    echo ### OWASP ZAP - Vulnerabilidades por Severidade: >> dast-report.md
    echo - **Alta**: Verificar relatório JSON para detalhes >> dast-report.md
    echo - **Média**: Verificar relatório JSON para detalhes >> dast-report.md
    echo - **Baixa**: Verificar relatório JSON para detalhes >> dast-report.md
    echo - **Informativa**: Verificar relatório JSON para detalhes >> dast-report.md
)
echo. >> dast-report.md

echo ## Recomendações de Mitigação >> dast-report.md
echo. >> dast-report.md
echo 1. **Prioridade Alta**: Corrigir vulnerabilidades de alta severidade identificadas pelo ZAP >> dast-report.md
echo 2. **Prioridade Média**: Revisar e corrigir vulnerabilidades de média severidade >> dast-report.md
echo 3. **Configuração**: Implementar headers de segurança adicionais >> dast-report.md
echo 4. **Monitoramento**: Configurar alertas para tentativas de ataque >> dast-report.md
echo 5. **Testes Regulares**: Executar testes DAST em cada deploy >> dast-report.md

echo.
echo ========================================
echo Análise DAST Concluída!
echo ========================================
echo.
echo Relatórios gerados:
if exist "zap-baseline-report.html" (
    echo - zap-baseline-report.html (OWASP ZAP)
) else (
    echo - OWASP ZAP: Não gerado
)
if exist "nikto-report.html" (
    echo - nikto-report.html (Nikto)
) else (
    echo - Nikto: Não gerado
)
if exist "security-tests-report.json" (
    echo - security-tests-report.json (Testes Customizados)
) else (
    echo - Testes Customizados: Não gerado
)
echo - dast-report.md (Consolidado)
echo.

echo Parando aplicação Spring Boot...
taskkill /F /IM java.exe >nul 2>&1

echo.
echo Abrindo relatório consolidado...
start dast-report.md

echo.
echo ✅ Análise DAST concluída com sucesso!
echo 📄 Verifique os relatórios gerados para detalhes das vulnerabilidades
pause
