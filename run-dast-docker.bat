@echo off
echo ========================================
echo Executando Análise DAST com Docker Compose
echo ========================================

echo.
echo [1/5] Verificando dependências...

REM Verificar se Docker está instalado
docker --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERRO: Docker não está instalado ou não está no PATH
    echo Instale o Docker Desktop e tente novamente
    pause
    exit /b 1
)

REM Verificar se Docker Compose está disponível
docker-compose --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERRO: Docker Compose não está disponível
    echo Verifique se o Docker Desktop está instalado corretamente
    pause
    exit /b 1
)

echo ✅ Docker e Docker Compose encontrados

echo.
echo [2/5] Criando diretórios para relatórios...
if not exist "zap-reports" mkdir zap-reports
if not exist "nikto-reports" mkdir nikto-reports
if not exist "sqlmap-reports" mkdir sqlmap-reports
if not exist "wapiti-reports" mkdir wapiti-reports

echo.
echo [3/5] Iniciando serviços DAST...
echo Iniciando aplicação XP e ferramentas de segurança...
docker-compose -f docker-compose-dast.yml up -d

echo Aguardando serviços inicializarem...
timeout /t 120 /nobreak >nul

echo.
echo [4/5] Executando varreduras de segurança...

echo Executando OWASP ZAP Baseline Scan...
docker-compose -f docker-compose-dast.yml exec zap zap-baseline.py ^
  -t http://xp-app:8080 ^
  -J /zap/wrk/zap-baseline-report.json ^
  -x /zap/wrk/zap-baseline-report.xml ^
  -r /zap/wrk/zap-baseline-report.html ^
  -I ^
  -j

echo Executando Nikto...
docker-compose -f docker-compose-dast.yml exec nikto nikto -h http://xp-app:8080 ^
  -output /tmp/reports/nikto-report.html ^
  -Format htm ^
  -Tuning 1,2,3,4,5,6,7,8,9,0,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z

echo Executando SQLMap...
docker-compose -f docker-compose-dast.yml exec sqlmap sqlmap -u "http://xp-app:8080/api/auth/authenticate" ^
  --data "username=admin&password=admin" ^
  --batch ^
  --output-dir=/tmp/reports

echo Executando Wapiti...
docker-compose -f docker-compose-dast.yml exec wapiti wapiti -u http://xp-app:8080 ^
  --output /tmp/reports/wapiti-report.html ^
  --format html

echo.
echo [5/5] Gerando relatório consolidado...

echo # Relatório de Testes Dinâmicos de Segurança (DAST) > dast-docker-report.md
echo Data: %date% %time% >> dast-docker-report.md
echo. >> dast-docker-report.md
echo ## Resumo dos Testes DAST >> dast-docker-report.md
echo. >> dast-docker-report.md

if exist "zap-reports\zap-baseline-report.html" (
    echo ✅ OWASP ZAP Baseline Scan: SUCESSO >> dast-docker-report.md
    echo - Relatório HTML: zap-reports\zap-baseline-report.html >> dast-docker-report.md
    echo - Relatório JSON: zap-reports\zap-baseline-report.json >> dast-docker-report.md
    echo - Relatório XML: zap-reports\zap-baseline-report.xml >> dast-docker-report.md
) else (
    echo ❌ OWASP ZAP Baseline Scan: FALHOU >> dast-docker-report.md
)
echo. >> dast-docker-report.md

if exist "nikto-reports\nikto-report.html" (
    echo ✅ Nikto Web Vulnerability Scanner: SUCESSO >> dast-docker-report.md
    echo - Relatório: nikto-reports\nikto-report.html >> dast-docker-report.md
) else (
    echo ❌ Nikto Web Vulnerability Scanner: FALHOU >> dast-docker-report.md
)
echo. >> dast-docker-report.md

if exist "sqlmap-reports" (
    echo ✅ SQLMap SQL Injection Scanner: SUCESSO >> dast-docker-report.md
    echo - Relatórios: sqlmap-reports\ >> dast-docker-report.md
) else (
    echo ❌ SQLMap SQL Injection Scanner: FALHOU >> dast-docker-report.md
)
echo. >> dast-docker-report.md

if exist "wapiti-reports\wapiti-report.html" (
    echo ✅ Wapiti Web Vulnerability Scanner: SUCESSO >> dast-docker-report.md
    echo - Relatório: wapiti-reports\wapiti-report.html >> dast-docker-report.md
) else (
    echo ❌ Wapiti Web Vulnerability Scanner: FALHOU >> dast-docker-report.md
)
echo. >> dast-docker-report.md

echo ## Vulnerabilidades Identificadas >> dast-docker-report.md
echo. >> dast-docker-report.md
echo ### Ferramentas Utilizadas: >> dast-docker-report.md
echo - **OWASP ZAP**: Varredura de vulnerabilidades web >> dast-docker-report.md
echo - **Nikto**: Scanner de vulnerabilidades web >> dast-docker-report.md
echo - **SQLMap**: Testes de SQL Injection >> dast-docker-report.md
echo - **Wapiti**: Scanner de vulnerabilidades web >> dast-docker-report.md
echo. >> dast-docker-report.md

echo ## Recomendações de Mitigação >> dast-docker-report.md
echo. >> dast-docker-report.md
echo 1. **Prioridade Alta**: Corrigir vulnerabilidades de alta severidade >> dast-docker-report.md
echo 2. **Prioridade Média**: Revisar vulnerabilidades de média severidade >> dast-docker-report.md
echo 3. **Configuração**: Implementar headers de segurança >> dast-docker-report.md
echo 4. **Monitoramento**: Configurar alertas de segurança >> dast-docker-report.md
echo 5. **Testes Regulares**: Executar DAST em cada deploy >> dast-docker-report.md

echo.
echo ========================================
echo Análise DAST com Docker Concluída!
echo ========================================
echo.
echo Relatórios gerados:
if exist "zap-reports\zap-baseline-report.html" (
    echo - zap-reports\zap-baseline-report.html (OWASP ZAP)
) else (
    echo - OWASP ZAP: Não gerado
)
if exist "nikto-reports\nikto-report.html" (
    echo - nikto-reports\nikto-report.html (Nikto)
) else (
    echo - Nikto: Não gerado
)
if exist "sqlmap-reports" (
    echo - sqlmap-reports\ (SQLMap)
) else (
    echo - SQLMap: Não gerado
)
if exist "wapiti-reports\wapiti-report.html" (
    echo - wapiti-reports\wapiti-report.html (Wapiti)
) else (
    echo - Wapiti: Não gerado
)
echo - dast-docker-report.md (Consolidado)
echo.

echo Parando serviços Docker...
docker-compose -f docker-compose-dast.yml down

echo.
echo Abrindo relatório consolidado...
start dast-docker-report.md

echo.
echo ✅ Análise DAST com Docker concluída com sucesso!
echo 📄 Verifique os relatórios gerados para detalhes das vulnerabilidades
pause
