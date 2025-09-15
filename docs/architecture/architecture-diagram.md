# 🏗️ Diagramas de Arquitetura - Projeto XP

## 📋 Visão Geral

Este documento contém os diagramas de arquitetura do projeto XP, uma aplicação Spring Boot que implementa uma arquitetura orientada a serviços (SOA) com ESB (Enterprise Service Bus) usando Apache Camel.

---

## 🏛️ 1. Arquitetura de Camadas

### Diagrama de Camadas da Aplicação

```mermaid
graph TB
    subgraph "🌐 Camada de Apresentação"
        A[Swagger UI<br/>Documentação API]
        B[H2 Console<br/>Interface BD]
        C[Postman Collection<br/>Testes API]
        D[Cliente HTTP<br/>Consumidores]
    end
    
    subgraph "🔌 Camada de Controllers"
        E[AuthController<br/>Autenticação JWT]
        F[ProductController<br/>CRUD Produtos]
        G[CustomerController<br/>CRUD Clientes]
        H[ESBController<br/>Endpoints ESB]
        I[LGPDController<br/>Conformidade LGPD]
        J[AdminController<br/>Funções Admin]
    end
    
    subgraph "⚙️ Camada de Serviços"
        K[AuthenticationService<br/>Autenticação]
        L[ProductService<br/>Lógica Produtos]
        M[CustomerService<br/>Lógica Clientes]
        N[LGPDComplianceService<br/>Conformidade]
        O[SecurityServices<br/>Segurança]
    end
    
    subgraph "🔄 Camada ESB (Apache Camel)"
        P[ESBRoutes<br/>Roteamento]
        Q[MessageAggregator<br/>Agregação]
        R[CircuitBreaker<br/>Tolerância Falhas]
        S[LoadBalancer<br/>Balanceamento]
        T[MessageEnricher<br/>Enriquecimento]
    end
    
    subgraph "🗄️ Camada de Persistência"
        U[ProductRepository<br/>JPA Repository]
        V[CustomerRepository<br/>JPA Repository]
        W[UserRepository<br/>JPA Repository]
        X[H2 Database<br/>Banco em Memória]
    end
    
    subgraph "🔒 Camada de Segurança"
        Y[JwtService<br/>Tokens JWT]
        Z[InputSanitizer<br/>Sanitização]
        AA[RateLimitingService<br/>Limitação Taxa]
        BB[AnomalyDetectionService<br/>Detecção Anomalias]
        CC[DataEncryptionService<br/>Criptografia]
    end
    
    subgraph "🌍 Camada SOAP"
        DD[ProductEndpoint<br/>SOAP Services]
        EE[WSDL<br/>Contrato SOAP]
        FF[XSD Schema<br/>Validação XML]
    end
    
    %% Conexões entre camadas
    A --> E
    B --> X
    C --> E
    D --> E
    
    E --> K
    F --> L
    G --> M
    H --> P
    I --> N
    J --> M
    
    K --> Y
    L --> U
    M --> V
    N --> W
    O --> Z
    
    P --> Q
    P --> R
    P --> S
    P --> T
    
    U --> X
    V --> X
    W --> X
    
    DD --> L
    EE --> DD
    FF --> DD
```

---

## 🔧 2. Diagrama de Componentes e Integração

### Arquitetura de Componentes

