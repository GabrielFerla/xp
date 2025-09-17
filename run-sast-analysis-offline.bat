@echo off
echo ========================================
echo Executando Análise SAST Local (Modo Offline)
echo ========================================

echo.
echo [1/3] Tentando OWASP Dependency Check...
call mvn org.owasp:dependency-check-maven:check
set OWASP_SUCCESS=%ERRORLEVEL%

if %OWASP_SUCCESS% neq 0 (
    echo ⚠️ OWASP Dependency Check falhou - possivelmente problemas de conectividade
    echo Continuando apenas com SpotBugs...
    set OWASP_FAILED=true
) else (
    echo ✅ OWASP Dependency Check executado com sucesso
    set OWASP_FAILED=false
)

echo.
echo [2/3] Executando SpotBugs Security Analysis...
call mvn com.github.spotbugs:spotbugs-maven-plugin:check
if %ERRORLEVEL% neq 0 (
    echo ❌ ERRO: Falha na análise SpotBugs
    pause
    exit /b 1
)

echo.
echo [3/3] Gerando relatório consolidado...
echo # Relatório de Análise Estática de Segurança (SAST) > sast-report.md
echo Data: %date% %time% >> sast-report.md
echo. >> sast-report.md
echo ## Vulnerabilidades de Dependências (OWASP Dependency Check) >> sast-report.md
echo. >> sast-report.md

if "%OWASP_FAILED%"=="true" (
    echo ⚠️ OWASP Dependency Check falhou devido a problemas de conectividade >> sast-report.md
    echo - Possível bloqueio de rede ou proxy >> sast-report.md
    echo - Recomenda-se executar com conexão estável >> sast-report.md
    echo - Alternativa: usar análise manual de dependências >> sast-report.md
) else (
    if exist "target\dependency-check-report.html" (
        echo ✅ Relatório OWASP gerado: target\dependency-check-report.html >> sast-report.md
        echo - Análise completa de vulnerabilidades de dependências >> sast-report.md
        echo - Classificação por CVSS score >> sast-report.md
    ) else (
        echo ❌ Falha na geração do relatório OWASP >> sast-report.md
    )
)

echo. >> sast-report.md
echo ## Análise de Código Estático (SpotBugs) >> sast-report.md
echo. >> sast-report.md
if exist "target\spotbugsXml.xml" (
    echo ✅ Relatório SpotBugs gerado: target\spotbugsXml.xml >> sast-report.md
    echo - Análise de bugs de segurança no código >> sast-report.md
    echo - Foco em vulnerabilidades críticas (Rank 1-3) >> sast-report.md
) else (
    echo ❌ Falha na geração do relatório SpotBugs >> sast-report.md
)

echo. >> sast-report.md
echo ## Recomendações >> sast-report.md
echo 1. Revisar vulnerabilidades de dependências com CVSS ^>= 7.0 >> sast-report.md
echo 2. Corrigir bugs de segurança identificados pelo SpotBugs >> sast-report.md
echo 3. Atualizar dependências com vulnerabilidades conhecidas >> sast-report.md
if "%OWASP_FAILED%"=="true" (
    echo 4. Executar OWASP Dependency Check com conexão estável >> sast-report.md
    echo 5. Considerar usar proxy corporativo se disponível >> sast-report.md
)

echo.
echo ========================================
echo Análise SAST Concluída!
echo ========================================
echo.
echo Relatórios gerados:
if exist "target\dependency-check-report.html" (
    echo - target\dependency-check-report.html (OWASP)
) else (
    echo - OWASP: Falhou (problemas de conectividade)
)
if exist "target\spotbugsXml.xml" (
    echo - target\spotbugsXml.xml (SpotBugs)
) else (
    echo - SpotBugs: Falhou
)
echo - sast-report.md (Consolidado)
echo.
echo Abrindo relatório consolidado...
start sast-report.md

pause
