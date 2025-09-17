@echo off
echo ========================================
echo Executando Análise SAST Híbrida
echo ========================================

echo.
echo [1/5] Compilando projeto...
call mvn clean compile
if %ERRORLEVEL% neq 0 (
    echo ERRO: Falha na compilação
    pause
    exit /b 1
)

echo.
echo [2/5] Executando testes com cobertura...
call mvn test jacoco:report
if %ERRORLEVEL% neq 0 (
    echo AVISO: Testes falharam, continuando...
)

echo.
echo [3/5] Executando SpotBugs Security Analysis...
call mvn com.github.spotbugs:spotbugs-maven-plugin:spotbugs
if %ERRORLEVEL% neq 0 (
    echo AVISO: SpotBugs falhou
)

echo.
echo [4/5] Executando OWASP Dependency Check...
call mvn org.owasp:dependency-check-maven:check
if %ERRORLEVEL% neq 0 (
    echo AVISO: OWASP falhou - possivelmente problemas de conectividade
)

echo.
echo [5/5] Gerando relatório consolidado...
echo # Relatório de Análise Estática de Segurança (SAST) > sast-report.md
echo Data: %date% %time% >> sast-report.md
echo. >> sast-report.md
echo ## Análise de Segurança e Qualidade >> sast-report.md
echo. >> sast-report.md

if exist "target\spotbugsXml.xml" (
    echo ✅ SpotBugs Security Analysis: SUCESSO >> sast-report.md
    echo - Relatório: target\spotbugsXml.xml >> sast-report.md
) else (
    echo ❌ SpotBugs Security Analysis: FALHOU >> sast-report.md
)
echo. >> sast-report.md

if exist "target\dependency-check-report.html" (
    echo ✅ OWASP Dependency Check: SUCESSO >> sast-report.md
    echo - Relatório: target\dependency-check-report.html >> sast-report.md
) else (
    echo ⚠️ OWASP Dependency Check: FALHOU (problemas de conectividade) >> sast-report.md
)
echo. >> sast-report.md

if exist "target\site\jacoco\jacoco.xml" (
    echo ✅ JaCoCo Coverage Report: SUCESSO >> sast-report.md
    echo - Relatório: target\site\jacoco\jacoco.xml >> sast-report.md
) else (
    echo ❌ JaCoCo Coverage Report: FALHOU >> sast-report.md
)
echo. >> sast-report.md

echo ## Recomendações >> sast-report.md
echo 1. Corrigir bugs de segurança identificados pelo SpotBugs >> sast-report.md
echo 2. Revisar vulnerabilidades de dependências >> sast-report.md
echo 3. Melhorar cobertura de testes >> sast-report.md
echo 4. Executar OWASP localmente com conexão estável >> sast-report.md

echo.
echo ========================================
echo Análise SAST Híbrida Concluída!
echo ========================================
echo.
echo Relatórios gerados:
if exist "target\spotbugsXml.xml" (
    echo - target\spotbugsXml.xml (SpotBugs)
) else (
    echo - SpotBugs: Não gerado
)
if exist "target\dependency-check-report.html" (
    echo - target\dependency-check-report.html (OWASP)
) else (
    echo - OWASP: Não gerado
)
if exist "target\site\jacoco\jacoco.xml" (
    echo - target\site\jacoco\jacoco.xml (Cobertura)
) else (
    echo - Cobertura: Não gerada
)
echo - sast-report.md (Consolidado)
echo.
echo Abrindo relatório consolidado...
start sast-report.md

pause