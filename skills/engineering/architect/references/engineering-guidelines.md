# Diretrizes Técnicas e Regras Inegociáveis de Arquitetura e Engenharia

Este documento consolida as diretrizes inegociáveis para o **Arquiteto de Software**, seus artefatos (ADD/SAD, ADRs, PRDs técnicos) e a atuação dos agentes de desenvolvimento (`/developer`).

---

## 1. Production-Readiness (Caminho para Produção)

- **Maturidade Corporativa:** Todo plano e ADD deve mapear explicitamente os passos faltantes para atingir maturidade de nível corporativo (Enterprise Grade), indicando o "caminho ideal" sem atalhos frágeis.
- **Análise de Trade-offs com Empatia:** Explicar claramente prós e contras de cada escolha arquitetural (ex.: acoplamento vs coesão, gargalos de I/O, custos de infraestrutura). Abordagens frágeis devem ser corrigidas com didática e embasamento técnico.
- **Design para o Ciclo de Vida Completo:** Toda solução deve ser projetada desde o dia zero para:
  1. *Testabilidade:* Módulos profundos com interfaces fáceis de mockar/testar.
  2. *Build & CI:* Pipelines atômicos e rápidos.
  3. *Deploy:* Zero-downtime (Blue/Green ou Canary), rollback simplificado.
  4. *Monitoramento & SRE:* Métricas de ouro (Latência, Tráfego, Erros, Saturação), logs estruturados e rastreamento distribuído.

---

## 2. Engenharia e Refatoração Segura

- **Padrões & Limites:** Clean Architecture, Domain-Driven Design (DDD) e SOLID aplicados com equilíbrio e bom senso (KISS e YAGNI). Evitar over-engineering desnecessário.
- **Segurança na Refatoração:**
  - Proibido quebrar contratos públicos ou realizar breaking changes brutais.
  - As migrações devem ser em passos incrementais (Expand & Contract / Strangler Fig Pattern).
  - APIs com contratos consistentes e versionados (REST com OpenAPI ou gRPC com Protobuf).
- **Arqueologia de Código Obrigatória:**
  - Ler e compreender rotas existentes, padrões de concorrência, tratamento de erros e convenções de nomenclatura locais **ANTES** de propor ou refatorar.
  - Respeitar padrões estabelecidos da base de código. Desvios substanciais exigem registro prévio em ADR (`docs/adr/`).
- **Engenharia de Teste Reversa:**
  - Diante de bugs ou novas features, inspecionar primeiro a suite de testes existente.
  - Tratar testes automatizados como especificação viva do sistema.
  - Toda alteração deve garantir **regressão zero**.

---

## 3. DBA, Concorrência e Segurança OWASP

- **Estratégia de Banco de Dados:**
  - Dimensionamento de volumetria e plano de crescimento de dados.
  - Indexação criteriosa (B-Tree, GIN, índices compostos), planos de execução (`EXPLAIN ANALYZE`).
  - Prevenção ativa de consultas N+1 (uso de `JOIN FETCH`, batch loading ou DataLoaders).
  - Pooling de conexões dimensionado para concorrência e estratégias de cache (Redis com TTL adequado).
- **Segurança OWASP Top 10:**
  - Prevenção estrita a SQL Injection (queries parametrizadas/ORM), XSS (sanitização de inputs e headers CSP), CSRF e vazamento de credenciais.
  - Rotas e fluxos críticos (autenticação, pagamento, permissões) devem ter especificações e testes negativos de ataque (ex.: `*.spec.sec.ts` via Playwright CLI / `/secure-e2e`).

---

## 4. Proatividade Full-Stack & Revelação de Lacunas Ocultas

- **Mapeamento Ponta-a-Ponta:** Quando o usuário fornecer requisitos vagos ou abstratos, o arquiteto deve mapear todo o fluxo ponta-a-ponta e autodeclarar módulos "invisíveis" indispensáveis (auditoria/logs, rate limiting, SLAs, transações distribuídas, circuit breakers, concorrência e idempotência).
- **Ecossistema Frontend/Backend:** Ao desenhar uma feature de interface, garantir simultaneamente:
  1. Contrato da API e validação de schema (Zod/OpenAPI);
  2. Gerenciamento de estado global e assíncrono (React Query / Zustand / SWR);
  3. Transporte seguro de credenciais (HttpOnly Cookies / Bearer tokens);
  4. Persistência de sessão resiliente e tratamento global de erros (Error Boundaries + Toasts).
- **Desafio Técnico & Mentoria:** Se o usuário ignorar riscos de segurança, falhas de consistência ou problemas de escalabilidade, atuar ativamente como mentor, apresentando os componentes e salvaguardas necessários.

---

## 5. Rigor de Código e Edição Cirúrgica

- **ZERO Pseudocódigo:** É expressamente **proibido** utilizar `// ...`, `// resto do código` ou `/* implementação futura */`. Todo código gerado em artefatos ou refatorações deve ser real, completo, tipado e auto-contido.
- **Edição Cirúrgica e Atômica:**
  - Em ferramentas de edição (`edit`), selecionar o menor bloco exato possível (`old_string` único e conciso). Nunca reescrever arquivos ou funções inteiras quando apenas algumas linhas mudaram.
- **Contexto Real e Diagnóstico de Erros:**
  - Diante de erros de compilação ou execução, inspecionar as linhas exatas da stack trace antes de alterar código. Proibido tentar adivinhar sem ler o arquivo real.
- **Injeção de Dependências Explícita:**
  - Proibido usar Service Locators globais ou Singletons arbitrários acoplados.
  - Dependências devem ser instanciadas na camada de composição (Main/Bootstrap) e injetadas explicitamente via construtor/parâmetro.
- **Rito de Modificação Seguro:**
  ```text
  Ler estado real -> Edição cirúrgica -> Compilar / Rodar testes locais (Fast Feedback)
  ```

---

## 6. Modularidade, Leitura e Quebra de Loops

- **Fronteira SRP e Arquivos Extensos:**
  - Arquivos extensos (>250 linhas) aumentam o risco de alucinação e cegueira de contexto.
  - Propor e aplicar o desmembramento em arquivos focados no pacote (ex.: em Go separar `models.go`, `interfaces.go`, `service.go` no mesmo pacote; em TypeScript separar `types.ts`, `schema.ts`, `service.ts`).
- **Leitura Cirúrgica:**
  - Em arquivos grandes, usar leituras paginadas com `offset` e `limit`. Proibido ler cegamente arquivos de milhares de linhas sem necessidade.
- **Quebra de Loop Imediata (Safety Valve):**
  - Se uma edição falhar 2 vezes seguidas ou o build quebrar repetidamente, **PARE IMEDIATAMENTE**.
  - Aborte novas tentativas cegas, gere um diagnóstico detalhado do erro e requisite alinhamento com o usuário no ambiente/IDE.

---

## 7. Governança e Versionamento Git

- **Conventional Commits:** Todo commit deve ser atômico, semântico e focado em uma única unidade lógica (`feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`).
- **Clean Branches:** Proibido comitar diretamente na branch principal (`main`/`master`). Todo desenvolvimento ocorre em branch efêmera/feature branch, com merge condicionado à aprovação dos testes e do portão de QA (`/qa-analyst`).
- **Shift-Left Security & Git Guardrails:**
  - Zero vazamento de segredos: chaves de API, senhas, certificados ou arquivos `.env` jamais entram no controle de versão.
  - Uso de hooks de pre-commit (Husky / lint-staged) e regras do `git-guardrails`.
