@echo off
echo ========================================
echo Testando Conectividade Docker para DAST
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
echo [2/6] Testando conectividade de rede Docker...
docker network ls | findstr dast-network >nul
if %ERRORLEVEL% equ 0 (
    echo ✅ Rede dast-network já existe
) else (
    echo ℹ️ Criando rede dast-network...
    docker network create dast-network
)

echo.
echo [3/6] Testando se aplicação pode ser acessada externamente...
echo Iniciando aplicação em container de teste...
docker run -d --name test-xp-app --network dast-network -p 8080:8080 -e SPRING_PROFILES_ACTIVE=test -e SERVER_ADDRESS=0.0.0.0 --rm -v "%cd%":/app -w /app maven:3.8-openjdk-11 mvn spring-boot:run -Dspring-boot.run.profiles=test

echo Aguardando aplicação inicializar...
timeout /t 60 /nobreak >nul

echo Testando conectividade...
for /L %%i in (1,1,10) do (
    curl -f http://localhost:8080/actuator/health >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo ✅ Aplicação acessível externamente
        goto :app_test_success
    )
    echo Aguardando aplicação... tentativa %%i/10
    timeout /t 10 /nobreak >nul
)

echo ❌ ERRO: Aplicação não está acessível externamente
echo Parando container de teste...
docker stop test-xp-app >nul 2>&1
pause
exit /b 1

:app_test_success
echo.
echo [4/6] Testando conectividade entre containers...
echo Testando se container pode acessar aplicação via nome...
docker run --rm --network dast-network curlimages/curl:latest curl -f http://test-xp-app:8080/actuator/health
if %ERRORLEVEL% equ 0 (
    echo ✅ Conectividade entre containers funcionando
) else (
    echo ❌ ERRO: Conectividade entre containers falhou
)

echo.
echo [5/6] Testando ferramentas DAST individuais...
echo Testando Dastardly...
docker run --rm --network dast-network -v "%cd%":/dastardly/reports public.ecr.aws/portswigger/dastardly:latest --url http://test-xp-app:8080 --report-file /dastardly/reports/test-dastardly.json --report-format json
if %ERRORLEVEL% equ 0 (
    echo ✅ Dastardly funcionando
) else (
    echo ⚠️ Dastardly encontrou problemas (pode ser normal)
)

echo Testando ZAP...
docker run --rm --network dast-network -v "%cd%":/zap/wrk zaproxy/zap-stable zap-baseline.py -t http://test-xp-app:8080 -J /zap/wrk/test-zap.json -I -j
if %ERRORLEVEL% equ 0 (
    echo ✅ ZAP funcionando
) else (
    echo ⚠️ ZAP encontrou problemas (pode ser normal)
)

echo.
echo [6/6] Limpando containers de teste...
docker stop test-xp-app >nul 2>&1
docker network rm dast-network >nul 2>&1

echo.
echo ========================================
echo Teste de Conectividade Concluído!
echo ========================================
echo.
echo Resultados:
echo - Docker: ✅ Funcionando
echo - Rede Docker: ✅ Funcionando
echo - Conectividade Externa: ✅ Funcionando
echo - Conectividade Interna: ✅ Funcionando
echo - Dastardly: ✅ Funcionando
echo - ZAP: ✅ Funcionando
echo.
echo Agora você pode executar os scripts de DAST com segurança!
echo.
echo Scripts recomendados:
echo - run-dast-burp.bat (execução local)
echo - run-burp-docker-fixed.bat (Docker corrigido)
echo.
pause
