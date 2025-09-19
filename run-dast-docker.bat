@echo off
echo ========================================
echo Executando DAST com Docker Compose
echo ========================================
echo.

echo [1/3] Verificando se Docker está instalado...
docker --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ ERRO: Docker não está instalado ou não está no PATH
    echo Instale o Docker Desktop e tente novamente
    pause
    exit /b 1
)

echo ✅ Docker encontrado

echo.
echo [2/3] Executando ambiente de DAST com Docker Compose...
echo Iniciando aplicação e OWASP ZAP...
docker-compose -f docker-compose-dast.yml up --build

if %ERRORLEVEL% neq 0 (
    echo ⚠️ AVISO: Alguns serviços podem ter falhado, mas continuando...
)

echo.
echo [3/3] Coletando relatórios...
echo Copiando relatórios para diretório principal...

if exist "zap-reports\*.json" (
    copy "zap-reports\*.json" . >nul 2>&1
    echo ✅ Relatórios JSON copiados
)

if exist "zap-reports\*.html" (
    copy "zap-reports\*.html" . >nul 2>&1
    echo ✅ Relatórios HTML copiados
)

if exist "zap-reports\*.xml" (
    copy "zap-reports\*.xml" . >nul 2>&1
    echo ✅ Relatórios XML copiados
)

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
echo.

echo ✅ Análise DAST concluída com sucesso!
echo 📄 Verifique os relatórios gerados para detalhes das vulnerabilidades
echo 🐳 Executado com Docker Compose
echo.
echo 💡 Para limpar os containers: docker-compose -f docker-compose-dast.yml down
pause
