@echo off
echo ========================================
echo Executando Análise SAST Local
echo ========================================

echo.
echo [1/3] Executando OWASP Dependency Check...
call mvn org.owasp:dependency-check-maven:check
if %ERRORLEVEL% neq 0 (
    echo ERRO: Falha na análise OWASP Dependency Check
    pause
    exit /b 1
)

echo.
echo [2/3] Executando SpotBugs Security Analysis...
call mvn com.github.spotbugs:spotbugs-maven-plugin:check
if %ERRORLEVEL% neq 0 (
    echo ERRO: Falha na análise SpotBugs
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
if exist "target\dependency-check-report.html" (
    echo ✅ Relatório OWASP gerado: target\dependency-check-report.html >> sast-report.md
) else (
    echo ❌ Falha na geração do relatório OWASP >> sast-report.md
)
echo. >> sast-report.md
echo ## Análise de Código Estático (SpotBugs) >> sast-report.md
echo. >> sast-report.md
if exist "target\spotbugsXml.xml" (
    echo ✅ Relatório SpotBugs gerado: target\spotbugsXml.xml >> sast-report.md
) else (
    echo ❌ Falha na geração do relatório SpotBugs >> sast-report.md
)
echo. >> sast-report.md
echo ## Recomendações >> sast-report.md
echo 1. Revisar vulnerabilidades de dependências com CVSS ^>= 7.0 >> sast-report.md
echo 2. Corrigir bugs de segurança identificados pelo SpotBugs >> sast-report.md
echo 3. Atualizar dependências com vulnerabilidades conhecidas >> sast-report.md

echo.
echo ========================================
echo Análise SAST Concluída!
echo ========================================
echo.
echo Relatórios gerados:
echo - target\dependency-check-report.html (OWASP)
echo - target\spotbugsXml.xml (SpotBugs)
echo - sast-report.md (Consolidado)
echo.
echo Abrindo relatório consolidado...
start sast-report.md

pause