```mermaid
graph TB
    subgraph "🌐 Clientes Externos"
        A[Cliente Web]
        B[Cliente Mobile]
        C[Cliente SOAP]
        D[Cliente ESB]
    end
    
    subgraph "🔐 Gateway de Segurança"
        E[Spring Security]
        F[JWT Authentication]
        G[Rate Limiting]
        H[Input Sanitization]
    end
    
    subgraph "📡 Camada de API"
        I[REST Controllers]
        J[SOAP Endpoints]
        K[ESB Routes]
        L[Global Exception Handler]
    end
    
    subgraph "⚙️ Camada de Negócio"
        M[Service Layer]
        N[Factory Pattern]
        O[DTO Mappers]
        P[Validation Layer]
    end
    
    subgraph "🔄 Enterprise Service Bus"
        Q[Apache Camel]
        R[Message Router]
        S[Content Enricher]
        T[Circuit Breaker]
        U[Load Balancer]
        V[Dead Letter Channel]
    end
    
    subgraph "🗄️ Camada de Dados"
        W[JPA Repositories]
        X[H2 Database]
        Y[Data Encryption]
        Z[Audit Logging]
    end
    
    subgraph "📊 Monitoramento"
        AA[Actuator Health]
        BB[JMX Management]
        CC[Security Audit]
        DD[Performance Metrics]
    end
    
    subgraph "🔒 Serviços de Segurança"
        EE[LGPD Compliance]
        FF[Data Encryption]
        GG[Anomaly Detection]
        HH[Security Maintenance]
    end
    
    %% Fluxo de dados
    A --> E
    B --> E
    C --> J
    D --> K
    
    E --> F
    F --> G
    G --> H
    H --> I
    
    I --> M
    J --> M
    K --> Q
    
    M --> N
    N --> O
    O --> P
    P --> W
    
    Q --> R
    R --> S
    S --> T
    T --> U
    U --> V
    
    W --> X
    X --> Y
    Y --> Z
    
    I --> AA
    Q --> BB
    M --> CC
    W --> DD
    
    M --> EE
    EE --> FF
    FF --> GG
    GG --> HH
```

---

## 🌊 3. Diagrama de Fluxo de Dados

### Fluxo de Dados da Aplicação

```mermaid
sequenceDiagram
    participant C as Cliente
    participant GW as Gateway Segurança
    participant API as REST Controller
    participant SVC as Service Layer
    participant ESB as Apache Camel ESB
    participant REPO as Repository
    participant DB as H2 Database
    participant SOAP as SOAP Endpoint
    
    Note over C,SOAP: Fluxo de Autenticação
    C->>GW: POST /api/auth/authenticate
    GW->>API: Validar credenciais
    API->>SVC: AuthenticationService.authenticate()
    SVC->>REPO: UserRepository.findByUsername()
    REPO->>DB: SELECT user
    DB-->>REPO: User data
    REPO-->>SVC: User entity
    SVC-->>API: JWT Token
    API-->>GW: AuthenticationResponse
    GW-->>C: Token JWT
    
    Note over C,SOAP: Fluxo CRUD Produtos (REST)
    C->>GW: GET /api/products (com JWT)
    GW->>GW: Validar JWT Token
    GW->>API: ProductController.getAllProducts()
    API->>SVC: ProductService.getAllProducts()
    SVC->>REPO: ProductRepository.findAll()
    REPO->>DB: SELECT products
    DB-->>REPO: Product entities
    REPO-->>SVC: List<Product>
    SVC->>SVC: ProductFactory.createDTO()
    SVC-->>API: List<ProductDTO>
    API-->>GW: ResponseEntity<List<ProductDTO>>
    GW-->>C: JSON Response
    
    Note over C,SOAP: Fluxo ESB (REST to SOAP)
    C->>GW: GET /esb/api-to-soap/products
    GW->>ESB: ESB Route Handler
    ESB->>ESB: Transform REST to SOAP
    ESB->>SOAP: SOAP Request
    SOAP->>SVC: ProductService.getAllProducts()
    SVC->>REPO: ProductRepository.findAll()
    REPO->>DB: SELECT products
    DB-->>REPO: Product entities
    REPO-->>SVC: List<Product>
    SVC-->>SOAP: List<ProductDTO>
    SOAP-->>ESB: SOAP Response
    ESB->>ESB: Transform SOAP to JSON
    ESB-->>GW: JSON Response
    GW-->>C: JSON Response
    
    Note over C,SOAP: Fluxo SOAP Direto
    C->>SOAP: SOAP Request (WSDL)
    SOAP->>SVC: ProductService.getProductById()
    SVC->>REPO: ProductRepository.findById()
    REPO->>DB: SELECT product WHERE id
    DB-->>REPO: Product entity
    REPO-->>SVC: Product
    SVC-->>SOAP: ProductDTO
    SOAP-->>C: SOAP Response
```

