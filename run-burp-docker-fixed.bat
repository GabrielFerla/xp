@echo off
echo ========================================
echo Executando DAST com Burp Suite via Docker (CORRIGIDO)
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
echo [2/5] Testando conectividade Docker...
echo Executando teste de conectividade...
call test-docker-connectivity.bat
if %ERRORLEVEL% neq 0 (
    echo ❌ ERRO: Teste de conectividade falhou
    echo Corrija os problemas de conectividade antes de continuar
    pause
    exit /b 1
)

echo.
echo [3/5] Iniciando ambiente de testes com Docker Compose corrigido...
echo Iniciando aplicação e ferramentas de segurança...
docker-compose -f docker-compose-burp-fixed.yml up --build -d

echo Aguardando serviços inicializarem...
timeout /t 120 /nobreak >nul

echo.
echo [4/5] Verificando status dos serviços...
docker-compose -f docker-compose-burp-fixed.yml ps

echo.
echo [5/5] Monitorando execução dos testes...
echo Os testes estão sendo executados em background...
echo.
echo Para monitorar o progresso:
echo - Logs gerais: docker-compose -f docker-compose-burp-fixed.yml logs -f
echo - Logs da aplicação: docker-compose -f docker-compose-burp-fixed.yml logs -f xp-app
echo - Logs do Dastardly: docker-compose -f docker-compose-burp-fixed.yml logs -f dastardly
echo - Logs do ZAP: docker-compose -f docker-compose-burp-fixed.yml logs -f zap
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
echo Comandos úteis:
echo - Ver status: docker-compose -f docker-compose-burp-fixed.yml ps
echo - Ver logs: docker-compose -f docker-compose-burp-fixed.yml logs -f
echo - Parar serviços: docker-compose -f docker-compose-burp-fixed.yml down
echo - Reiniciar: docker-compose -f docker-compose-burp-fixed.yml restart
echo.
echo Aguardando conclusão dos testes...
echo (Os testes podem levar 10-15 minutos para completar)
echo.
pause
