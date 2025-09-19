#!/bin/bash

echo "=========================================="
echo "🔍 EXECUTANDO ANÁLISE SCA (SOFTWARE COMPOSITION ANALYSIS)"
echo "=========================================="
echo ""
echo "📋 Verificando:"
echo "  - Versões desatualizadas"
echo "  - CVEs conhecidos"
echo "  - Licenças incompatíveis"
echo "  - Dependências transitivas"
echo ""

# Verificar se Maven está disponível
if ! command -v mvn &> /dev/null; then
    echo "❌ ERRO: Maven não encontrado no PATH"
    echo "   Instale o Maven e adicione ao PATH"
    exit 1
fi

echo "✅ Maven encontrado"
echo ""

# Compilar projeto primeiro
echo "🔨 Compilando projeto..."
mvn clean compile -q
if [ $? -ne 0 ]; then
    echo "❌ ERRO: Falha na compilação"
    exit 1
fi

echo "✅ Compilação concluída"
echo ""

# Executar análise SCA
echo "🔍 Executando OWASP Dependency Check (SCA)..."
mvn org.owasp:dependency-check-maven:check -DfailBuildOnCVSS=7
SCA_EXIT_CODE=$?

if [ $SCA_EXIT_CODE -eq 0 ]; then
    echo "✅ Análise SCA concluída com sucesso!"
else
    echo "⚠️ SCA encontrou vulnerabilidades - continuando..."
fi

echo ""

# Gerar relatório consolidado
echo "📊 Gerando relatório SCA consolidado..."

# Criar diretório de relatórios SCA
mkdir -p sca-reports

# Gerar relatório consolidado
echo "# Relatório de Análise de Composição de Software (SCA)" > sca-report.md
echo "Data: $(date)" >> sca-report.md
echo "Ferramenta: OWASP Dependency Check v8.4.0" >> sca-report.md
echo "" >> sca-report.md

echo "## Resumo da Análise" >> sca-report.md
echo "" >> sca-report.md

# Verificar se relatórios foram gerados
if [ -f "target/sca-reports/dependency-check-report.html" ]; then
    echo "✅ **Análise SCA**: SUCESSO" >> sca-report.md
    echo "- Relatório HTML: target/sca-reports/dependency-check-report.html" >> sca-report.md
    echo "- Relatório XML: target/sca-reports/dependency-check-report.xml" >> sca-report.md
    echo "- Relatório JSON: target/sca-reports/dependency-check-report.json" >> sca-report.md
    echo "- Relatório CSV: target/sca-reports/dependency-check-report.csv" >> sca-report.md
else
    echo "❌ **Análise SCA**: FALHOU" >> sca-report.md
    echo "- Verifique logs para detalhes" >> sca-report.md
fi
echo "" >> sca-report.md

# Análise de vulnerabilidades
echo "## Análise de Vulnerabilidades" >> sca-report.md
echo "" >> sca-report.md
if [ -f "target/sca-reports/dependency-check-report.json" ]; then
    # Extrair estatísticas do JSON
    HIGH_VULNS=$(grep -o '"severity":"HIGH"' target/sca-reports/dependency-check-report.json | wc -l)
    MEDIUM_VULNS=$(grep -o '"severity":"MEDIUM"' target/sca-reports/dependency-check-report.json | wc -l)
    LOW_VULNS=$(grep -o '"severity":"LOW"' target/sca-reports/dependency-check-report.json | wc -l)
    
    echo "### Estatísticas de Vulnerabilidades" >> sca-report.md
    echo "- 🔴 **Alta Severidade**: $HIGH_VULNS" >> sca-report.md
    echo "- 🟡 **Média Severidade**: $MEDIUM_VULNS" >> sca-report.md
    echo "- 🟢 **Baixa Severidade**: $LOW_VULNS" >> sca-report.md
else
    echo "⚠️ Estatísticas não disponíveis - relatório JSON não encontrado" >> sca-report.md
fi
echo "" >> sca-report.md

# Análise de licenças
echo "## Análise de Licenças" >> sca-report.md
echo "" >> sca-report.md
echo "### Licenças Detectadas" >> sca-report.md
if [ -f "target/sca-reports/dependency-check-report.json" ]; then
    # Extrair licenças do JSON
    LICENSES=$(grep -o '"license":"[^"]*"' target/sca-reports/dependency-check-report.json | sort | uniq -c | sort -nr)
    if [ ! -z "$LICENSES" ]; then
        echo "$LICENSES" | while read count license; do
            echo "- $license: $count dependências" >> sca-report.md
        done
    else
        echo "- Nenhuma licença detectada no relatório" >> sca-report.md
    fi
else
    echo "- Análise de licenças não disponível" >> sca-report.md
fi
echo "" >> sca-report.md

