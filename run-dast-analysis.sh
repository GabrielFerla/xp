#!/bin/bash

echo "========================================"
echo "Executando Análise DAST (Dynamic Application Security Testing)"
echo "========================================"

echo ""
echo "[1/6] Verificando dependências..."

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ ERRO: Docker não está instalado"
    echo "Instale o Docker e tente novamente"
    exit 1
fi

# Verificar se Python está instalado
if ! command -v python3 &> /dev/null; then
    echo "❌ ERRO: Python3 não está instalado"
    echo "Instale o Python 3.x e tente novamente"
    exit 1
fi

echo "✅ Docker e Python encontrados"

echo ""
echo "[2/6] Iniciando aplicação para testes..."
echo "Iniciando aplicação Spring Boot em background..."
nohup mvn spring-boot:run -Dspring-boot.run.profiles=test > app.log 2>&1 &
APP_PID=$!

echo "Aguardando aplicação inicializar..."
sleep 90

echo ""
echo "[3/6] Verificando se aplicação está rodando..."
for i in {1..30}; do
    if curl -f http://localhost:8080/actuator/health >/dev/null 2>&1; then
        echo "✅ Aplicação está rodando e pronta para testes"
        break
    fi
    echo "Aguardando aplicação... tentativa $i/30"
    sleep 10
done

# Verificar se a aplicação está respondendo
if ! curl -f http://localhost:8080/actuator/health >/dev/null 2>&1; then
    echo "❌ ERRO: Aplicação não está respondendo após 5 minutos"
    echo "Verifique se a aplicação iniciou corretamente"
    kill $APP_PID 2>/dev/null
    exit 1
fi

echo ""
echo "[4/6] Executando OWASP ZAP Baseline Scan..."
echo "Baixando e executando OWASP ZAP..."
docker run -t --rm -v "$(pwd)":/zap/wrk/:rw zaproxy/zap-stable zap-baseline.py \
  -t http://host.docker.internal:8080 \
  -J zap-baseline-report.json \
  -x zap-baseline-report.xml \
  -r zap-baseline-report.html \
  -I \
  -j \
  -z "config api.disablekey=true; config scanner.attackOnStart=true; config view.mode=attack; config connection.dnsTtlSuccessfulQueries=-1"

if [ $? -ne 0 ]; then
    echo "⚠️ AVISO: OWASP ZAP encontrou problemas, mas continuando..."
fi

echo ""
echo "[5/6] Executando Nikto Web Vulnerability Scanner..."
echo "Executando Nikto..."
docker run --rm -v "$(pwd)":/tmp/reports \
  sullo/nikto -h http://host.docker.internal:8080 \
  -output /tmp/reports/nikto-report.html \
  -Format htm \
  -Tuning 1,2,3,4,5,6,7,8,9,0,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z

if [ $? -ne 0 ]; then
    echo "⚠️ AVISO: Nikto encontrou problemas, mas continuando..."
fi

echo ""
echo "[6/6] Executando testes de segurança customizados..."
echo "Executando script Python de testes customizados..."
python3 scripts/security-tests.py http://localhost:8080

if [ $? -ne 0 ]; then
    echo "⚠️ AVISO: Testes customizados encontraram vulnerabilidades"
fi

echo ""
echo "========================================"
echo "Gerando relatório consolidado DAST..."
echo "========================================"

cat > dast-report.md << EOF
# Relatório de Testes Dinâmicos de Segurança (DAST)
Data: $(date)

## Resumo dos Testes DAST

EOF

# Verificar relatórios OWASP ZAP
if [ -f "zap-baseline-report.html" ]; then
    echo "✅ OWASP ZAP Baseline Scan: SUCESSO" >> dast-report.md
    echo "- Relatório HTML: zap-baseline-report.html" >> dast-report.md
    echo "- Relatório JSON: zap-baseline-report.json" >> dast-report.md
    echo "- Relatório XML: zap-baseline-report.xml" >> dast-report.md
else
    echo "❌ OWASP ZAP Baseline Scan: FALHOU" >> dast-report.md
fi
echo "" >> dast-report.md

# Verificar relatórios Nikto
if [ -f "nikto-report.html" ]; then
    echo "✅ Nikto Web Vulnerability Scanner: SUCESSO" >> dast-report.md
    echo "- Relatório: nikto-report.html" >> dast-report.md
else
    echo "❌ Nikto Web Vulnerability Scanner: FALHOU" >> dast-report.md
fi
echo "" >> dast-report.md

# Verificar testes customizados
if [ -f "security-tests-report.json" ]; then
    echo "✅ Testes de Segurança Customizados: SUCESSO" >> dast-report.md
    echo "- Relatório: security-tests-report.json" >> dast-report.md
else
    echo "❌ Testes de Segurança Customizados: FALHOU" >> dast-report.md
fi
echo "" >> dast-report.md

echo "## Vulnerabilidades Identificadas" >> dast-report.md
echo "" >> dast-report.md

# Analisar relatório ZAP JSON se disponível
if [ -f "zap-baseline-report.json" ]; then
    HIGH_COUNT=$(jq '.High' zap-baseline-report.json 2>/dev/null || echo "0")
    MEDIUM_COUNT=$(jq '.Medium' zap-baseline-report.json 2>/dev/null || echo "0")
    LOW_COUNT=$(jq '.Low' zap-baseline-report.json 2>/dev/null || echo "0")
    INFO_COUNT=$(jq '.Informational' zap-baseline-report.json 2>/dev/null || echo "0")
    
    echo "### OWASP ZAP - Vulnerabilidades por Severidade:" >> dast-report.md
    echo "- **Alta**: $HIGH_COUNT" >> dast-report.md
    echo "- **Média**: $MEDIUM_COUNT" >> dast-report.md
    echo "- **Baixa**: $LOW_COUNT" >> dast-report.md
    echo "- **Informativa**: $INFO_COUNT" >> dast-report.md
fi
echo "" >> dast-report.md

cat >> dast-report.md << EOF
## Recomendações de Mitigação

1. **Prioridade Alta**: Corrigir vulnerabilidades de alta severidade identificadas pelo ZAP
2. **Prioridade Média**: Revisar e corrigir vulnerabilidades de média severidade
3. **Configuração**: Implementar headers de segurança adicionais
4. **Monitoramento**: Configurar alertas para tentativas de ataque
5. **Testes Regulares**: Executar testes DAST em cada deploy

EOF

echo ""
echo "========================================"
echo "Análise DAST Concluída!"
echo "========================================"
echo ""
echo "Relatórios gerados:"
if [ -f "zap-baseline-report.html" ]; then
    echo "- zap-baseline-report.html (OWASP ZAP)"
else
    echo "- OWASP ZAP: Não gerado"
fi
if [ -f "nikto-report.html" ]; then
    echo "- nikto-report.html (Nikto)"
else
    echo "- Nikto: Não gerado"
fi
if [ -f "security-tests-report.json" ]; then
    echo "- security-tests-report.json (Testes Customizados)"
else
    echo "- Testes Customizados: Não gerado"
fi
echo "- dast-report.md (Consolidado)"
echo ""

echo "Parando aplicação Spring Boot..."
kill $APP_PID 2>/dev/null

echo ""
echo "Abrindo relatório consolidado..."
if command -v xdg-open &> /dev/null; then
    xdg-open dast-report.md
elif command -v open &> /dev/null; then
    open dast-report.md
else
    echo "Abra manualmente o arquivo dast-report.md"
fi

echo ""
echo "✅ Análise DAST concluída com sucesso!"
echo "📄 Verifique os relatórios gerados para detalhes das vulnerabilidades"
