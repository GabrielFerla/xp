@echo off
echo ========================================
echo Executando DAST - OWASP ZAP
echo ========================================
echo.

echo [1/4] Verificando se Docker está instalado...
docker --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ ERRO: Docker não está instalado ou não está no PATH
    echo Instale o Docker Desktop e tente novamente
    pause
    exit /b 1
)

echo ✅ Docker encontrado

echo.
echo [2/4] Verificando se aplicação está rodando...
curl -f http://localhost:8080/actuator/health >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo ❌ ERRO: Aplicação não está respondendo na porta 8080
    echo.
    echo Verifique se a aplicação está rodando:
    echo 1. Execute: mvn spring-boot:run -Dspring-boot.run.profiles=test
    echo 2. Aguarde a aplicação inicializar completamente
    echo 3. Teste manualmente: curl http://localhost:8080/actuator/health
    echo.
    pause
    exit /b 1
)

echo ✅ Aplicação está rodando e respondendo

echo.
echo [3/4] Executando OWASP ZAP Baseline Scan...
echo Executando ZAP para análise de segurança...
docker run -t --rm -v "%cd%":/zap/wrk/:rw zaproxy/zap-stable zap-baseline.py ^
  -t http://host.docker.internal:8080 ^
  -J zap-baseline-report.json ^
  -x zap-baseline-report.xml ^
  -r zap-baseline-report.html ^
  -I

if %ERRORLEVEL% neq 0 (
    echo ⚠️ AVISO: OWASP ZAP encontrou problemas, mas continuando...
)

echo.
echo [4/4] Gerando relatório consolidado DAST...
echo ========================================
echo Gerando relatório consolidado DAST...
echo ========================================

echo # Relatório de Testes Dinâmicos de Segurança (DAST) > dast-report.md
echo Data: %date% %time% >> dast-report.md
echo. >> dast-report.md
echo ## Resumo dos Testes DAST >> dast-report.md
echo. >> dast-report.md

if exist "zap-baseline-report.html" (
    echo ✅ OWASP ZAP Baseline Scan: SUCESSO >> dast-report.md
    echo - Relatório HTML: zap-baseline-report.html >> dast-report.md
    echo - Relatório JSON: zap-baseline-report.json >> dast-report.md
    echo - Relatório XML: zap-baseline-report.xml >> dast-report.md
) else (
    echo ❌ OWASP ZAP Baseline Scan: FALHOU >> dast-report.md
)
echo. >> dast-report.md

echo ## Configuração da Aplicação >> dast-report.md
echo. >> dast-report.md
echo - **Porta**: 8080 (ambiente de teste) >> dast-report.md
echo - **Perfil**: test >> dast-report.md
echo - **Banco**: H2 em memória >> dast-report.md
echo - **SSL**: Desabilitado para testes >> dast-report.md
echo. >> dast-report.md

echo ## Vulnerabilidades Identificadas >> dast-report.md
echo. >> dast-report.md

if exist "zap-baseline-report.json" (
    echo ### OWASP ZAP - Vulnerabilidades por Severidade: >> dast-report.md
    echo - **Alta**: Verificar relatório JSON para detalhes >> dast-report.md
    echo - **Média**: Verificar relatório JSON para detalhes >> dast-report.md
    echo - **Baixa**: Verificar relatório JSON para detalhes >> dast-report.md
    echo - **Informativa**: Verificar relatório JSON para detalhes >> dast-report.md
)
echo. >> dast-report.md

echo ## Recomendações de Mitigação >> dast-report.md
echo. >> dast-report.md
echo 1. **Prioridade Alta**: Corrigir vulnerabilidades de alta severidade identificadas pelo ZAP >> dast-report.md
echo 2. **Prioridade Média**: Revisar e corrigir vulnerabilidades de média severidade >> dast-report.md
echo 3. **Configuração**: Implementar headers de segurança adicionais >> dast-report.md
echo 4. **Monitoramento**: Configurar alertas para tentativas de ataque >> dast-report.md
echo 5. **Testes Regulares**: Executar testes DAST em cada deploy >> dast-report.md

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
echo - dast-report.md (Consolidado)
echo.

echo Abrindo relatório consolidado...
start dast-report.md

echo.
echo ✅ Análise DAST concluída com sucesso!
echo 📄 Verifique os relatórios gerados para detalhes das vulnerabilidades
echo 🔍 Implementação simples com OWASP ZAP
pause
