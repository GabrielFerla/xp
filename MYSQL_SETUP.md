# 🗄️ MySQL Setup - Projeto XP

## 📋 Visão Geral

Este documento explica como configurar e executar o projeto XP com MySQL como banco de dados, mantendo total compatibilidade com o H2 existente.

## 🚀 Configuração Rápida

### Opção 1: Script Automatizado (Recomendado)

#### Linux/macOS:
```bash
chmod +x run-with-mysql.sh
./run-with-mysql.sh
```

#### Windows:
```cmd
run-with-mysql.bat
```

### Opção 2: Configuração Manual

#### 1. Iniciar MySQL com Docker
```bash
docker-compose -f docker-compose-mysql.yml up -d
```

#### 2. Executar a aplicação
```bash
# MySQL Development
./mvnw spring-boot:run -Dspring-boot.run.profiles=mysql

# MySQL Production
./mvnw spring-boot:run -Dspring-boot.run.profiles=prod

# H2 (padrão)
./mvnw spring-boot:run
```

## 🐳 Docker Compose

### Serviços Disponíveis

| Serviço | Porta | Descrição |
|---------|-------|-----------|
| MySQL | 3306 | Banco de dados principal |
| phpMyAdmin | 8081 | Interface web para MySQL |

### Comandos Docker

```bash
# Iniciar todos os serviços
docker-compose -f docker-compose-mysql.yml up -d

# Ver logs
docker-compose -f docker-compose-mysql.yml logs -f

# Parar serviços
docker-compose -f docker-compose-mysql.yml down

# Parar e remover volumes
docker-compose -f docker-compose-mysql.yml down -v
```

## 🔧 Configurações por Ambiente

### Desenvolvimento (application-mysql.properties)
- **Banco**: MySQL local
- **Porta**: 3306
- **Database**: xpdb
- **Usuário**: xp_user
- **Senha**: xp_password
- **SSL**: Desabilitado
- **Logs**: Detalhados

### Produção (application-prod.properties)
- **Banco**: MySQL configurável via variáveis de ambiente
- **SSL**: Obrigatório
- **Logs**: Otimizados
- **Pool de Conexões**: Configurado para alta performance
- **Swagger**: Desabilitado

### Teste (application-test.properties)
- **Banco**: H2 em memória
- **SSL**: Desabilitado
- **Logs**: Mínimos

## 📊 Estrutura do Banco MySQL

### Tabelas Principais
```sql
-- Usuários do sistema
users (id, username, password, email, role, enabled, ...)

-- Catálogo de produtos
products (id, name, description, price, stock, ...)

-- Dados dos clientes
customers (id, first_name, last_name, email, phone, address, ...)

-- Log de auditoria
audit_log (id, event_type, username, ip_address, details, timestamp, ...)

-- Eventos de segurança
security_event (id, event_type, severity, description, ip_address, ...)

-- Requisições LGPD
lgpd_request (id, user_id, request_type, status, requestor_email, ...)
```

### Características MySQL
- **Engine**: InnoDB
- **Charset**: utf8mb4
- **Collation**: utf8mb4_unicode_ci
- **Índices**: Otimizados para performance
- **Constraints**: Validações de integridade

## 🔄 Migrações Flyway

### Estrutura de Migrações
```
src/main/resources/db/migration/
├── V1__Create_initial_tables.sql          # H2
├── V2__Add_indexes_and_constraints.sql    # H2
├── V3__Insert_sample_data.sql             # H2
├── V4__Add_future_extensions.sql          # H2
└── mysql/
    └── V1__Create_initial_tables_mysql.sql # MySQL
```

### Comandos Flyway
```bash
# Verificar status
mvn flyway:info

# Executar migrações
mvn flyway:migrate

# Limpar banco (desenvolvimento)
mvn flyway:clean
```

## 🌐 Acesso aos Serviços

### Aplicação XP
- **URL**: https://localhost:8080
- **Swagger**: https://localhost:8080/swagger-ui.html
- **Health**: https://localhost:8080/actuator/health
- **ESB Info**: https://localhost:8080/api/esb/info