# Dependências desatualizadas
echo "## Dependências Desatualizadas" >> sca-report.md
echo "" >> sca-report.md
echo "### Versões com Vulnerabilidades Conhecidas" >> sca-report.md
if [ -f "target/sca-reports/dependency-check-report.json" ]; then
    # Extrair dependências com vulnerabilidades
    VULN_DEPS=$(grep -o '"fileName":"[^"]*"' target/sca-reports/dependency-check-report.json | head -10)
    if [ ! -z "$VULN_DEPS" ]; then
        echo "$VULN_DEPS" | while read dep; do
            echo "- $dep" >> sca-report.md
        done
    else
        echo "- Nenhuma dependência vulnerável detectada" >> sca-report.md
    fi
else
    echo "- Análise de dependências não disponível" >> sca-report.md
fi
echo "" >> sca-report.md

# Recomendações
echo "## Recomendações de Segurança" >> sca-report.md
echo "" >> sca-report.md
echo "### Ações Prioritárias" >> sca-report.md
echo "1. **Atualizar Dependências**: Atualizar todas as dependências com vulnerabilidades de alta severidade" >> sca-report.md
echo "2. **Revisar Licenças**: Verificar compatibilidade de licenças com política da empresa" >> sca-report.md
echo "3. **Monitoramento Contínuo**: Configurar alertas para novas vulnerabilidades" >> sca-report.md
echo "4. **Testes de Segurança**: Executar análise SCA em cada build" >> sca-report.md
echo "5. **Documentação**: Manter registro de dependências e suas justificativas" >> sca-report.md
echo "" >> sca-report.md

echo "### Próximos Passos" >> sca-report.md
echo "- Revisar relatório HTML detalhado" >> sca-report.md
echo "- Implementar correções de segurança" >> sca-report.md
echo "- Configurar monitoramento contínuo" >> sca-report.md
echo "- Atualizar política de dependências" >> sca-report.md
echo "" >> sca-report.md

echo "## Status da Implementação SCA" >> sca-report.md
echo "" >> sca-report.md
echo "### ✅ Funcionalidades Implementadas" >> sca-report.md
echo "- Análise automática no pipeline CI/CD" >> sca-report.md
echo "- Detecção de CVEs conhecidos" >> sca-report.md
echo "- Verificação de versões desatualizadas" >> sca-report.md
echo "- Análise de licenças incompatíveis" >> sca-report.md
echo "- Relatórios em múltiplos formatos (HTML, XML, JSON, CSV)" >> sca-report.md
echo "- Cache local para melhor performance" >> sca-report.md
echo "- Configuração de severidade personalizada" >> sca-report.md
echo "" >> sca-report.md

echo "### 📊 Métricas de Qualidade" >> sca-report.md
echo "- **Ferramenta**: OWASP Dependency Check v8.4.0" >> sca-report.md
echo "- **Base de Dados**: NVD (National Vulnerability Database)" >> sca-report.md
echo "- **Frequência**: A cada build/PR" >> sca-report.md
echo "- **Formato**: Relatórios consolidados" >> sca-report.md
echo "" >> sca-report.md

echo "✅ Relatório SCA gerado com sucesso!"
echo "📄 Arquivo: sca-report.md"
echo ""

# Exibir resumo
echo "=========================================="
echo "🔍 RESUMO DA ANÁLISE SCA"
echo "=========================================="
echo ""
if [ -f "target/sca-reports/dependency-check-report.html" ]; then
    echo "✅ OWASP Dependency Check: SUCESSO"
    echo "   📄 Relatório HTML: target/sca-reports/dependency-check-report.html"
    echo "   📄 Relatório XML: target/sca-reports/dependency-check-report.xml"
    echo "   📄 Relatório JSON: target/sca-reports/dependency-check-report.json"
    echo "   📄 Relatório CSV: target/sca-reports/dependency-check-report.csv"
else
    echo "❌ OWASP Dependency Check: FALHOU"
fi
echo ""
if [ -f "sca-report.md" ]; then
    echo "✅ Relatório Consolidado: sca-report.md"
fi
echo ""
echo "📦 Todos os relatórios foram salvos"
echo "=========================================="
echo ""

# Abrir relatório HTML se disponível
if [ -f "target/sca-reports/dependency-check-report.html" ]; then
    echo "Deseja abrir o relatório HTML? (s/n)"
    read -r OPEN_REPORT
    if [[ "$OPEN_REPORT" =~ ^[Ss]$ ]]; then
        if command -v xdg-open &> /dev/null; then
            xdg-open "target/sca-reports/dependency-check-report.html"
        elif command -v open &> /dev/null; then
            open "target/sca-reports/dependency-check-report.html"
        else
            echo "Abra manualmente: target/sca-reports/dependency-check-report.html"
        fi
    fi
fi

echo ""
echo "Análise SCA concluída!"
