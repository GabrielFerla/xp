# Configuração de Testes Dinâmicos de Segurança (DAST)

Este documento descreve como configurar e executar testes dinâmicos de segurança (DAST) para a aplicação XP.

## Visão Geral

Os testes DAST (Dynamic Application Security Testing) são executados contra a aplicação em tempo de execução para identificar vulnerabilidades de segurança que só podem ser detectadas quando a aplicação está funcionando.

## Ferramentas Implementadas

### 1. OWASP ZAP (Zed Attack Proxy)
- **Função**: Scanner principal de vulnerabilidades web
- **Capacidades**: Detecção de OWASP Top 10, XSS, SQL Injection, CSRF
- **Relatórios**: HTML, JSON, XML

### 2. Nikto Web Vulnerability Scanner
- **Função**: Scanner especializado em vulnerabilidades web
- **Capacidades**: Detecção de configurações inseguras, arquivos sensíveis
- **Relatórios**: HTML

### 3. SQLMap
- **Função**: Scanner automatizado de SQL Injection
- **Capacidades**: Testes de injeção SQL, exploração de vulnerabilidades
- **Relatórios**: Múltiplos formatos

### 4. Wapiti
- **Função**: Scanner de vulnerabilidades web
- **Capacidades**: XSS, SQL Injection, File Disclosure
- **Relatórios**: HTML

### 5. Testes Customizados
- **Função**: Testes específicos da aplicação XP
- **Capacidades**: Bypass de autenticação, headers de segurança, rate limiting
- **Relatórios**: JSON

## Pré-requisitos

### Para Execução Local
- Java 21+
- Maven 3.6+
- Python 3.8+
- Docker Desktop
- Docker Compose

### Para Execução no Pipeline CI/CD
- GitHub Actions (configurado automaticamente)
- Docker (disponível nos runners)

## Métodos de Execução

### 1. Execução Local (Windows)

```bash
# Execução simples
run-dast-analysis.bat

# Execução com Docker Compose
run-dast-docker.bat
```

### 2. Execução Local (Linux/macOS)

```bash
# Dar permissão de execução
chmod +x run-dast-analysis.sh

# Executar
./run-dast-analysis.sh
```

### 3. Execução com Docker Compose

```bash
# Iniciar todos os serviços
docker-compose -f docker-compose-dast.yml up -d

# Executar varreduras
docker-compose -f docker-compose-dast.yml exec zap zap-baseline.py -t http://xp-app:8080 -r /zap/wrk/report.html

# Parar serviços
docker-compose -f docker-compose-dast.yml down
```

### 4. Execução Manual de Ferramentas

#### OWASP ZAP
```bash
# Execução básica
docker run -t zaproxy/zap-stable zap-baseline.py -t http://localhost:8080

# Execução com relatórios
docker run -t zaproxy/zap-stable zap-baseline.py \
  -t http://localhost:8080 \
  -J report.json \
  -x report.xml \
  -r report.html
```

#### Nikto
```bash
# Execução básica
docker run --rm sullo/nikto -h http://localhost:8080

# Execução com relatório
docker run --rm -v $(pwd):/tmp/reports \
  sullo/nikto -h http://localhost:8080 \
  -output /tmp/reports/nikto-report.html \
  -Format htm
```

#### Testes Customizados
```bash
# Executar testes Python
python3 scripts/security-tests.py http://localhost:8080
```

## Configuração

### 1. Configuração da Aplicação

A aplicação deve estar configurada para aceitar conexões externas:

```properties
# application-test.properties
server.port=8080
server.address=0.0.0.0
```

### 2. Configuração Docker

O arquivo `docker-compose-dast.yml` configura:
- Aplicação XP na porta 8080
- OWASP ZAP na porta 8081
- Volumes para relatórios
- Rede interna para comunicação

### 3. Configuração do Pipeline

O pipeline CI/CD está configurado em `.github/workflows/ci-cd.yml`:
- Execução automática após build
- Inicialização da aplicação
- Execução de todas as ferramentas
- Geração de relatórios consolidados

## Relatórios

### Tipos de Relatórios Gerados