### phpMyAdmin
- **URL**: http://localhost:8081
- **Usuário**: xp_user
- **Senha**: xp_password

### MySQL Direto
```bash
# Conectar via Docker
docker exec -it xp-mysql mysql -u xp_user -p xpdb

# Conectar via cliente MySQL
mysql -h localhost -P 3306 -u xp_user -p xpdb
```

## 🔒 Segurança

### Configurações de Produção
- **SSL/TLS**: Obrigatório
- **Senhas**: Via variáveis de ambiente
- **CORS**: Configurável
- **Rate Limiting**: Ativado
- **Audit Logs**: Habilitados

### Variáveis de Ambiente (Produção)
```bash
export DB_HOST=your-mysql-host
export DB_PORT=3306
export DB_NAME=xpdprod
export DB_USERNAME=xp_prod_user
export DB_PASSWORD=secure_prod_password
export JWT_SECRET=your-jwt-secret
export ENCRYPTION_KEY=your-encryption-key
export CORS_ALLOWED_ORIGINS=https://yourdomain.com
```

## 📈 Performance

### Configurações Otimizadas
- **Connection Pool**: HikariCP configurado
- **Batch Processing**: Habilitado
- **Índices**: Otimizados para queries frequentes
- **Caching**: Configurado para produção

### Monitoramento
- **JMX**: Habilitado
- **Actuator**: Health checks
- **Logs**: Estruturados
- **Métricas**: Disponíveis

## 🚨 Troubleshooting

### Problemas Comuns

#### 1. MySQL não inicia
```bash
# Verificar logs
docker logs xp-mysql

# Verificar se a porta está livre
netstat -tulpn | grep 3306
```

#### 2. Conexão recusada
```bash
# Verificar se o container está rodando
docker ps | grep xp-mysql

# Testar conectividade
docker exec xp-mysql mysqladmin ping -h localhost
```

#### 3. Erro de migração
```bash
# Verificar status das migrações
mvn flyway:info

# Limpar e reaplicar (desenvolvimento)
mvn flyway:clean
mvn flyway:migrate
```

#### 4. SSL/TLS Issues
```bash
# Desabilitar SSL para desenvolvimento
# Adicionar ?useSSL=false na URL de conexão
```

## 🔄 Migração H2 → MySQL

### Passos para Migração
1. **Backup dos dados H2** (se necessário)
2. **Configurar MySQL** com Docker Compose
3. **Executar migrações** Flyway
4. **Verificar dados** via phpMyAdmin
5. **Testar aplicação** com novo banco

### Compatibilidade
- ✅ **100% compatível** com H2
- ✅ **Mesma estrutura** de dados
- ✅ **Mesmas APIs** REST/SOAP
- ✅ **Mesmos testes** funcionam

## 📚 Recursos Adicionais

### Documentação
- [MySQL 8.0 Reference](https://dev.mysql.com/doc/refman/8.0/en/)
- [Flyway Documentation](https://flywaydb.org/documentation/)
- [Spring Boot MySQL](https://spring.io/guides/gs/accessing-data-mysql/)

### Ferramentas
- **phpMyAdmin**: Interface web
- **MySQL Workbench**: Cliente desktop
- **DBeaver**: Cliente universal
- **Flyway CLI**: Linha de comando

---

## 🎯 Resumo

O projeto XP agora suporta **MySQL e H2** com total flexibilidade:

- ✅ **Desenvolvimento**: H2 (rápido) ou MySQL (realista)
- ✅ **Testes**: H2 (isolado)
- ✅ **Produção**: MySQL (robusto)
- ✅ **Migrações**: Flyway (versionado)
- ✅ **Monitoramento**: Completo
- ✅ **Segurança**: Configurável

**Escolha o banco que melhor se adequa ao seu ambiente!** 🚀

---

*Documentação criada em: $(date)*
*Projeto: XP Application*
*Versão: 0.0.1-SNAPSHOT*
