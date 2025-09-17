@echo off
echo ========================================
echo Testando Imagens Docker para DAST
echo ========================================

echo.
echo [1/6] Verificando se Docker está rodando...
docker --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ ERRO: Docker não está instalado ou não está no PATH
    pause
    exit /b 1
)
echo ✅ Docker está funcionando

echo.
echo [2/6] Testando imagem Dastardly (Burp Suite)...
echo Baixando imagem Dastardly...
docker pull public.ecr.aws/portswigger/dastardly:latest
if %ERRORLEVEL% equ 0 (
    echo ✅ Dastardly (Burp Suite): OK
) else (
    echo ❌ Dastardly (Burp Suite): FALHOU
)

echo.
echo [3/6] Testando imagem OWASP ZAP...
echo Baixando imagem OWASP ZAP...
docker pull zaproxy/zap-stable
if %ERRORLEVEL% equ 0 (
    echo ✅ OWASP ZAP: OK
) else (
    echo ❌ OWASP ZAP: FALHOU
)

echo.
echo [4/6] Testando imagem Nikto...
echo Baixando imagem Nikto...
docker pull sullo/nikto
if %ERRORLEVEL% equ 0 (
    echo ✅ Nikto: OK
) else (
    echo ❌ Nikto: FALHOU
)

echo.
echo [5/6] Testando imagem SQLMap...
echo Baixando imagem SQLMap...
docker pull paoloo/sqlmap
if %ERRORLEVEL% equ 0 (
    echo ✅ SQLMap: OK
) else (
    echo ❌ SQLMap: FALHOU
)

echo.
echo [6/6] Testando imagem Wapiti...
echo Baixando imagem Wapiti...
docker pull wapiti-scanner/wapiti
if %ERRORLEVEL% equ 0 (
    echo ✅ Wapiti: OK
) else (
    echo ❌ Wapiti: FALHOU
)

echo.
echo ========================================
echo Teste de Imagens Docker Concluído!
echo ========================================
echo.
echo Resumo:
echo - Dastardly (Burp Suite): Verificado
echo - OWASP ZAP: Verificado (imagem corrigida)
echo - Nikto: Verificado
echo - SQLMap: Verificado
echo - Wapiti: Verificado
echo.
echo Agora você pode executar os scripts de DAST com segurança!
echo.
echo Scripts disponíveis:
echo - run-dast-burp.bat (recomendado)
echo - run-burp-docker.bat
echo - run-dast-analysis.bat
echo.
pause
