# 🗄️ Database Migrations - Projeto XP

## 📋 Visão Geral

Este diretório contém os scripts de migração do banco de dados usando **Flyway** para controle de versão e evolução do schema.

## 🚀 Configuração

### Dependências
```xml
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-core</artifactId>
</dependency>
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-database-h2</artifactId>
</dependency>
```

### Configuração no application.properties
```properties
# Flyway Database Migration
spring.flyway.enabled=true
spring.flyway.locations=classpath:db/migration
spring.flyway.baseline-on-migrate=true
spring.flyway.baseline-version=0
spring.flyway.validate-on-migrate=true
spring.flyway.clean-disabled=false
```

## 📁 Estrutura das Migrações

### V1__Create_initial_tables.sql
- **Descrição**: Criação das tabelas iniciais do sistema
- **Tabelas**: users, products, customers, audit_log, security_event, lgpd_request, role
- **Funcionalidades**: 
  - Schema base da aplicação
  - Constraints de integridade
  - Comentários de documentação

### V2__Add_indexes_and_constraints.sql
- **Descrição**: Adição de índices de performance e constraints adicionais
- **Funcionalidades**:
  - Índices para otimização de queries
  - Constraints de validação de dados
  - Índices compostos para buscas complexas

### V3__Insert_sample_data.sql
- **Descrição**: Inserção de dados de exemplo para desenvolvimento e testes
- **Dados**:
  - Usuários padrão (admin, user, etc.)
  - Catálogo de produtos
  - Clientes de exemplo
  - Logs de auditoria
  - Eventos de segurança
  - Requisições LGPD

### V4__Add_future_extensions.sql
- **Descrição**: Extensões futuras para funcionalidades avançadas
- **Tabelas**: orders, order_items, categories, wishlist, reviews, notifications, api_keys
- **Funcionalidades**: E-commerce, categorização, reviews, notificações

## 🔧 Comandos Flyway

### Executar Migrações
```bash
# Via Maven
mvn flyway:migrate

# Via Spring Boot (automático na inicialização)
./mvnw spring-boot:run
```

### Verificar Status
```bash
# Verificar migrações aplicadas
mvn flyway:info

# Verificar histórico
mvn flyway:history
```

### Limpar Banco (Desenvolvimento)
```bash
# Limpar todas as tabelas (CUIDADO!)
mvn flyway:clean

# Reaplicar todas as migrações
mvn flyway:migrate
```

## 📊 Estrutura do Banco

### Tabelas Principais
- **users**: Usuários do sistema com autenticação
- **products**: Catálogo de produtos
- **customers**: Dados dos clientes
- **audit_log**: Log de auditoria para compliance
- **security_event**: Eventos de segurança
- **lgpd_request**: Requisições de conformidade LGPD

### Tabelas de Extensão
- **orders**: Pedidos de e-commerce
- **order_items**: Itens dos pedidos
- **categories**: Categorias de produtos
- **wishlist**: Lista de desejos dos usuários
- **reviews**: Avaliações de produtos
- **notifications**: Notificações do sistema
- **api_keys**: Chaves de API para integração

## 🔒 Segurança e Compliance

### LGPD Compliance
- Tabela `lgpd_request` para rastreamento de requisições
- Logs de auditoria em `audit_log`
- Eventos de segurança em `security_event`

### Validações de Dados
- Constraints de integridade referencial
- Validações de formato (email, telefone, etc.)
- Checks de valores (preços, ratings, etc.)

## 🚀 Desenvolvimento

### Criando Nova Migração
1. Crie um novo arquivo seguindo o padrão: `V{versão}__{descrição}.sql`
2. Use transações para operações complexas
3. Adicione comentários explicativos
4. Teste em ambiente de desenvolvimento

### Exemplo de Nova Migração
```sql
-- =====================================================
-- Migration V5: Add New Feature
-- Description: Adds new functionality
-- Author: Development Team
-- Date: 2024-01-20
-- =====================================================

-- Add new table
CREATE TABLE new_feature (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add indexes
CREATE INDEX idx_new_feature_name ON new_feature(name);
```

## 📈 Monitoramento

### Verificação de Integridade
- Flyway valida checksums das migrações
- Constraints garantem integridade dos dados
- Índices otimizam performance das queries

### Logs de Migração
- Flyway registra todas as operações
- Logs disponíveis via Actuator
- Histórico completo de mudanças

## 🎯 Benefícios

### Controle de Versão
- ✅ Histórico completo de mudanças
- ✅ Rollback de migrações
- ✅ Validação de integridade

### Colaboração
- ✅ Migrações versionadas
- ✅ Aplicação automática
- ✅ Sincronização de ambientes

### Qualidade
- ✅ Validação de dados
- ✅ Performance otimizada
- ✅ Documentação integrada

---

*Documentação criada em: $(date)*
*Projeto: XP Application*
*Versão: 0.0.1-SNAPSHOT*
