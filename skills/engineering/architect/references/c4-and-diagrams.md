# Referência de Diagramas: C4 Model, Sequência e DER

Use diagramas Mermaid em todos os documentos arquiteturais para garantir renderização nativa em Markdown no GitHub/GitLab e documentações de código.

---

## 1. C4 Model (Contexto e Contêineres)

### C4 Nível 1 - Contexto do Sistema
Ilustra os limites do sistema, seus usuários e sistemas externos.

```mermaid
C4Context
    title C4 Nível 1 - Contexto Geral do Sistema
    Enterprise_Boundary(b0, "Ecossistema da Empresa") {
        Person(customer, "Cliente", "Acessa os serviços e faz compras")
        Person(admin, "Operador / Suporte", "Gerencia pedidos e configurações")
        System(coreSystem, "Plataforma Core", "Orquestra operações de negócio e regras centrais")
    }

    System_Ext(emailService, "Provedor de Email (Sendgrid)", "Envia emails transacionais")
    System_Ext(erp, "ERP Legado", "Armazena contabilidade e estoque central")

    Rel(customer, coreSystem, "Realiza pedidos e consultas", "HTTPS")
    Rel(admin, coreSystem, "Opera painel de administração", "HTTPS")
    Rel(coreSystem, emailService, "Dispara notificações", "HTTPS/REST")
    Rel(coreSystem, erp, "Sincroniza dados fiscais", "gRPC/VPN")
```

---

### C4 Nível 2 - Contêineres
Expõe as aplicações, bancos de dados, microsserviços e mensageria.

```mermaid
C4Container
    title C4 Nível 2 - Contêineres e Comunicação
    Person(user, "Usuário")

    Container_Boundary(c1, "Plataforma") {
        Container(webApp, "Frontend SPA", "React / Next.js", "Interface web interativa")
        Container(mobileApp, "Mobile App", "React Native / Expo", "App mobile iOS/Android")
        Container(apiGateway, "API Gateway / BFF", "Go / Node.js", "Roteamento, autenticação e rate limit")
        Container(orderService, "Order Service", "TypeScript", "Processamento e ciclo de vida de pedidos")
        Container(paymentService, "Payment Service", "Go", "Integração segura com gateways financeiros")
        ContainerDb(db, "Primary DB", "PostgreSQL", "Armazenamento relacional com RLS")
        ContainerQueue(broker, "Event Broker", "RabbitMQ / Kafka", "Fila assíncrona de eventos")
    }

    Rel(user, webApp, "Acessa", "HTTPS")
    Rel(user, mobileApp, "Acessa", "HTTPS")
    Rel(webApp, apiGateway, "Chama API", "JSON/HTTPS")
    Rel(mobileApp, apiGateway, "Chama API", "JSON/HTTPS")
    Rel(apiGateway, orderService, "Encaminha chamadas", "gRPC")
    Rel(orderService, db, "Persiste pedidos", "TCP")
    Rel(orderService, broker, "Publica 'OrderCreated'", "AMQP")
    Rel(broker, paymentService, "Consome 'OrderCreated'", "AMQP")
```

---

## 2. Diagrama de Sequência (Fluxos e Protocolos)

Essencial para explicitar chamadas síncronas, assíncronas, webhooks e idempotência.

```mermaid
sequenceDiagram
    autonumber
    actor Client as Cliente (Web/Mobile)
    participant Gateway as API Gateway
    participant OrderSvc as Order Service
    participant Broker as Message Broker (Queue)
    participant PaySvc as Payment Service
    participant GatewayExt as Gateway Pagamento Externo

    Client->>Gateway: POST /v1/orders (payload + idempotency_key)
    Gateway->>OrderSvc: Validar e criar pedido
    OrderSvc->>OrderSvc: Persiste status 'PENDING' no DB
    OrderSvc->>Broker: Publicar evento 'order.created'
    OrderSvc-->>Gateway: Retorna 201 Created (order_id)
    Gateway-->>Client: 201 Created

    par Processamento Assíncrono
        Broker->>PaySvc: Consumir evento 'order.created'
        PaySvc->>GatewayExt: POST /charges (processa cartão/PIX)
        GatewayExt-->>PaySvc: 200 OK (Transação aprovada)
        PaySvc->>Broker: Publicar evento 'payment.succeeded'
    end
```

---

## 3. Diagrama de Entidade-Relacionamento (DER / Esquema de Dados)

```mermaid
erDiagram
    TENANT ||--o{ USER : possui
    TENANT ||--o{ ORDER : possui
    USER ||--o{ ORDER : realiza
    ORDER ||--|{ ORDER_ITEM : contem
    PRODUCT ||--o{ ORDER_ITEM : referencia

    TENANT {
        uuid id PK
        string name
        string slug
        timestamp created_at
    }

    USER {
        uuid id PK
        uuid tenant_id FK
        string email
        string role
        timestamp created_at
    }

    ORDER {
        uuid id PK
        uuid tenant_id FK
        uuid user_id FK
        decimal total_amount
        string status
        timestamp created_at
    }

    ORDER_ITEM {
        uuid id PK
        uuid order_id FK
        uuid product_id FK
        int quantity
        decimal unit_price
    }

    PRODUCT {
        uuid id PK
        uuid tenant_id FK
        string sku
        string title
        decimal price
    }
```
