@echo off
echo ========================================
echo Executando Análise Integrada SAST + DAST
echo ========================================

echo.
echo [1/8] Verificando dependências...

REM Verificar se Docker está instalado
docker --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERRO: Docker não está instalado ou não está no PATH
    echo Instale o Docker Desktop e tente novamente
    pause
    exit /b 1
)

REM Verificar se Java está instalado
java -version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERRO: Java não está instalado ou não está no PATH
    echo Instale o Java 8+ e tente novamente
    pause
    exit /b 1
)

REM Verificar se Maven está instalado
mvn --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERRO: Maven não está instalado ou não está no PATH
    echo Instale o Maven e tente novamente
    pause
    exit /b 1
)

echo ✅ Docker, Java e Maven encontrados

echo.
echo [2/8] Executando Análise SAST (Static Application Security Testing)...
echo Executando SpotBugs Security...
mvn clean compile spotbugs:check -Dspotbugs.failOnError=false
if %ERRORLEVEL% neq 0 (
    echo ⚠️ AVISO: SpotBugs encontrou problemas de segurança
)

echo Executando OWASP Dependency Check...
mvn org.owasp:dependency-check-maven:check -DfailBuildOnCVSS=7
if %ERRORLEVEL% neq 0 (
    echo ⚠️ AVISO: Dependency Check encontrou vulnerabilidades
)

echo.
echo [3/8] Iniciando aplicação para testes DAST...
echo Iniciando aplicação Spring Boot em background...
start /B mvn spring-boot:run -Dspring-boot.run.profiles=test

echo Aguardando aplicação inicializar...
timeout /t 90 /nobreak >nul

echo.
echo [4/8] Verificando se aplicação está rodando...
for /L %%i in (1,1,5) do (
    curl -f http://localhost:8082/actuator/health >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo ✅ Aplicação está rodando e pronta para testes DAST
        goto :app_ready
    )
    echo Aguardando aplicação... tentativa %%i/5
    timeout /t 10 /nobreak >nul
)

echo ❌ ERRO: Aplicação não está respondendo após 5 minutos
echo Verifique se a aplicação iniciou corretamente
pause
exit /b 1

:app_ready
echo.
echo [5/8] Executando Dastardly (Burp Suite) para DAST...
echo Baixando e executando Dastardly para varredura rápida...
docker run --rm -v "%cd%":/dastardly/reports ^
  public.ecr.aws/portswigger/dastardly:latest ^
  --url http://host.docker.internal:8082 ^
  --report-file /dastardly/reports/dastardly-report.json ^
  --report-format json

if %ERRORLEVEL% neq 0 (
    echo ⚠️ AVISO: Dastardly encontrou problemas, mas continuando...
)

echo.
echo [6/8] Executando OWASP ZAP Baseline Scan (complementar)...
echo Executando ZAP para análise mais detalhada...
docker run -t --rm -v "%cd%":/zap/wrk/:rw zaproxy/zap-stable zap-baseline.py ^
  -t http://host.docker.internal:8082 ^
  -J zap-baseline-report.json ^
  -x zap-baseline-report.xml ^
  -r zap-baseline-report.html ^
  -I ^
  -j ^
  -z "config api.disablekey=true; config scanner.attackOnStart=true; config view.mode=attack; config connection.dnsTtlSuccessfulQueries=-1"

if %ERRORLEVEL% neq 0 (
    echo ⚠️ AVISO: OWASP ZAP encontrou problemas, mas continuando...
)

echo.
echo [7/8] Executando testes de segurança customizados...
echo Executando script Python de testes customizados...
python scripts/security-tests.py http://localhost:8082

if %ERRORLEVEL% neq 0 (
    echo ⚠️ AVISO: Testes customizados encontraram vulnerabilidades
)

