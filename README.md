# Aplicação XP

Essa é uma demonstração de um projeto para uma arquitetura orientada a serviços, implementando SOAP e REST junto a uma camada de barramento de serviço corporativo (ESB).

## Tecnologias Usadas

- Java 21
- Spring Boot 3.4.5
- Spring Security with JWT
- Spring Data JPA
- H2 Database
- SOAP Web Services
- RESTful APIs
- **Apache Camel ESB 4.4.0** - Barramento de serviço corporativo
- OpenAPI/Swagger para Documentação
- **Resilience4j** - Implementa o modelo do Circuit Breaker

## Características do ESB

A aplicação possui implementação completa do ESB usando Apache Camel, através dos seguintes padrões:

### Endpoints ESB Disponíveis

- **REST to SOAP Bridge**: `/esb/api-to-soap` - Converte solicitações REST para SOAP
- **Message Aggregator**: `/esb/aggregate` - Aggrega multiplas mensagens
- **Content-Based Router**: `/esb/route` - Direciona mensagens baseado no conteúdo
- **Load Balancer**: `/esb/loadbalance` - Distribui a carga pelos endpoints
- **Circuit Breaker**: `/esb/circuit-breaker` - Implementa tolerância a falhas
- **Message Enricher**: `/esb/enrich` - Enriquece as mensagens com informações adicionais
- **Dead Letter Channel**: `/esb/deadletter` - Cuida de mensagens com erros

### Monitoramento do ESB

- **JMX Management**: Para monitoramento e gerenciamento
- **Health Endpoints**: Disponível em `/actuator/health`
- **Metrics**: Disponível em `/actuator/metrics`

## Correções Recentes e Aprimoramentos

### Correções do ESB Circuit Breaker
- ✅ **Circuit Breaker Corrigido**: Dependência faltante `camel-resilience4j-starter` adicionada
- ✅ **Configuração do Servlet**: Arquivo `CamelServletConfig` criado para expor rotas ESB via HTTP
- ✅ **Configurações de Segurança**: Atualizadas para permitir acesso a pasta `/esb/**` com os endpoints

### Melhorias de CI/CD na Pipeline
- ✅ **Correção no Docker H2**: Serviço Docker inexistente removido do Github Actions
- ✅ **Configuração de Testes**: Adicionado o arquivo `application-test.properties` dedicado para testar o ambiente.
- ✅ **Maven Surefire**: Configurado para compatibilidade com Java 21
- ✅ **Gerenciamento de Perfis**: Teste de ativação de perfil automático

## Carregando a Aplicação

Para rodar a aplicação, execute o seguinte comando:

```bash
# Usando Maven Wrapper
./mvnw spring-boot:run
```

Ou caso esteja usando o Maven tradicional:

```bash
mvn spring-boot:run
```

Por padrão, a aplicação começará na porta 8080.

## Acessando a Applicação

- **H2 Database Console**: http://localhost:8080/h2-console
  - JDBC URL: `jdbc:h2:mem:xpdb`
  - Username: `sa`
  - Password: `password`

- **Swagger UI**: http://localhost:8080/swagger-ui.html

- **WSDL para o serviço web SOAP**: http://localhost:8080/ws/products.wsdl

## Autenticação de API

As APIs REST estão seguras com Autentiação JWT, para acessar os endpoints protegidos, você terá que:

1. Registrar um novo usuário ou usar um dos usuários preé-definidos:
   - Admin: `admin` / `admin123`
   - User: `user` / `user123`

2. Authenticar para coletar um token JWT:
   ```json
   // POST /api/auth/authenticate
   {
     "username": "admin",
     "password": "admin123"
   }
   ```

   Resposta:
   ```json
   {
     "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTYzMTQ1MjQ5MCwiZXhwIjoxNjMxNDU0MjkwfQ.example_token"
   }
   ```

3. Use a token retornada no header do autenticador para solicitações subsequentes:
   ```
   Authorization: Bearer <token>
   ```

##  Endpoints da API REST

### Authenticação

- `POST /api/auth/register` - Registrar um novo usuário
  ```json
  // Corpo
  {
    "firstName": "New",
    "lastName": "User",
    "username": "newuser",
    "email": "newuser@example.com",
    "password": "securepassword123",
    "role": "USER"
  }
  ```

  Resposta:
  ```json
  {
    "message": "User registered successfully"
  }
  ```

- `POST /api/auth/authenticate` - Authentique e colete o token JWT
  ```json
  // Request Body
  {
    "username": "admin",
    "password": "admin123"
  }
  ```

  Resposta:
  ```json
  {
    "token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJhZG1pbiIsImlhdCI6MTYzMTQ1MjQ5MCwiZXhwIjoxNjMxNDU0MjkwfQ.example_token"
  }
  ```

### Produtos