---

## 🗄️ 4. Diagrama de Entidades (ER)

### Modelo de Dados

```mermaid
erDiagram
    USER {
        Long id PK
        String username UK
        String password
        String email UK
        Role role
        Boolean enabled
        Boolean accountNonExpired
        Boolean accountNonLocked
        Boolean credentialsNonExpired
    }
    
    CUSTOMER {
        Long id PK
        String firstName
        String lastName
        String email UK
        String phone
        String address
    }
    
    PRODUCT {
        Long id PK
        String name
        String description
        Double price
        Integer stock
    }
    
    ROLE {
        String name PK
        String description
    }
    
    AUDIT_LOG {
        Long id PK
        String eventType
        String username
        String ipAddress
        String details
        LocalDateTime timestamp
    }
    
    SECURITY_EVENT {
        Long id PK
        String eventType
        String severity
        String description
        String ipAddress
        LocalDateTime timestamp
        Boolean resolved
    }
    
    LGPD_REQUEST {
        Long id PK
        Long userId FK
        String requestType
        String status
        String requestorEmail
        LocalDateTime requestDate
        LocalDateTime processedDate
    }
    
    %% Relacionamentos
    USER ||--o{ AUDIT_LOG : "generates"
    USER ||--o{ LGPD_REQUEST : "requests"
    USER }o--|| ROLE : "has"
    CUSTOMER ||--o{ AUDIT_LOG : "generates"
    PRODUCT ||--o{ AUDIT_LOG : "generates"
```

---

## 🎯 5. Diagrama de Casos de Uso

### Casos de Uso dos Serviços

```mermaid
graph TB
    subgraph "👤 Ator: Usuário"
        A[Usuário]
    end
    
    subgraph "👨‍💼 Ator: Administrador"
        B[Administrador]
    end
    
    subgraph "🔌 Ator: Cliente Externo"
        C[Cliente Externo]
    end
    
    subgraph "📋 Casos de Uso - Autenticação"
        D[Registrar Usuário]
        E[Autenticar Usuário]
        F[Renovar Token JWT]
    end
    
    subgraph "📦 Casos de Uso - Produtos"
        G[Listar Produtos]
        H[Buscar Produto por ID]
        I[Criar Produto]
        J[Atualizar Produto]
        K[Excluir Produto]
    end
    
    subgraph "👥 Casos de Uso - Clientes"
        L[Listar Clientes]
        M[Buscar Cliente por ID]
        N[Buscar Cliente por Sobrenome]
        O[Criar Cliente]
        P[Atualizar Cliente]
        Q[Excluir Cliente]
    end
    
    subgraph "🔄 Casos de Uso - ESB"
        R[Transformar REST para SOAP]
        S[Agregar Mensagens]
        T[Roteamento Baseado em Conteúdo]
        U[Balanceamento de Carga]
        V[Circuit Breaker]
        W[Enriquecimento de Mensagens]
        X[Dead Letter Channel]
    end
    
    subgraph "🔒 Casos de Uso - LGPD"
        Y[Exportar Dados Pessoais]
        Z[Excluir Dados Pessoais]
        AA[Solicitar Portabilidade]
        BB[Atualizar Consentimento]
    end
    
    subgraph "⚙️ Casos de Uso - Administração"
        CC[Gerenciar Usuários]
        DD[Visualizar Estatísticas]
        EE[Monitorar Sistema]
        FF[Configurar Segurança]
    end
    
    %% Relacionamentos
    A --> D
    A --> E
    A --> F
    A --> G
    A --> H
    A --> L
    A --> M
    A --> N
    A --> O
    A --> P
    A --> Y
    A --> Z
    A --> AA
    A --> BB
    
    B --> CC
    B --> DD
    B --> EE
    B --> FF
    B --> Q
    B --> K
    
    C --> R
    C --> S
    C --> T
    C --> U
    C --> V
    C --> W
    C --> X
```

