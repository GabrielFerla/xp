#!/bin/bash

echo "========================================"
echo "Executando Análise SAST Local"
echo "========================================"

echo ""
echo "[1/3] Executando OWASP Dependency Check..."
mvn org.owasp:dependency-check-maven:check
if [ $? -ne 0 ]; then
    echo "ERRO: Falha na análise OWASP Dependency Check"
    exit 1
fi

echo ""
echo "[2/3] Executando SpotBugs Security Analysis..."
mvn com.github.spotbugs:spotbugs-maven-plugin:check
if [ $? -ne 0 ]; then
    echo "ERRO: Falha na análise SpotBugs"
    exit 1
fi

echo ""
echo "[3/3] Gerando relatório consolidado..."
cat > sast-report.md << EOF
# Relatório de Análise Estática de Segurança (SAST)
Data: $(date)

## Vulnerabilidades de Dependências (OWASP Dependency Check)

EOF

if [ -f "target/dependency-check-report.html" ]; then
    echo "✅ Relatório OWASP gerado: target/dependency-check-report.html" >> sast-report.md
else
    echo "❌ Falha na geração do relatório OWASP" >> sast-report.md
fi

cat >> sast-report.md << EOF

## Análise de Código Estático (SpotBugs)

EOF

if [ -f "target/spotbugsXml.xml" ]; then
    echo "✅ Relatório SpotBugs gerado: target/spotbugsXml.xml" >> sast-report.md
else
    echo "❌ Falha na geração do relatório SpotBugs" >> sast-report.md
fi

cat >> sast-report.md << EOF

## Recomendações
1. Revisar vulnerabilidades de dependências com CVSS >= 7.0
2. Corrigir bugs de segurança identificados pelo SpotBugs
3. Atualizar dependências com vulnerabilidades conhecidas
EOF

echo ""
echo "========================================"
echo "Análise SAST Concluída!"
echo "========================================"
echo ""
echo "Relatórios gerados:"
echo "- target/dependency-check-report.html (OWASP)"
echo "- target/spotbugsXml.xml (SpotBugs)"
echo "- sast-report.md (Consolidado)"
echo ""
echo "Abrindo relatório consolidado..."
if command -v xdg-open > /dev/null; then
    xdg-open sast-report.md
elif command -v open > /dev/null; then
    open sast-report.md
else
    echo "Abra manualmente o arquivo sast-report.md"
fi
