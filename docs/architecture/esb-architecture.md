# 🔄 Arquitetura ESB - Projeto XP

## 📋 Visão Geral

Este documento detalha a implementação do Enterprise Service Bus (ESB) no projeto XP usando Apache Camel 4.4.0, demonstrando padrões de integração enterprise.

---

## 🏗️ Arquitetura ESB Detalhada

### Diagrama de Arquitetura ESB

```mermaid
graph TB
    subgraph "🌐 Clientes"
        A[Cliente REST]
        B[Cliente SOAP]
        C[Cliente ESB]
        D[Cliente Mobile]
    end
    
    subgraph "🔌 Gateway ESB"
        E[Camel Servlet]
        F[ESB Controller]
        G[Route Builder]
    end
    
    subgraph "🔄 Padrões ESB Implementados"
        H[Message Router<br/>/esb/route]
        I[Message Aggregator<br/>/esb/aggregate]
        J[Load Balancer<br/>/esb/loadbalance]
        K[Circuit Breaker<br/>/esb/circuit-breaker]
        L[Message Enricher<br/>/esb/enrich]
        M[Dead Letter Channel<br/>/esb/deadletter]
        N[REST to SOAP Bridge<br/>/esb/api-to-soap]
    end
    
    subgraph "🎯 Serviços de Destino"
        O[Product Service]
        P[Customer Service]
        Q[Authentication Service]
        R[External API]
    end
    
    subgraph "📊 Monitoramento ESB"
        S[JMX Management]
        T[Health Endpoints]
        U[Audit Logs]
        V[Performance Metrics]
    end
    
    %% Fluxos de entrada
    A --> E
    B --> E
    C --> F
    D --> E
    
    %% Gateway para padrões
    E --> G
    F --> G
    G --> H
    G --> I
    G --> J
    G --> K
    G --> L
    G --> M
    G --> N
    
    %% Padrões para serviços
    H --> O
    H --> P
    I --> O
    I --> P
    J --> O
    J --> Q
    K --> O
    L --> P
    M --> R
    N --> O
    
    %% Monitoramento
    H --> S
    I --> T
    J --> U
    K --> V
    L --> S
    M --> T
    N --> U
```

---

## 🔄 Padrões ESB Implementados

### 1. Message Router (Content-Based Router)

```mermaid
graph LR
    A[Request] --> B{Entity Type?}
    B -->|products| C[Product Service]
    B -->|customers| D[Customer Service]
    B -->|unknown| E[Error Response]
    
    C --> F[JSON Response]
    D --> F
    E --> G[400 Bad Request]
```

**Endpoint**: `/esb/route?entity=products|customers`

### 2. Message Aggregator

```mermaid
graph TB
    A[Request] --> B[Multicast]
    B --> C[Product Service]
    B --> D[Customer Service]
    C --> E[Aggregation Strategy]
    D --> E
    E --> F[Combined Response]
```

**Endpoint**: `/esb/aggregate`

### 3. Load Balancer

```mermaid
graph LR
    A[Request] --> B[Round Robin]
    B --> C[Product REST API]
    B --> D[Product SOAP API]
    C --> E[Response]
    D --> E
```

**Endpoint**: `/esb/loadbalance`

### 4. Circuit Breaker

```mermaid
graph TB
    A[Request] --> B{Service Available?}
    B -->|Yes| C[Product Service]
    B -->|No| D[Fallback Response]
    C --> E[Success Response]
    D --> F[503 Service Unavailable]
```

**Endpoint**: `/esb/circuit-breaker`

### 5. Message Enricher

```mermaid
graph LR
    A[Original Message] --> B[Enrich with Product Data]
    B --> C[Enriched Message]
    C --> D[Enhanced Response]
```

**Endpoint**: `/esb/enrich`

### 6. Dead Letter Channel

```mermaid
graph TB
    A[Request] --> B[Process Message]
    B --> C{Success?}
    C -->|Yes| D[Success Response]
    C -->|No| E[Retry Logic]
    E --> F{Max Retries?}
    F -->|No| B
    F -->|Yes| G[Dead Letter Queue]
    G --> H[Error Response]
```

**Endpoint**: `/esb/deadletter`

### 7. REST to SOAP Bridge

```mermaid
sequenceDiagram
    participant C as Cliente REST
    participant ESB as ESB Router
    participant T as SOAP Transformer
    participant S as SOAP Service
    participant J as JSON Transformer
    
    C->>ESB: GET /esb/api-to-soap/products
    ESB->>T: Transform REST to SOAP
    T->>S: SOAP Request
    S-->>T: SOAP Response
    T->>J: Transform SOAP to JSON
    J-->>ESB: JSON Response
    ESB-->>C: JSON Response
```

