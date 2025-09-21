# Implementação SCA (Software Composition Analysis)

## 📋 Visão Geral

Este documento descreve a implementação completa do SCA (Software Composition Analysis) usando OWASP Dependency-Check no projeto XP Application.

## 🎯 Objetivos da Task 3

- ✅ **Versões desatualizadas**: Detectar dependências com versões antigas
- ✅ **CVEs conhecidos**: Identificar vulnerabilidades conhecidas
- ✅ **Licenças incompatíveis**: Verificar compatibilidade de licenças
- ✅ **Análise automática**: Executar no pipeline CI/CD

## 🔧 Ferramenta Utilizada

**OWASP Dependency-Check v8.4.0**
- ✅ Gratuito e open-source
- ✅ Base de dados NVD (National Vulnerability Database)
- ✅ Análise de licenças
- ✅ Relatórios em múltiplos formatos
- ✅ Integração com Maven

## 📁 Arquivos de Configuração

### 1. `pom.xml`
```xml
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>8.4.0</version>
    <configuration>
        <failBuildOnCVSS>7</failBuildOnCVSS>
        <enableLicenseAnalysis>true</enableLicenseAnalysis>
        <format>ALL</format>
        <outputDirectory>${project.build.directory}/sca-reports</outputDirectory>
    </configuration>
</plugin>
```

### 2. `dependency-check.properties`
- Configurações de timeout e retry
- Análise de licenças habilitada
- Configurações de cache local
- Análise de dependências transitivas

### 3. `owasp-suppression.xml`
- Supressão de falsos positivos
- Configuração de dependências seguras conhecidas

## 🚀 Pipeline CI/CD

### Etapa SCA no GitHub Actions
```yaml
sca:
  runs-on: ubuntu-latest
  needs: test
  
  steps:
  - name: Run SCA Analysis
    run: mvn org.owasp:dependency-check-maven:check
    
  - name: Generate SCA Report
    run: |
      # Gera relatório consolidado
      # Extrai estatísticas de vulnerabilidades
      # Analisa licenças detectadas
```

## 📊 Relatórios Gerados

### Formatos Disponíveis
- **HTML**: `target/sca-reports/dependency-check-report.html`
- **XML**: `target/sca-reports/dependency-check-report.xml`
- **JSON**: `target/sca-reports/dependency-check-report.json`
- **CSV**: `target/sca-reports/dependency-check-report.csv`
- **Markdown**: `sca-report.md` (consolidado)

### Conteúdo dos Relatórios
1. **Resumo da Análise**
   - Status da execução
   - Localização dos relatórios

2. **Análise de Vulnerabilidades**
   - Estatísticas por severidade (Alta/Média/Baixa)
   - Lista de CVEs encontrados

3. **Análise de Licenças**
   - Licenças detectadas
   - Contagem por tipo de licença

4. **Dependências Desatualizadas**
   - Versões com vulnerabilidades conhecidas
   - Sugestões de atualização

5. **Recomendações de Segurança**
   - Ações prioritárias
   - Próximos passos

## 🛠️ Scripts de Execução

### Windows
```bash
run-sca-analysis.bat
```

### Linux/macOS
```bash
./run-sca-analysis.sh
```

### Maven Direto
```bash
mvn org.owasp:dependency-check-maven:check
```

## 📈 Métricas de Qualidade

### Funcionalidades Implementadas
- ✅ Análise automática no pipeline CI/CD
- ✅ Detecção de CVEs conhecidos
- ✅ Verificação de versões desatualizadas
- ✅ Análise de licenças incompatíveis
- ✅ Relatórios em múltiplos formatos
- ✅ Cache local para melhor performance
- ✅ Configuração de severidade personalizada

### Configurações de Segurança
- **CVSS Threshold**: 7.0 (falha apenas em vulnerabilidades críticas)
- **Cache**: 24 horas para dados NVD
- **Timeout**: 30 segundos para conexões
- **Retry**: 3 tentativas com delay de 5 segundos

## 🔍 Análise de Dependências

### Dependências Analisadas
- **Spring Boot**: 3.4.5
- **Apache Camel**: 4.4.0
- **MySQL Connector**: 8.0.33
- **JWT**: 0.11.5
- **SpringDoc**: 2.8.9
- **H2 Database**: Runtime
- **Lombok**: Optional

### Tipos de Análise
1. **Dependências Diretas**: Declaradas no pom.xml
2. **Dependências Transitivas**: Dependências de dependências
3. **Dependências de Teste**: Apenas para testes
4. **Dependências de Runtime**: Para execução

## 🚨 Alertas e Notificações

### Severidades Configuradas
- **🔴 Alta (CVSS 7.0+)**: Falha no build
- **🟡 Média (CVSS 4.0-6.9)**: Aviso no relatório
- **🟢 Baixa (CVSS 0.1-3.9)**: Informativo

### Ações Automáticas
- Build falha apenas para vulnerabilidades críticas
- Relatórios são salvos como artefatos
- Cache é mantido entre execuções

## 📋 Checklist de Implementação

### ✅ Configuração Básica
- [x] Plugin Maven configurado
- [x] Arquivo de propriedades criado
- [x] Supressões configuradas
- [x] Pipeline CI/CD atualizado

### ✅ Análise Avançada
- [x] Análise de licenças habilitada
- [x] Dependências transitivas incluídas
- [x] Múltiplos formatos de relatório
- [x] Cache local configurado

### ✅ Scripts e Automação
- [x] Script Windows criado
- [x] Script Linux criado
- [x] Relatório consolidado
- [x] Estatísticas automáticas

### ✅ Documentação
- [x] Documentação técnica
- [x] Exemplos de uso
- [x] Troubleshooting
- [x] Métricas de qualidade

## 🔧 Troubleshooting

### Problemas Comuns

#### 1. Falha de Conectividade
```bash
# Verificar configurações de proxy
# Aumentar timeout
# Usar cache local
```

#### 2. Falsos Positivos
```xml
<!-- Adicionar ao owasp-suppression.xml -->
<suppress>
    <notes>Justificativa para supressão</notes>
    <cve>CVE-XXXX-XXXX</cve>
    <gav>groupId:artifactId:version</gav>
</suppress>
```

#### 3. Performance Lenta
```properties
# Usar cache local
dataDirectory=.dependency-check
cveValidForHours=24

# Configurar timeout
connectionTimeout=30000
readTimeout=30000
```

## 📚 Recursos Adicionais

### Links Úteis
- [OWASP Dependency Check](https://owasp.org/www-project-dependency-check/)
- [NVD Database](https://nvd.nist.gov/)
- [Maven Plugin Documentation](https://jeremylong.github.io/DependencyCheck/dependency-check-maven/)

### Comandos Úteis
```bash
# Limpar cache
rm -rf .dependency-check

# Executar apenas análise
mvn org.owasp:dependency-check-maven:check

# Verificar versão
mvn org.owasp:dependency-check-maven:help
```
