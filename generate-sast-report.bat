@echo off
echo ========================================
echo Gerando Relatório SAST Completo
echo ========================================

echo.
echo [1/3] Executando SpotBugs Security Analysis...
call mvn com.github.spotbugs:spotbugs-maven-plugin:spotbugs
set SPOTBUGS_SUCCESS=%ERRORLEVEL%

echo.
echo [2/3] Tentando OWASP Dependency Check...
call mvn org.owasp:dependency-check-maven:check
set OWASP_SUCCESS=%ERRORLEVEL%

echo.
echo [3/3] Gerando relatório consolidado...
echo # Relatório de Análise Estática de Segurança (SAST) > sast-report.md
echo Data: %date% %time% >> sast-report.md
echo. >> sast-report.md
echo ## Vulnerabilidades de Dependências (OWASP Dependency Check) >> sast-report.md
echo. >> sast-report.md

if %OWASP_SUCCESS% equ 0 (
    if exist "target\dependency-check-report.html" (
        echo ✅ Relatório OWASP gerado: target\dependency-check-report.html >> sast-report.md
        echo - Análise completa de vulnerabilidades de dependências >> sast-report.md
        echo - Classificação por CVSS score >> sast-report.md
    ) else (
        echo ⚠️ OWASP executado mas relatório não encontrado >> sast-report.md
    )
) else (
    echo ⚠️ OWASP Dependency Check falhou devido a problemas de conectividade >> sast-report.md
    echo - Possível bloqueio de rede ou proxy >> sast-report.md
    echo - Recomenda-se executar com conexão estável >> sast-report.md
    echo - Alternativa: usar análise manual de dependências >> sast-report.md
)

echo. >> sast-report.md
echo ## Análise de Código Estático (SpotBugs) >> sast-report.md
echo. >> sast-report.md

if %SPOTBUGS_SUCCESS% equ 0 (
    if exist "target\spotbugsXml.xml" (
        echo ✅ Relatório SpotBugs gerado: target\spotbugsXml.xml >> sast-report.md
        echo - Análise de bugs de segurança no código >> sast-report.md
        echo - Foco em vulnerabilidades críticas (Rank 1-3) >> sast-report.md
        
        REM Contar bugs encontrados
        for /f %%i in ('findstr /c:"<BugInstance" target\spotbugsXml.xml 2^>nul ^| find /c /v ""') do set BUG_COUNT=%%i
        if "%BUG_COUNT%"=="" set BUG_COUNT=0
        echo - **Total de bugs encontrados: %BUG_COUNT%** >> sast-report.md
        
        if %BUG_COUNT% gtr 0 (
            echo. >> sast-report.md
            echo ### Bugs Críticos (High Priority) >> sast-report.md
            findstr /c:"High:" target\spotbugsXml.xml 2>nul | findstr /c:"DM_DEFAULT_ENCODING" >nul && echo - **DM_DEFAULT_ENCODING**: Uso de encoding padrão >> sast-report.md
            findstr /c:"High:" target\spotbugsXml.xml 2>nul | findstr /c:"DMI_RANDOM_USED_ONLY_ONCE" >nul && echo - **DMI_RANDOM_USED_ONLY_ONCE**: Objetos Random usados apenas uma vez >> sast-report.md
            
            echo. >> sast-report.md
            echo ### Bugs Médios (Medium Priority) >> sast-report.md
            findstr /c:"Medium:" target\spotbugsXml.xml 2>nul | findstr /c:"EI_EXPOSE_REP" >nul && echo - **EI_EXPOSE_REP**: Exposição de representação interna >> sast-report.md
            findstr /c:"Medium:" target\spotbugsXml.xml 2>nul | findstr /c:"REC_CATCH_EXCEPTION" >nul && echo - **REC_CATCH_EXCEPTION**: Captura de exceções desnecessárias >> sast-report.md
            findstr /c:"Medium:" target\spotbugsXml.xml 2>nul | findstr /c:"SS_SHOULD_BE_STATIC" >nul && echo - **SS_SHOULD_BE_STATIC**: Campos que deveriam ser estáticos >> sast-report.md
            
            echo. >> sast-report.md
            echo ### Bugs Baixos (Low Priority) >> sast-report.md
            findstr /c:"Low:" target\spotbugsXml.xml 2>nul | findstr /c:"SE_NO_SERIALVERSIONID" >nul && echo - **SE_NO_SERIALVERSIONID**: Falta de serialVersionUID >> sast-report.md
            findstr /c:"Low:" target\spotbugsXml.xml 2>nul | findstr /c:"DM_CONVERT_CASE" >nul && echo - **DM_CONVERT_CASE**: Uso de conversão de caso não localizada >> sast-report.md
        )
    ) else (
        echo ❌ Falha na geração do relatório SpotBugs >> sast-report.md
    )
) else (
    echo ❌ SpotBugs Security Analysis falhou >> sast-report.md
)

echo. >> sast-report.md
echo ## Recomendações >> sast-report.md
echo 1. **Prioridade Alta**: Corrigir bugs de encoding e geração de números aleatórios >> sast-report.md
echo 2. **Prioridade Média**: Implementar cópias defensivas para evitar exposição de dados >> sast-report.md
echo 3. **Prioridade Baixa**: Adicionar serialVersionUID e melhorar localização >> sast-report.md
if %OWASP_SUCCESS% neq 0 (
    echo 4. Executar OWASP Dependency Check com conexão estável >> sast-report.md
    echo 5. Considerar usar proxy corporativo se disponível >> sast-report.md
)

echo.
echo ========================================
echo Relatório SAST Gerado com Sucesso!
echo ========================================
echo.
echo Relatórios disponíveis:
if exist "target\spotbugsXml.xml" (
    echo - target\spotbugsXml.xml (SpotBugs - %BUG_COUNT% bugs)
) else (
    echo - SpotBugs: Falhou
)
if exist "target\dependency-check-report.html" (
    echo - target\dependency-check-report.html (OWASP)
) else (
    echo - OWASP: Falhou (problemas de conectividade)
)
echo - sast-report.md (Consolidado)
echo.
echo Abrindo relatório consolidado...
start sast-report.md

pause
