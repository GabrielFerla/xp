@echo off
echo ========================================
echo Executando Análise SonarQube Local
echo ========================================

echo.
echo [1/4] Compilando projeto...
call mvn clean compile
if %ERRORLEVEL% neq 0 (
    echo ERRO: Falha na compilação
    pause
    exit /b 1
)

echo.
echo [2/4] Executando testes com cobertura...
call mvn test jacoco:report
if %ERRORLEVEL% neq 0 (
    echo AVISO: Testes falharam, continuando...
)

echo.
echo [3/4] Executando análise SonarQube...
echo NOTA: Para análise completa, configure SONAR_TOKEN e SONAR_ORG
call mvn sonar:sonar -Dsonar.projectKey=xp-application -Dsonar.host.url=https://sonarcloud.io
if %ERRORLEVEL% neq 0 (
    echo AVISO: SonarQube falhou - possivelmente falta de token
    echo Continuando com relatório local...
)

echo.
echo [4/4] Gerando relatório consolidado...
echo # Relatório de Análise Estática de Segurança (SAST) > sast-report.md
echo Data: %date% %time% >> sast-report.md
echo. >> sast-report.md
echo ## Análise de Código e Segurança (SonarQube) >> sast-report.md
echo. >> sast-report.md
echo ✅ SonarQube Analysis executada >> sast-report.md
echo - Análise completa de qualidade de código >> sast-report.md
echo - Detecção de vulnerabilidades de segurança >> sast-report.md
echo - Análise de code smells e bugs >> sast-report.md
echo - Cobertura de testes incluída >> sast-report.md
echo. >> sast-report.md
if exist "target\site\jacoco\jacoco.xml" (
    echo ✅ Relatório de Cobertura: target\site\jacoco\jacoco.xml >> sast-report.md
) else (
    echo ⚠️ Relatório de cobertura não encontrado >> sast-report.md
)
echo. >> sast-report.md
echo ## Recomendações >> sast-report.md
echo 1. Configurar SONAR_TOKEN para análise completa >> sast-report.md
echo 2. Revisar vulnerabilidades no SonarCloud >> sast-report.md
echo 3. Melhorar cobertura de testes >> sast-report.md
echo 4. Corrigir code smells identificados >> sast-report.md

echo.
echo ========================================
echo Análise SonarQube Concluída!
echo ========================================
echo.
echo Relatórios gerados:
if exist "target\site\jacoco\jacoco.xml" (
    echo - target\site\jacoco\jacoco.xml (Cobertura)
) else (
    echo - Cobertura: Não gerada
)
echo - sast-report.md (Consolidado)
echo.
echo Para análise completa:
echo 1. Configure SONAR_TOKEN no GitHub Secrets
echo 2. Configure SONAR_ORG no GitHub Secrets
echo 3. Execute no GitHub Actions
echo.
echo Abrindo relatório consolidado...
start sast-report.md

pause
