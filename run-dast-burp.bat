@echo off
echo ========================================
echo Executando Análise DAST com Burp Suite
echo ========================================

echo.
echo [1/7] Verificando dependências...

REM Verificar se Docker está instalado
docker --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERRO: Docker não está instalado ou não está no PATH
    echo Instale o Docker Desktop e tente novamente
    pause
    exit /b 1
)

REM Verificar se Java está instalado (necessário para Burp Suite)
java -version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ERRO: Java não está instalado ou não está no PATH
    echo Instale o Java 8+ e tente novamente
    pause
    exit /b 1
)

echo ✅ Docker e Java encontrados

echo.
echo [2/7] Iniciando aplicação para testes...
echo Iniciando aplicação Spring Boot em background...
start /B mvn spring-boot:run -Dspring-boot.run.profiles=test

echo Aguardando aplicação inicializar...
timeout /t 90 /nobreak >nul

echo.
echo [3/7] Verificando se aplicação está rodando...
for /L %%i in (1,1,5) do (
    curl -f http://localhost:8082/actuator/health >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        echo ✅ Aplicação está rodando e pronta para testes
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
echo [4/7] Executando Dastardly (Burp Suite)...
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
echo [5/7] Executando OWASP ZAP Baseline Scan (complementar)...
echo Executando ZAP para análise mais detalhada...
docker run -t --rm -v "%cd%":/zap/wrk/:rw owasp/zap2docker-stable zap-baseline.py ^
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
echo [6/7] Executando testes de segurança customizados...
echo Executando script Python de testes customizados...
python scripts/security-tests.py http://localhost:8082

if %ERRORLEVEL% neq 0 (
    echo ⚠️ AVISO: Testes customizados encontraram vulnerabilidades
)

echo.
echo [7/7] Executando análise de APIs com Burp Suite Professional (se disponível)...
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
echo Gerando relatório consolidado DAST...
echo ========================================

echo # Relatório de Testes Dinâmicos de Segurança (DAST) com Burp Suite > dast-burp-report.md
echo Data: %date% %time% >> dast-burp-report.md
echo. >> dast-burp-report.md
echo ## Resumo dos Testes DAST >> dast-burp-report.md
echo. >> dast-burp-report.md

if exist "dastardly-report.json" (
    echo ✅ Dastardly (Burp Suite): SUCESSO >> dast-burp-report.md
    echo - Relatório JSON: dastardly-report.json >> dast-burp-report.md
    echo - **Vantagem**: Varredura rápida e eficiente do Burp Suite >> dast-burp-report.md
) else (
    echo ❌ Dastardly (Burp Suite): FALHOU >> dast-burp-report.md
)
echo. >> dast-burp-report.md

if exist "burp-pro-report.html" (
    echo ✅ Burp Suite Professional: SUCESSO >> dast-burp-report.md
    echo - Relatório HTML: burp-pro-report.html >> dast-burp-report.md
    echo - **Vantagem**: Análise avançada e detalhada >> dast-burp-report.md
) else (
    echo ℹ️ Burp Suite Professional: Não executado (JAR não encontrado) >> dast-burp-report.md
)
echo. >> dast-burp-report.md

if exist "zap-baseline-report.html" (
    echo ✅ OWASP ZAP Baseline Scan: SUCESSO >> dast-burp-report.md
    echo - Relatório HTML: zap-baseline-report.html >> dast-burp-report.md
    echo - Relatório JSON: zap-baseline-report.json >> dast-burp-report.md
    echo - Relatório XML: zap-baseline-report.xml >> dast-burp-report.md
) else (
    echo ❌ OWASP ZAP Baseline Scan: FALHOU >> dast-burp-report.md
)
echo. >> dast-burp-report.md

if exist "security-tests-report.json" (
    echo ✅ Testes de Segurança Customizados: SUCESSO >> dast-burp-report.md
    echo - Relatório: security-tests-report.json >> dast-burp-report.md
) else (
    echo ❌ Testes de Segurança Customizados: FALHOU >> dast-burp-report.md
)
echo. >> dast-burp-report.md

echo ## Vantagens do Burp Suite >> dast-burp-report.md
echo. >> dast-burp-report.md
echo 1. **Dastardly**: Varredura rápida e gratuita, ideal para CI/CD >> dast-burp-report.md
echo 2. **Burp Suite Professional**: Análise avançada com detecção superior de vulnerabilidades >> dast-burp-report.md
echo 3. **Interface Amigável**: Relatórios mais claros e acionáveis >> dast-burp-report.md
echo 4. **Integração**: Melhor integração com pipelines de desenvolvimento >> dast-burp-report.md
echo. >> dast-burp-report.md

echo ## Vulnerabilidades Identificadas >> dast-burp-report.md
echo. >> dast-burp-report.md

REM Analisar relatório Dastardly se disponível
if exist "dastardly-report.json" (
    echo ### Dastardly (Burp Suite) - Vulnerabilidades: >> dast-burp-report.md
    echo - **Alta**: Verificar relatório JSON para detalhes >> dast-burp-report.md
    echo - **Média**: Verificar relatório JSON para detalhes >> dast-burp-report.md
    echo - **Baixa**: Verificar relatório JSON para detalhes >> dast-burp-report.md
    echo - **Informativa**: Verificar relatório JSON para detalhes >> dast-burp-report.md
)
echo. >> dast-burp-report.md

REM Analisar relatório Burp Pro se disponível
if exist "burp-pro-report.html" (
    echo ### Burp Suite Professional - Vulnerabilidades: >> dast-burp-report.md
    echo - **Crítica**: Verificar relatório HTML para detalhes >> dast-burp-report.md
    echo - **Alta**: Verificar relatório HTML para detalhes >> dast-burp-report.md
    echo - **Média**: Verificar relatório HTML para detalhes >> dast-burp-report.md
    echo - **Baixa**: Verificar relatório HTML para detalhes >> dast-burp-report.md
)
echo. >> dast-burp-report.md

echo ## Recomendações de Mitigação >> dast-burp-report.md
echo. >> dast-burp-report.md
echo 1. **Prioridade Crítica**: Corrigir vulnerabilidades críticas identificadas pelo Burp Suite >> dast-burp-report.md
echo 2. **Prioridade Alta**: Corrigir vulnerabilidades de alta severidade >> dast-burp-report.md
echo 3. **Configuração**: Implementar headers de segurança adicionais >> dast-burp-report.md
echo 4. **Monitoramento**: Configurar alertas para tentativas de ataque >> dast-burp-report.md
echo 5. **Testes Regulares**: Executar testes DAST com Burp Suite em cada deploy >> dast-burp-report.md
echo 6. **Burp Suite Professional**: Considere adquirir licença para análise mais profunda >> dast-burp-report.md

echo.
echo ========================================
echo Análise DAST com Burp Suite Concluída!
echo ========================================
echo.
echo Relatórios gerados:
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
echo - dast-burp-report.md (Consolidado)
echo.

echo Parando aplicação Spring Boot...
taskkill /F /IM java.exe >nul 2>&1

echo.
echo Abrindo relatório consolidado...
start dast-burp-report.md

echo.
echo ✅ Análise DAST com Burp Suite concluída com sucesso!
echo 📄 Verifique os relatórios gerados para detalhes das vulnerabilidades
echo 🚀 O Burp Suite oferece análises mais precisas e relatórios mais claros
pause
