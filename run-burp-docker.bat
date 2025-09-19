@echo off
echo ========================================
echo Executando DAST com Burp Suite via Docker
echo ========================================

echo.
echo [1/4] Verificando dependências...

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
echo [2/4] Iniciando ambiente de testes com Docker Compose...
echo Iniciando aplicação e ferramentas de segurança...
docker-compose -f docker-compose-burp.yml up --build -d

echo Aguardando serviços inicializarem...
timeout /t 120 /nobreak >nul

echo.
echo [3/4] Verificando status dos serviços...
docker-compose -f docker-compose-burp.yml ps

echo.
echo [4/4] Aguardando conclusão dos testes...
echo Os testes podem levar alguns minutos para completar...
echo Monitore os logs com: docker-compose -f docker-compose-burp.yml logs -f

echo.
echo ========================================
echo Ambiente de Testes DAST Iniciado!
echo ========================================
echo.
echo Serviços disponíveis:
echo - Aplicação XP: http://localhost:8080
echo - OWASP ZAP: http://localhost:8081
echo - Nginx Proxy: http://localhost:80
echo.
echo Relatórios serão salvos em:
echo - ./dastardly-reports/ (Dastardly - Burp Suite)
echo - ./zap-reports/ (OWASP ZAP)
echo - ./nikto-reports/ (Nikto)
echo - ./sqlmap-reports/ (SQLMap)
echo - ./wapiti-reports/ (Wapiti)
echo.
echo Para parar os serviços: docker-compose -f docker-compose-burp.yml down
echo Para ver logs: docker-compose -f docker-compose-burp.yml logs -f
echo.
pause
