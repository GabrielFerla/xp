# Configuração do Burp Suite para Testes DAST

Este documento explica como configurar e usar o Burp Suite para testes de segurança dinâmicos (DAST) no projeto XP.

## 🚀 Vantagens do Burp Suite

### Dastardly (Gratuito)
- **Varredura rápida**: Completada em menos de 10 minutos
- **Integração CI/CD**: Perfeito para pipelines automatizados
- **Detecção precisa**: Baseado na tecnologia do Burp Suite
- **Relatórios claros**: JSON estruturado e fácil de processar

### Burp Suite Professional
- **Análise avançada**: Detecção superior de vulnerabilidades
- **Interface gráfica**: Análise manual e automatizada
- **Extensões**: Plugins para funcionalidades específicas
- **Relatórios detalhados**: HTML rico com evidências

## 📋 Pré-requisitos

### Obrigatórios
- Docker Desktop instalado
- Java 8+ (para Burp Suite Professional)
- Maven (para build da aplicação)

### Opcionais
- Burp Suite Professional (licença comercial)
- Python 3.x (para testes customizados)

## 🛠️ Configuração

### 1. Dastardly (Gratuito)

O Dastardly já está configurado nos scripts fornecidos:

```bash
# Executar teste completo com Dastardly
run-dast-burp.bat

# Ou via Docker Compose
run-burp-docker.bat
```

### 2. Burp Suite Professional

Para usar o Burp Suite Professional:

1. **Adquira uma licença** em [portswigger.net](https://portswigger.net/burp)
2. **Baixe o JAR** do Burp Suite Professional
3. **Coloque o arquivo** `burp-suite-pro.jar` na pasta do projeto
4. **Execute o script** `run-dast-burp.bat`

## 📊 Comparação de Ferramentas

| Ferramenta | Velocidade | Precisão | Custo | Integração CI/CD |
|------------|------------|----------|-------|------------------|
| Dastardly | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Gratuito | ⭐⭐⭐⭐⭐ |
| Burp Suite Pro | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Pago | ⭐⭐⭐⭐ |
| OWASP ZAP | ⭐⭐⭐ | ⭐⭐⭐ | Gratuito | ⭐⭐⭐ |
| Nikto | ⭐⭐⭐⭐ | ⭐⭐ | Gratuito | ⭐⭐⭐ |

## 🔧 Scripts Disponíveis

### `run-dast-burp.bat`
Script principal que executa:
- Dastardly (Burp Suite gratuito)
- OWASP ZAP (complementar)
- Burp Suite Professional (se disponível)
- Testes customizados Python

### `run-burp-docker.bat`
Executa todos os testes via Docker Compose:
- Aplicação XP
- Dastardly
- OWASP ZAP
- Nikto
- SQLMap
- Wapiti

### `docker-compose-burp.yml`
Configuração Docker para ambiente completo de testes.

## 📈 Relatórios Gerados

### Dastardly
- **Formato**: JSON
- **Arquivo**: `dastardly-report.json`
- **Conteúdo**: Vulnerabilidades com severidade e evidências

### Burp Suite Professional
- **Formato**: HTML
- **Arquivo**: `burp-pro-report.html`
- **Conteúdo**: Relatório detalhado com screenshots e evidências

### Consolidado
- **Formato**: Markdown
- **Arquivo**: `dast-burp-report.md`
- **Conteúdo**: Resumo de todos os testes executados

## 🎯 Tipos de Vulnerabilidades Detectadas

### Dastardly
- SQL Injection
- Cross-Site Scripting (XSS)
- Cross-Site Request Forgery (CSRF)
- Insecure Direct Object References
- Security Misconfiguration
- Sensitive Data Exposure

### Burp Suite Professional
- Todas as vulnerabilidades do Dastardly
- Business Logic Flaws
- Authentication Bypass
- Authorization Issues
- Session Management Problems
- Cryptographic Issues

## 🔄 Integração com CI/CD

### GitHub Actions
```yaml
- name: Run DAST with Dastardly
  run: |
    docker run --rm -v ${{ github.workspace }}:/dastardly/reports \
      public.ecr.aws/portswigger/dastardly:latest \
      --url http://localhost:8080 \
      --report-file /dastardly/reports/dastardly-report.json
```

### Jenkins
```groovy
pipeline {
    agent any
    stages {
        stage('DAST') {
            steps {
                sh 'run-dast-burp.bat'
            }
        }
    }
}
```

## 📝 Configuração Avançada

### `burp-config.json`
Arquivo de configuração para Burp Suite Professional:
- Escopo de teste
- Configurações de crawl
- Configurações de auditoria
- Configurações de performance

### Personalização
Você pode modificar o arquivo `burp-config.json` para:
- Alterar profundidade de crawl
- Configurar autenticação
- Definir timeouts
- Configurar proxy

## 🚨 Troubleshooting

### Problemas Comuns

1. **Docker não encontrado**
   - Instale o Docker Desktop
   - Verifique se está rodando

2. **Java não encontrado**
   - Instale Java 8+
   - Verifique variável PATH

3. **Aplicação não responde**
   - Verifique se a porta 8082 está livre
   - Aguarde mais tempo para inicialização

4. **Burp Suite Professional não executa**
   - Verifique se o JAR está na pasta correta
   - Verifique se a licença é válida

### Logs
Para debug, verifique os logs:
```bash
# Logs do Docker Compose
docker-compose -f docker-compose-burp.yml logs -f

# Logs da aplicação
mvn spring-boot:run -Dspring-boot.run.profiles=test
```

## 📚 Recursos Adicionais

- [Documentação Dastardly](https://portswigger.net/burp/dastardly)
- [Burp Suite Professional](https://portswigger.net/burp/pro)
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/)
- [Burp Suite Extensions](https://portswigger.net/burp/extensions)

## 🎉 Conclusão

O Burp Suite oferece uma solução superior para testes DAST, combinando:
- **Facilidade de uso** com Dastardly
- **Precisão avançada** com Burp Suite Professional
- **Integração perfeita** com pipelines de CI/CD
- **Relatórios claros** e acionáveis

Recomendamos usar o Dastardly para testes regulares e o Burp Suite Professional para análises mais profundas e testes manuais.
