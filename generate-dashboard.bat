@echo off
echo ==========================================
echo 📊 GERANDO DASHBOARD DE SEGURANÇA
echo ==========================================
echo.

REM Verificar se Python está disponível
python --version >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ ERRO: Python não encontrado no PATH
    echo    Instale o Python e adicione ao PATH
    pause
    exit /b 1
)

echo ✅ Python encontrado
echo.

REM Executar script de geração do dashboard
echo 🔄 Executando script de geração...
python generate-dashboard.py

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Dashboard gerado com sucesso!
    echo 📄 Arquivo: security-dashboard.html
    echo.
    echo Deseja abrir o dashboard? (S/N)
    set /p OPEN_DASHBOARD=
    if /i "%OPEN_DASHBOARD%"=="S" (
        start "" "security-dashboard.html"
    )
) else (
    echo ❌ ERRO: Falha na geração do dashboard
)

echo.
echo Pressione qualquer tecla para sair...
pause >nul