echo.
echo [8/8] Executando análise de APIs com Burp Suite Professional (se disponível)...
if exist "burp-suite-pro.jar" (
    echo Executando Burp Suite Professional para análise avançada...
    java -jar burp-suite-pro.jar --headless --config-file=burp-config.json --scan-target=http://localhost:8082 --report-format=html --report-file=burp-pro-report.html
    if %ERRORLEVEL% neq 0 (
        echo ⚠️ AVISO: Burp Suite Professional encontrou problemas
    )
) else (
    echo ℹ️ Burp Suite Professional não encontrado (burp-suite-pro.jar)
    echo Para usar o Burp Suite Professional, coloque o arquivo JAR na pasta do projeto
)

echo.
echo ========================================
echo Gerando relatório consolidado SAST + DAST...
echo ========================================

echo # Relatório Integrado de Segurança (SAST + DAST) > sast-dast-report.md
echo Data: %date% %time% >> sast-dast-report.md
echo. >> sast-dast-report.md
echo ## Resumo da Análise de Segurança >> sast-dast-report.md
echo. >> sast-dast-report.md

echo ### Análise SAST (Static Application Security Testing) >> sast-dast-report.md
echo. >> sast-dast-report.md

if exist "target\spotbugsXml.xml" (
    echo ✅ SpotBugs Security: SUCESSO >> sast-dast-report.md
    echo - Relatório XML: target\spotbugsXml.xml >> sast-dast-report.md
    echo - **Foco**: Vulnerabilidades no código fonte >> sast-dast-report.md
) else (
    echo ❌ SpotBugs Security: FALHOU >> sast-dast-report.md
)
echo. >> sast-dast-report.md

if exist "target\dependency-check-report.html" (
    echo ✅ OWASP Dependency Check: SUCESSO >> sast-dast-report.md
    echo - Relatório HTML: target\dependency-check-report.html >> sast-dast-report.md
    echo - **Foco**: Vulnerabilidades em dependências >> sast-dast-report.md
) else (
    echo ❌ OWASP Dependency Check: FALHOU >> sast-dast-report.md
)
echo. >> sast-dast-report.md

echo ### Análise DAST (Dynamic Application Security Testing) >> sast-dast-report.md
echo. >> sast-dast-report.md

if exist "dastardly-report.json" (
    echo ✅ Dastardly (Burp Suite): SUCESSO >> sast-dast-report.md
    echo - Relatório JSON: dastardly-report.json >> sast-dast-report.md
    echo - **Foco**: Vulnerabilidades em tempo de execução >> sast-dast-report.md
) else (
    echo ❌ Dastardly (Burp Suite): FALHOU >> sast-dast-report.md
)
echo. >> sast-dast-report.md

if exist "burp-pro-report.html" (
    echo ✅ Burp Suite Professional: SUCESSO >> sast-dast-report.md
    echo - Relatório HTML: burp-pro-report.html >> sast-dast-report.md
    echo - **Foco**: Análise avançada de vulnerabilidades >> sast-dast-report.md
) else (
    echo ℹ️ Burp Suite Professional: Não executado (JAR não encontrado) >> sast-dast-report.md
)
echo. >> sast-dast-report.md

if exist "zap-baseline-report.html" (
    echo ✅ OWASP ZAP Baseline Scan: SUCESSO >> sast-dast-report.md
    echo - Relatório HTML: zap-baseline-report.html >> sast-dast-report.md
    echo - Relatório JSON: zap-baseline-report.json >> sast-dast-report.md
    echo - Relatório XML: zap-baseline-report.xml >> sast-dast-report.md
) else (
    echo ❌ OWASP ZAP Baseline Scan: FALHOU >> sast-dast-report.md
)
echo. >> sast-dast-report.md

if exist "security-tests-report.json" (
    echo ✅ Testes de Segurança Customizados: SUCESSO >> sast-dast-report.md
    echo - Relatório: security-tests-report.json >> sast-dast-report.md
) else (
    echo ❌ Testes de Segurança Customizados: FALHOU >> sast-dast-report.md
)
echo. >> sast-dast-report.md

