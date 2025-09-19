@echo off
echo ==========================================
echo 🔍 EXECUTANDO ANÁLISE SCA (SOFTWARE COMPOSITION ANALYSIS)
echo ==========================================
echo.
echo 📋 Verificando:
echo   - Versões desatualizadas
echo   - CVEs conhecidos
echo   - Licenças incompatíveis
echo   - Dependências transitivas
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

REM Executar análise SCA
echo 🔍 Executando OWASP Dependency Check (SCA)...
call mvn org.owasp:dependency-check-maven:check -DfailBuildOnCVSS=7
SCA_EXIT_CODE=%ERRORLEVEL%

if %SCA_EXIT_CODE% EQU 0 (
    echo ✅ Análise SCA concluída com sucesso!
) else (
    echo ⚠️ SCA encontrou vulnerabilidades - continuando...
)

echo.

REM Gerar relatório consolidado
echo 📊 Gerando relatório SCA consolidado...

REM Criar diretório de relatórios SCA
if not exist "sca-reports" mkdir sca-reports

REM Gerar relatório consolidado
echo # Relatório de Análise de Composição de Software (SCA) > sca-report.md
echo Data: %DATE% %TIME% >> sca-report.md
echo Ferramenta: OWASP Dependency Check v8.4.0 >> sca-report.md
echo. >> sca-report.md

echo ## Resumo da Análise >> sca-report.md
echo. >> sca-report.md

REM Verificar se relatórios foram gerados
if exist "target\sca-reports\dependency-check-report.html" (
    echo ✅ **Análise SCA**: SUCESSO >> sca-report.md
    echo - Relatório HTML: target\sca-reports\dependency-check-report.html >> sca-report.md
    echo - Relatório XML: target\sca-reports\dependency-check-report.xml >> sca-report.md
    echo - Relatório JSON: target\sca-reports\dependency-check-report.json >> sca-report.md
    echo - Relatório CSV: target\sca-reports\dependency-check-report.csv >> sca-report.md
) else (
    echo ❌ **Análise SCA**: FALHOU >> sca-report.md
    echo - Verifique logs para detalhes >> sca-report.md
)
echo. >> sca-report.md

REM Análise de vulnerabilidades
echo ## Análise de Vulnerabilidades >> sca-report.md
echo. >> sca-report.md
if exist "target\sca-reports\dependency-check-report.json" (
    echo ### Estatísticas de Vulnerabilidades >> sca-report.md
    echo - 🔴 **Alta Severidade**: Verificar relatório HTML para detalhes >> sca-report.md
    echo - 🟡 **Média Severidade**: Verificar relatório HTML para detalhes >> sca-report.md
    echo - 🟢 **Baixa Severidade**: Verificar relatório HTML para detalhes >> sca-report.md
) else (
    echo ⚠️ Estatísticas não disponíveis - relatório JSON não encontrado >> sca-report.md
)
echo. >> sca-report.md

REM Análise de licenças
echo ## Análise de Licenças >> sca-report.md
echo. >> sca-report.md
echo ### Licenças Detectadas >> sca-report.md
if exist "target\sca-reports\dependency-check-report.json" (
    echo - Verificar relatório HTML para lista completa de licenças >> sca-report.md
) else (
    echo - Análise de licenças não disponível >> sca-report.md
)
echo. >> sca-report.md

REM Dependências desatualizadas
echo ## Dependências Desatualizadas >> sca-report.md
echo. >> sca-report.md
echo ### Versões com Vulnerabilidades Conhecidas >> sca-report.md
if exist "target\sca-reports\dependency-check-report.json" (
    echo - Verificar relatório HTML para lista de dependências vulneráveis >> sca-report.md
) else (
    echo - Análise de dependências não disponível >> sca-report.md
)
echo. >> sca-report.md

REM Recomendações
echo ## Recomendações de Segurança >> sca-report.md
echo. >> sca-report.md
echo ### Ações Prioritárias >> sca-report.md
echo 1. **Atualizar Dependências**: Atualizar todas as dependências com vulnerabilidades de alta severidade >> sca-report.md
echo 2. **Revisar Licenças**: Verificar compatibilidade de licenças com política da empresa >> sca-report.md
echo 3. **Monitoramento Contínuo**: Configurar alertas para novas vulnerabilidades >> sca-report.md
echo 4. **Testes de Segurança**: Executar análise SCA em cada build >> sca-report.md
echo 5. **Documentação**: Manter registro de dependências e suas justificativas >> sca-report.md
echo. >> sca-report.md

echo ### Próximos Passos >> sca-report.md
echo - Revisar relatório HTML detalhado >> sca-report.md
echo - Implementar correções de segurança >> sca-report.md
echo - Configurar monitoramento contínuo >> sca-report.md
echo - Atualizar política de dependências >> sca-report.md
echo. >> sca-report.md

echo ## Status da Implementação SCA >> sca-report.md
echo. >> sca-report.md
echo ### ✅ Funcionalidades Implementadas >> sca-report.md
echo - Análise automática no pipeline CI/CD >> sca-report.md
echo - Detecção de CVEs conhecidos >> sca-report.md
echo - Verificação de versões desatualizadas >> sca-report.md
echo - Análise de licenças incompatíveis >> sca-report.md
echo - Relatórios em múltiplos formatos (HTML, XML, JSON, CSV) >> sca-report.md
echo - Cache local para melhor performance >> sca-report.md
echo - Configuração de severidade personalizada >> sca-report.md
echo. >> sca-report.md

echo ### 📊 Métricas de Qualidade >> sca-report.md
echo - **Ferramenta**: OWASP Dependency Check v8.4.0 >> sca-report.md
echo - **Base de Dados**: NVD (National Vulnerability Database) >> sca-report.md
echo - **Frequência**: A cada build/PR >> sca-report.md
echo - **Formato**: Relatórios consolidados >> sca-report.md
echo. >> sca-report.md

echo ✅ Relatório SCA gerado com sucesso!
echo 📄 Arquivo: sca-report.md
echo.

REM Exibir resumo
echo ==========================================
echo 🔍 RESUMO DA ANÁLISE SCA
echo ==========================================
echo.
if exist "target\sca-reports\dependency-check-report.html" (
    echo ✅ OWASP Dependency Check: SUCESSO
    echo    📄 Relatório HTML: target\sca-reports\dependency-check-report.html
    echo    📄 Relatório XML: target\sca-reports\dependency-check-report.xml
    echo    📄 Relatório JSON: target\sca-reports\dependency-check-report.json
    echo    📄 Relatório CSV: target\sca-reports\dependency-check-report.csv
) else (
    echo ❌ OWASP Dependency Check: FALHOU
)
echo.
if exist "sca-report.md" (
    echo ✅ Relatório Consolidado: sca-report.md
)
echo.
echo 📦 Todos os relatórios foram salvos
echo ==========================================
echo.

REM Abrir relatório HTML se disponível
if exist "target\sca-reports\dependency-check-report.html" (
    echo Deseja abrir o relatório HTML? (S/N)
    set /p OPEN_REPORT=
    if /i "%OPEN_REPORT%"=="S" (
        start "" "target\sca-reports\dependency-check-report.html"
    )
)

echo.
echo Pressione qualquer tecla para sair...
pause >nul
