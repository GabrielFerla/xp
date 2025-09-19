@echo off
echo ==========================================
echo 🔍 EXECUTANDO OWASP DEPENDENCY CHECK
echo ==========================================
echo.

REM Verificar se Maven está disponível
where mvn >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ ERRO: Maven não encontrado no PATH
    echo    Instale o Maven e adicione ao PATH
    pause
    exit /b 1
)

echo ✅ Maven encontrado
echo.

REM Compilar projeto primeiro
echo 🔨 Compilando projeto...
call mvn clean compile -q
if %ERRORLEVEL% NEQ 0 (
    echo ❌ ERRO: Falha na compilação
    pause
    exit /b 1
)

echo ✅ Compilação concluída
echo.

REM Executar OWASP Dependency Check
echo 🔍 Executando OWASP Dependency Check...
call mvn org.owasp:dependency-check-maven:check -DfailBuildOnCVSS=0 -DfailOnError=false
OWASP_EXIT_CODE=%ERRORLEVEL%

if %OWASP_EXIT_CODE% EQU 0 (
    echo ✅ OWASP Dependency Check concluído com sucesso!
) else (
    echo ⚠️ OWASP encontrou problemas - continuando...
)

echo.

REM Verificar relatórios gerados
echo 📊 Verificando relatórios gerados...
if exist "target\sca-reports\dependency-check-report.html" (
    echo ✅ Relatório HTML: target\sca-reports\dependency-check-report.html
) else (
    echo ❌ Relatório HTML não encontrado
)

if exist "target\sca-reports\dependency-check-report.json" (
    echo ✅ Relatório JSON: target\sca-reports\dependency-check-report.json
) else (
    echo ⚠️ Relatório JSON não encontrado
)

if exist "target\sca-reports\dependency-check-report.xml" (
    echo ✅ Relatório XML: target\sca-reports\dependency-check-report.xml
) else (
    echo ⚠️ Relatório XML não encontrado
)

echo.

REM Gerar dashboard
echo 📊 Gerando dashboard de segurança...
python generate-dashboard.py
if %ERRORLEVEL% EQU 0 (
    echo ✅ Dashboard gerado com sucesso!
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
