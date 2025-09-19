@echo off
echo ========================================
echo Executando SAST + DAST Integrado via Docker
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

echo ✅ Docker encontrado

echo.
echo [2/5] Executando SAST com Docker...
echo Executando análise estática de segurança...

REM Executar SpotBugs Security via Docker
docker run --rm -v "%cd%":/workspace -w /workspace ^
  maven:3.8-openjdk-11 ^
  mvn clean compile spotbugs:check -Dspotbugs.failOnError=false

if %ERRORLEVEL% neq 0 (
    echo ⚠️ AVISO: SpotBugs encontrou problemas de segurança
)

REM Executar OWASP Dependency Check via Docker
docker run --rm -v "%cd%":/workspace -w /workspace ^
  maven:3.8-openjdk-11 ^
  mvn org.owasp:dependency-check-maven:check -DfailBuildOnCVSS=7

if %ERRORLEVEL% neq 0 (
    echo ⚠️ AVISO: Dependency Check encontrou vulnerabilidades
)

echo.
echo [3/5] Iniciando ambiente de testes DAST com Docker Compose...
echo Iniciando aplicação e ferramentas de segurança...
docker-compose -f docker-compose-burp.yml up --build -d

echo Aguardando serviços inicializarem...
timeout /t 120 /nobreak >nul

echo.
echo [4/5] Verificando status dos serviços...
docker-compose -f docker-compose-burp.yml ps

echo.
echo [5/5] Aguardando conclusão dos testes DAST...
echo Os testes podem levar alguns minutos para completar...
echo Monitore os logs com: docker-compose -f docker-compose-burp.yml logs -f

echo.
echo ========================================
echo Ambiente Integrado SAST + DAST Iniciado!
echo ========================================
echo.
echo Serviços disponíveis:
echo - Aplicação XP: http://localhost:8080
echo - OWASP ZAP: http://localhost:8081
echo - Nginx Proxy: http://localhost:80
echo.
echo Relatórios SAST salvos em:
echo - target\spotbugsXml.xml (SpotBugs Security)
echo - target\dependency-check-report.html (OWASP Dependency Check)
echo.
echo Relatórios DAST salvos em:
echo - ./dastardly-reports/ (Dastardly - Burp Suite)
echo - ./zap-reports/ (OWASP ZAP)
echo - ./nikto-reports/ (Nikto)
echo - ./sqlmap-reports/ (SQLMap)
echo - ./wapiti-reports/ (Wapiti)
echo.
echo Para parar os serviços: docker-compose -f docker-compose-burp.yml down
echo Para ver logs: docker-compose -f docker-compose-burp.yml logs -f
echo.
echo 💡 Dica: Use run-sast-dast-integrated.bat para execução local completa
echo.
pause