**Endpoint**: `/esb/api-to-soap/products`

---

## 📊 Monitoramento ESB

### Métricas Disponíveis

```mermaid
graph TB
    subgraph "📈 Métricas ESB"
        A[Total Routes]
        B[Exchanges Processed]
        C[Exchanges Completed]
        D[Exchanges Failed]
        E[Mean Processing Time]
        F[Last Exchange Time]
    end
    
    subgraph "🔍 Health Checks"
        G[Route Status]
        H[Service Availability]
        I[Circuit Breaker Status]
        J[Dead Letter Queue Size]
    end
    
    subgraph "📝 Audit Logs"
        K[Route Execution]
        L[Error Events]
        M[Performance Metrics]
        N[Security Events]
    end
    
    A --> G
    B --> H
    C --> I
    D --> J
    E --> K
    F --> L
```

---

## 🛠️ Configuração ESB

### Estrutura de Rotas

```java
// Exemplo de configuração de rota ESB
from("servlet:///api-to-soap?servletName=CamelServlet")
    .routeId("rest-to-soap-bridge")
    .log("ESB: Processing REST to SOAP transformation")
    .choice()
        .when(header("CamelHttpPath").isEqualTo("/products"))
            .to("direct:getAllProductsSOAP")
        .when(header("CamelHttpPath").regex("/products/\\d+"))
            .to("direct:getProductByIdSOAP")
        .otherwise()
            .setBody(constant("{\"error\":\"Endpoint not found\"}"))
            .setHeader(Exchange.HTTP_RESPONSE_CODE, constant(404))
    .end();
```

### Configurações de Monitoramento

```properties
# ESB Monitoring
camel.springboot.jmx-enabled=true
camel.springboot.jmx-management-statistics-level=Extended
management.endpoints.web.exposure.include=health,info,metrics,camel
management.endpoint.health.show-details=always
```

---

## 🎯 Benefícios da Arquitetura ESB

### 1. **Desacoplamento de Serviços**
- Serviços não precisam conhecer uns aos outros
- Comunicação através de mensagens padronizadas
- Facilita manutenção e evolução

### 2. **Padrões de Integração**
- Implementação de padrões enterprise comprovados
- Reutilização de componentes
- Consistência na integração

### 3. **Tolerância a Falhas**
- Circuit Breaker para serviços indisponíveis
- Dead Letter Channel para mensagens com erro
- Retry automático com backoff

### 4. **Monitoramento e Observabilidade**
- Métricas detalhadas de performance
- Logs estruturados para auditoria
- Health checks para disponibilidade

### 5. **Transformação de Dados**
- Conversão automática entre formatos (REST ↔ SOAP)
- Enriquecimento de mensagens
- Validação de dados

---

## 🚀 Endpoints ESB Disponíveis

| Endpoint | Padrão | Descrição |
|----------|--------|-----------|
| `/esb/api-to-soap` | REST to SOAP Bridge | Converte requisições REST para SOAP |
| `/esb/aggregate` | Message Aggregator | Agrega múltiplas mensagens |
| `/esb/route` | Content-Based Router | Roteia baseado no conteúdo |
| `/esb/loadbalance` | Load Balancer | Distribui carga entre endpoints |
| `/esb/circuit-breaker` | Circuit Breaker | Implementa tolerância a falhas |
| `/esb/enrich` | Message Enricher | Enriquece mensagens com dados adicionais |
| `/esb/deadletter` | Dead Letter Channel | Trata mensagens com erro |

---

## 📋 Resumo da Implementação ESB

### **Características Técnicas:**
- **Framework**: Apache Camel 4.4.0
- **Padrões**: 7 padrões enterprise implementados
- **Monitoramento**: JMX + Actuator + Health Checks
- **Configuração**: Spring Boot Auto-configuration
- **Logging**: MDC logging para rastreamento

### **Benefícios Alcançados:**
- ✅ Desacoplamento de serviços
- ✅ Tolerância a falhas
- ✅ Monitoramento abrangente
- ✅ Transformação de dados
- ✅ Padrões enterprise
- ✅ Escalabilidade
- ✅ Manutenibilidade

---

*Documento criado em: $(date)*
*Projeto: XP Application - ESB Architecture*
*Versão: 0.0.1-SNAPSHOT*