- `GET /api/products` - Coleta todos os produtos
  
  Resposta:
  ```json
  [
    {
      "id": 1,
      "name": "Laptop",
      "description": "High-performance laptop",
      "price": 1299.99,
      "stockQuantity": 50
    },
    {
      "id": 2,
      "name": "Smartphone",
      "description": "Latest smartphone model",
      "price": 899.99,
      "stockQuantity": 100
    }
  ]
  ```

- `GET /api/products/{id}` - Pega um produto por ID
  
  Resposta:
  ```json
  {
    "id": 1,
    "name": "Laptop",
    "description": "High-performance laptop",
    "price": 1299.99,
    "stockQuantity": 50
  }
  ```

- `POST /api/products` - Cria um novo produto
  ```json
  // Corpo
  {
    "name": "Tablet",
    "description": "10-inch tablet with high resolution display",
    "price": 499.99,
    "stockQuantity": 75
  }
  ```

- `PUT /api/products/{id}` - Atualiza um produto
  ```json
  // Corpo
  {
    "name": "Updated Laptop",
    "description": "Updated high-performance laptop",
    "price": 1399.99,
    "stockQuantity": 45
  }
  ```

- `DELETE /api/products/{id}` - Deleta um produto

### Clientes

- `GET /api/customers` - Coleta todos os clientes
  
  Resposta:
  ```json
  [
    {
      "id": 1,
      "firstName": "John",
      "lastName": "Doe",
      "email": "john.doe@example.com",
      "phone": "123-456-7890",
      "address": "123 Main St"
    },
    {
      "id": 2,
      "firstName": "Jane",
      "lastName": "Smith",
      "email": "jane.smith@example.com",
      "phone": "987-654-3210",
      "address": "456 Oak Ave"
    }
  ]
  ```

- `GET /api/customers/{id}` - Coleta clientes por ID
  
  Resposta:
  ```json
  {
    "id": 1,
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "phone": "123-456-7890",
    "address": "123 Main St"
  }
  ```

- `GET /api/customers/search?lastName=xyz` - Pesquisa clientes pelo último nome
  
  Resposta:
  ```json
  [
    {
      "id": 3,
      "firstName": "Robert",
      "lastName": "xyz",
      "email": "robert.xyz@example.com",
      "phone": "555-123-4567",
      "address": "789 Pine Rd"
    }
  ]
  ```

- `POST /api/customers` - Cria um novo cliente
  ```json
  // Corpo
  {
    "firstName": "Alice",
    "lastName": "Johnson",
    "email": "alice.johnson@example.com",
    "phone": "555-987-6543",
    "address": "321 Elm St"
  }
  ```

- `PUT /api/customers/{id}` - Atualiza um cliente
  ```json
  // Corpo
  {
    "firstName": "Alice",
    "lastName": "Williams",
    "email": "alice.williams@example.com",
    "phone": "555-987-6543",
    "address": "321 Maple Ave"
  }
  ```

- `DELETE /api/customers/{id}` - Deleta um cliente (somente admin)

## SOAP Web Service

A aplicação expõe o SOAP Web Service para os produtos. Você pode acessar o WSDL em http://localhost:8080/ws/products.wsdl.

Exemplos de solicitações SOAP estão disponíveis na pasta `src/main/resources/soap-requests`

### Testando com o SoapUI ou Postman

1. Importe o WSDL no SoapUI ou Postman
2. Use as solicitações de exemplo disponíveis na pasta `soap-requests`

### Operações SOAP Disponíveis

- `GetAllProductsRequest` - Coleta todos os produtos
- `GetProductRequest` - Pega um produto por ID
- `AddProductRequest` - Adiciona um novo produto

## adrões Architecturais Demonstrados

- **Arquitetura Orientada a Serviços (SOA)**: Por APIs REST e SOAP Web Services
- **Modularização**: Usando interfaces e implementações
- **Factory**: Em `ProductFactory` e `CustomerFactory`
- **DTO**: Objetos para transferência de dados para comunicação de APIs.
- **Repositório**: Para abstração de acesso a dados.
- **Padrão MVC**: Model-View-Controller para APIs Web.

## Segurança

- Autenticação e autorização baseados em JWT.
- Controle de acesso baseado em função.
- Criptografia de senhas usando BCrypt
- Configuração HTTPS-ready (certificado SSL é necessário)

### Gerando uma chave JWT segura

Por motivos de segurança, você deve gerar a chave JWT somente para uso em produção. A aplicação inclui uma classe utilitária que gera a chave através do seguinte comando:

```bash
# Roda o gerador de chaves
mvn compile exec:java -Dexec.mainClass="com.xp.util.JwtKeyGenerator"
```

Isso irá resultar numa chave segura a qual você pode adicionar no arquivo `application.properties`, da seguinte forma:

```properties
jwt.secret=sua_chave_segura_aqui
```