---

## 🔄 6. Diagrama de Integração ESB

### Padrões ESB Implementados

```mermaid
graph TB
    subgraph "🌐 Entrada de Dados"
        A[Cliente REST]
        B[Cliente SOAP]
        C[Cliente ESB]
    end
    
    subgraph "🔄 Apache Camel ESB"
        D[Message Router]
        E[Content-Based Router]
        F[Message Aggregator]
        G[Load Balancer]
        H[Circuit Breaker]
        I[Message Enricher]
        J[Dead Letter Channel]
        K[Message Translator]
    end
    
    subgraph "🎯 Destinos"
        L[Product Service]
        M[Customer Service]
        N[Authentication Service]
        O[LGPD Service]
        P[External API]
    end
    
    subgraph "📊 Monitoramento"
        Q[JMX Metrics]
        R[Health Checks]
        S[Audit Logs]
    end
    
    %% Fluxos ESB
    A --> D
    B --> K
    C --> E
    
    D --> F
    E --> G
    F --> H
    G --> I
    H --> J
    I --> K
    
    F --> L
    G --> M
    H --> N
    I --> O
    J --> P
    
    D --> Q
    E --> R
    F --> S
    G --> Q
    H --> R
    I --> S
    J --> Q
    K --> R
```

---

## 📊 7. Diagrama de Monitoramento

### Arquitetura de Observabilidade

```mermaid
graph TB
    subgraph "📱 Aplicação XP"
        A[Spring Boot App]
        B[Apache Camel ESB]
        C[Security Services]
        D[LGPD Services]
    end
    
    subgraph "📊 Métricas"
        E[Actuator Health]
        F[JMX Metrics]
        G[Custom Metrics]
        H[Security Audit]
    end
    
    subgraph "📝 Logs"
        I[Application Logs]
        J[Security Logs]
        K[ESB Logs]
        L[Audit Logs]
    end
    
    subgraph "🔍 Monitoramento"
        M[Health Endpoints]
        N[JMX Console]
        O[Log Files]
        P[Security Dashboard]
    end
    
    subgraph "🚨 Alertas"
        Q[Anomaly Detection]
        R[Rate Limiting]
        S[Circuit Breaker]
        T[Security Violations]
    end
    
    %% Conexões
    A --> E
    B --> F
    C --> G
    D --> H
    
    A --> I
    C --> J
    B --> K
    D --> L
    
    E --> M
    F --> N
    I --> O
    J --> P
    
    G --> Q
    H --> R
    F --> S
    J --> T
```

---

## 🎯 Resumo da Arquitetura

### **Características Principais:**

1. **🏗️ Arquitetura em Camadas**: Separação clara de responsabilidades
2. **🔄 ESB com Apache Camel**: Padrões de integração enterprise
3. **🔒 Segurança Robusta**: JWT, LGPD, criptografia, auditoria
4. **📊 Observabilidade**: Métricas, logs, health checks
5. **🌐 Múltiplas Interfaces**: REST, SOAP, ESB endpoints
6. **🗄️ Persistência JPA**: H2 com repositórios bem estruturados

### **Padrões Implementados:**

- **Repository Pattern**: Abstração de acesso a dados
- **Factory Pattern**: Criação de objetos DTO/Entity
- **DTO Pattern**: Transferência de dados entre camadas
- **Circuit Breaker**: Tolerância a falhas
- **Message Router**: Roteamento baseado em conteúdo
- **Load Balancer**: Distribuição de carga
- **Dead Letter Channel**: Tratamento de mensagens com erro

---

*Documento criado em: $(date)*
*Projeto: XP Application*
*Versão: 0.0.1-SNAPSHOT*