1. **OWASP ZAP**:
   - `zap-baseline-report.html` - Relatório visual
   - `zap-baseline-report.json` - Dados estruturados
   - `zap-baseline-report.xml` - Formato XML

2. **Nikto**:
   - `nikto-report.html` - Relatório de vulnerabilidades

3. **SQLMap**:
   - Relatórios em múltiplos formatos na pasta `sqlmap-reports/`

4. **Wapiti**:
   - `wapiti-report.html` - Relatório de vulnerabilidades

5. **Testes Customizados**:
   - `security-tests-report.json` - Resultados estruturados

6. **Relatório Consolidado**:
   - `dast-report.md` - Resumo de todos os testes

### Interpretação dos Relatórios

#### Severidade de Vulnerabilidades
- **Alta**: Vulnerabilidades críticas que devem ser corrigidas imediatamente
- **Média**: Vulnerabilidades importantes que devem ser corrigidas em breve
- **Baixa**: Vulnerabilidades menores que podem ser corrigidas quando possível
- **Informativa**: Informações úteis para melhorar a segurança

#### Categorias de Vulnerabilidades
- **Autenticação**: Bypass de autenticação, força bruta
- **Autorização**: Controle de acesso inadequado
- **Injeção**: SQL Injection, XSS, Command Injection
- **Configuração**: Headers de segurança, configurações inseguras
- **Exposição de Dados**: Dados sensíveis expostos

## Troubleshooting

### Problemas Comuns

#### 1. Aplicação não inicia
```bash
# Verificar logs
tail -f app.log

# Verificar se a porta está em uso
netstat -an | grep 8080
```

#### 2. Docker não consegue acessar a aplicação
```bash
# Verificar se a aplicação está acessível
curl http://localhost:8080/actuator/health

# Verificar configuração de rede Docker
docker network ls
```

#### 3. Ferramentas não geram relatórios
```bash
# Verificar permissões de escrita
ls -la zap-reports/

# Verificar espaço em disco
df -h
```

### Logs e Debugging

#### Habilitar Logs Detalhados
```bash
# Para OWASP ZAP
docker run -t zaproxy/zap-stable zap-baseline.py \
  -t http://localhost:8080 \
  -v 10

# Para Nikto
docker run --rm sullo/nikto -h http://localhost:8080 -v
```

#### Verificar Status dos Serviços
```bash
# Status dos containers
docker-compose -f docker-compose-dast.yml ps

# Logs dos containers
docker-compose -f docker-compose-dast.yml logs zap
```

## Integração Contínua

### Pipeline CI/CD

O pipeline executa automaticamente:
1. Build da aplicação
2. Inicialização em ambiente de teste
3. Execução de testes DAST
4. Geração de relatórios
5. Upload de artefatos

### Configuração de Notificações

Para receber notificações sobre vulnerabilidades:
1. Configure webhooks no GitHub
2. Integre com Slack/Teams
3. Configure alertas por email

## Melhores Práticas

### 1. Execução Regular
- Execute testes DAST em cada deploy
- Configure execução automática no pipeline
- Monitore tendências de vulnerabilidades

### 2. Análise de Resultados
- Priorize vulnerabilidades de alta severidade
- Documente correções implementadas
- Mantenha histórico de vulnerabilidades

### 3. Configuração de Ambiente
- Use ambiente isolado para testes
- Configure dados de teste apropriados
- Mantenha ferramentas atualizadas

### 4. Segurança dos Relatórios
- Não commite relatórios com dados sensíveis
- Configure retenção apropriada de artefatos
- Limite acesso aos relatórios

## Suporte

Para problemas ou dúvidas:
1. Consulte a documentação das ferramentas
2. Verifique os logs de execução
3. Consulte a documentação do projeto
4. Abra uma issue no repositório

## Atualizações

Para manter as ferramentas atualizadas:
```bash
# Atualizar imagens Docker
docker pull zaproxy/zap-stable
docker pull sullo/nikto
docker pull paoloo/sqlmap
docker pull wapiti-scanner/wapiti

# Atualizar dependências Python
pip install -r requirements.txt
```