echo ## Vantagens da Análise Integrada SAST + DAST >> sast-dast-report.md
echo. >> sast-dast-report.md
echo 1. **Cobertura Completa**: SAST analisa código fonte, DAST analisa aplicação em execução >> sast-dast-report.md
echo 2. **Detecção Precoce**: SAST identifica problemas antes do deploy >> sast-dast-report.md
echo 3. **Validação Real**: DAST confirma vulnerabilidades em ambiente real >> sast-dast-report.md
echo 4. **Eficiência**: Burp Suite acelera significativamente os testes DAST >> sast-dast-report.md
echo 5. **Relatórios Consolidados**: Visão unificada de todas as vulnerabilidades >> sast-dast-report.md
echo. >> sast-dast-report.md

echo ## Vulnerabilidades Identificadas >> sast-dast-report.md
echo. >> sast-dast-report.md

echo ### SAST - Vulnerabilidades no Código >> sast-dast-report.md
echo - **SpotBugs**: Verificar target\spotbugsXml.xml para detalhes >> sast-dast-report.md
echo - **Dependencies**: Verificar target\dependency-check-report.html para detalhes >> sast-dast-report.md
echo. >> sast-dast-report.md

echo ### DAST - Vulnerabilidades em Execução >> sast-dast-report.md
echo - **Dastardly**: Verificar dastardly-report.json para detalhes >> sast-dast-report.md
echo - **Burp Pro**: Verificar burp-pro-report.html para detalhes >> sast-dast-report.md
echo - **ZAP**: Verificar zap-baseline-report.json para detalhes >> sast-dast-report.md
echo. >> sast-dast-report.md

echo ## Plano de Ação Prioritário >> sast-dast-report.md
echo. >> sast-dast-report.md
echo 1. **CRÍTICO**: Corrigir vulnerabilidades críticas identificadas pelo SAST >> sast-dast-report.md
echo 2. **ALTA**: Corrigir vulnerabilidades de alta severidade do DAST >> sast-dast-report.md
echo 3. **MÉDIA**: Atualizar dependências vulneráveis >> sast-dast-report.md
echo 4. **BAIXA**: Implementar melhorias de segurança sugeridas >> sast-dast-report.md
echo 5. **CONTÍNUO**: Executar análise integrada em cada deploy >> sast-dast-report.md

echo.
echo ========================================
echo Análise Integrada SAST + DAST Concluída!
echo ========================================
echo.
echo Relatórios gerados:
echo.
echo SAST (Análise Estática):
if exist "target\spotbugsXml.xml" (
    echo - target\spotbugsXml.xml (SpotBugs Security)
) else (
    echo - SpotBugs: Não gerado
)
if exist "target\dependency-check-report.html" (
    echo - target\dependency-check-report.html (OWASP Dependency Check)
) else (
    echo - Dependency Check: Não gerado
)
echo.
echo DAST (Análise Dinâmica):
if exist "dastardly-report.json" (
    echo - dastardly-report.json (Dastardly - Burp Suite)
) else (
    echo - Dastardly: Não gerado
)
if exist "burp-pro-report.html" (
    echo - burp-pro-report.html (Burp Suite Professional)
) else (
    echo - Burp Suite Professional: Não executado
)
if exist "zap-baseline-report.html" (
    echo - zap-baseline-report.html (OWASP ZAP)
) else (
    echo - OWASP ZAP: Não gerado
)
if exist "security-tests-report.json" (
    echo - security-tests-report.json (Testes Customizados)
) else (
    echo - Testes Customizados: Não gerado
)
echo.
echo Relatório Consolidado:
echo - sast-dast-report.md (SAST + DAST Integrado)
echo.

echo Parando aplicação Spring Boot...
taskkill /F /IM java.exe >nul 2>&1

echo.
echo Abrindo relatório consolidado...
start sast-dast-report.md

echo.
echo ✅ Análise integrada SAST + DAST concluída com sucesso!
echo 📄 Verifique os relatórios gerados para uma visão completa de segurança
echo 🚀 A combinação SAST + DAST com Burp Suite oferece cobertura máxima
echo.
echo 💡 Dica: Execute este script regularmente para manter a segurança atualizada
pause
