# Diagram Reference: C4 Model, Sequence and DER

Use Mermaid diagrams in every architectural document so they render natively in Markdown on GitHub/GitLab and in code documentation.

---

## 1. C4 Model (Context and Containers)

### C4 Level 1 - System Context
Shows the system boundaries, its users and external systems.

```mermaid
C4Context
    title C4 Level 1 - Overall System Context
    Enterprise_Boundary(b0, "Company Ecosystem") {
        Person(customer, "Customer", "Uses the services and places orders")
        Person(admin, "Operator / Support", "Manages orders and settings")
        System(coreSystem, "Core Platform", "Orchestrates business operations and central rules")
    }

    System_Ext(emailService, "Email Provider (Sendgrid)", "Sends transactional emails")
    System_Ext(erp, "Legacy ERP", "Stores central accounting and inventory")

    Rel(customer, coreSystem, "Places orders and queries", "HTTPS")
    Rel(admin, coreSystem, "Operates the admin panel", "HTTPS")
    Rel(coreSystem, emailService, "Dispatches notifications", "HTTPS/REST")
    Rel(coreSystem, erp, "Syncs fiscal data", "gRPC/VPN")
```

---

### C4 Level 2 - Containers
Reveals the applications, databases, microservices and messaging.

```mermaid
C4Container
    title C4 Level 2 - Containers and Communication
    Person(user, "User")

    Container_Boundary(c1, "Platform") {
        Container(webApp, "SPA Frontend", "React / Next.js", "Interactive web interface")
        Container(mobileApp, "Mobile App", "React Native / Expo", "iOS/Android mobile app")
        Container(apiGateway, "API Gateway / BFF", "Go / Node.js", "Routing, authentication and rate limit")
        Container(orderService, "Order Service", "TypeScript", "Order processing and lifecycle")
        Container(paymentService, "Payment Service", "Go", "Secure integration with financial gateways")
        ContainerDb(db, "Primary DB", "PostgreSQL", "Relational storage with RLS")
        ContainerQueue(broker, "Event Broker", "RabbitMQ / Kafka", "Asynchronous event queue")
    }

    Rel(user, webApp, "Accesses", "HTTPS")
    Rel(user, mobileApp, "Accesses", "HTTPS")
    Rel(webApp, apiGateway, "Calls the API", "JSON/HTTPS")
    Rel(mobileApp, apiGateway, "Calls the API", "JSON/HTTPS")
    Rel(apiGateway, orderService, "Forwards calls", "gRPC")
    Rel(orderService, db, "Persists orders", "TCP")
    Rel(orderService, broker, "Publishes 'OrderCreated'", "AMQP")
    Rel(broker, paymentService, "Consumes 'OrderCreated'", "AMQP")
```

---

## 2. Sequence Diagram (Flows and Protocols)

Essential to make synchronous calls, asynchronous calls, webhooks and idempotency explicit.

```mermaid
sequenceDiagram
    autonumber
    actor Client as Customer (Web/Mobile)
    participant Gateway as API Gateway
    participant OrderSvc as Order Service
    participant Broker as Message Broker (Queue)
    participant PaySvc as Payment Service
    participant GatewayExt as External Payment Gateway

    Client->>Gateway: POST /v1/orders (payload + idempotency_key)
    Gateway->>OrderSvc: Validate and create the order
    OrderSvc->>OrderSvc: Persist 'PENDING' status in the DB
    OrderSvc->>Broker: Publish 'order.created' event
    OrderSvc-->>Gateway: Returns 201 Created (order_id)
    Gateway-->>Client: 201 Created

    par Asynchronous processing
        Broker->>PaySvc: Consume 'order.created' event
        PaySvc->>GatewayExt: POST /charges (processes card/PIX)
        GatewayExt-->>PaySvc: 200 OK (transaction approved)
        PaySvc->>Broker: Publish 'payment.succeeded' event
    end
```

---

## 3. Entity-Relationship Diagram (DER / data schema)

```mermaid
erDiagram
    TENANT ||--o{ USER : has
    TENANT ||--o{ ORDER : has
    USER ||--o{ ORDER : places
    ORDER ||--|{ ORDER_ITEM : contains
    PRODUCT ||--o{ ORDER_ITEM : referenced_by

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
