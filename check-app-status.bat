@echo off
echo ========================================
echo Verificador de Status da Aplicação XP
echo ========================================

echo.
echo [1/4] Verificando processos Java...
tasklist /FI "IMAGENAME eq java.exe" 2>NUL | find /I /N "java.exe" >NUL
if %ERRORLEVEL% equ 0 (
    echo ✅ Processo Java encontrado
    tasklist /FI "IMAGENAME eq java.exe"
) else (
    echo ❌ Nenhum processo Java encontrado
)

echo.
echo [2/4] Verificando portas em uso...
netstat -an | findstr :8082 >nul
if %ERRORLEVEL% equ 0 (
    echo ✅ Porta 8082 está em uso
    netstat -an | findstr :8082
) else (
    echo ❌ Porta 8082 não está em uso
)

echo.
echo [3/4] Testando conectividade HTTP...
curl -f http://localhost:8082/actuator/health >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo ✅ Aplicação está respondendo na porta 8082
    echo.
    echo Testando endpoint de saúde...
    curl -s http://localhost:8082/actuator/health
    echo.
) else (
    echo ❌ Aplicação não está respondendo na porta 8082
)

echo.
echo [4/4] Verificando configuração da aplicação...
if exist "src\main\resources\application-test.properties" (
    echo ✅ Arquivo de configuração de teste encontrado
    echo.
    echo Configurações relevantes:
    findstr "server.port" src\main\resources\application-test.properties
    findstr "spring.profiles" src\main\resources\application-test.properties
) else (
    echo ❌ Arquivo de configuração de teste não encontrado
)

echo.
echo ========================================
echo Resumo do Status
echo ========================================
echo.
echo Se a aplicação não está rodando, execute:
echo   mvn spring-boot:run -Dspring-boot.run.profiles=test
echo.
echo Se a porta 8082 estiver ocupada, execute:
echo   netstat -ano ^| findstr :8082
echo   taskkill /PID [PID_NUMBER] /F
echo.
echo Para verificar logs da aplicação:
echo   tail -f logs/security-audit.log
echo.
pause
