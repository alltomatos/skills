---
name: secure-e2e
description: Suíte de testes E2E e segurança ofensiva/defensiva com Playwright e auditoria de código. Realiza auditoria estática e dinâmica de vulnerabilidades (OWASP), pensa como um atacante para encontrar brechas, gera testes de regressão de segurança (*.spec.sec.ts) e orienta a remediação do código. Use quando precisar auditar código em busca de falhas, criar testes de segurança, validar autenticação/permissões ou prevenir regressões.
---

# Secure E2E & Protocolo de Auditoria e Segurança Ofensiva/Defensiva

> **Crédito**: Arquitetura original inspirada por Matt Pocock ([mattpocock/skills](https://github.com/mattpocock/skills)). Expandido para incorporar cultura completa de Segurança por Design, Auditoria de Código e Testes Negativos Defensivos no framework `alltomatos/skills`.

A maioria dos testes de ponta a ponta (E2E) valida apenas o "caminho feliz" (Happy Path). Esta skill capacita o agente a **pensar com mentalidade de auditor/analista de segurança (White-Hat)**: investigar superfícies de ataque no código-fonte, descobrir vetores de falha, comprovar a vulnerabilidade via testes de segurança negativos automatizados (`*.spec.sec.ts`) e aplicar a correção definitiva no código.

---

## 1. Filosofia: Mentalidade de Atacante e Defesa em Profundidade

1. **Auditar Antes de Executar**: Analisar controllers, rotas, middlewares de autenticação, parsers de dados e queries de banco antes de criar testes.
2. **Testar o Caminho Infeliz (Negative Testing)**: Se uma rota exige perfil de administrador, o teste deve tentar burlá-la com múltiplos perfis e tokens forjados, garantindo que o servidor rejeite ativamente (HTTP 401/403).
3. **Não Confie no Cliente**: A interface pode esconder botões, mas a segurança real vive nas APIs. Todo teste deve validar o front-end manipulando o DOM/armazenamento local e, simultaneamente, disparar requisições diretas via API context (`request`).
4. **Ciclo Completo: Descobrir → Provar → Corrigir → Blindar**:
   - Descobre a vulnerabilidade no código ou arquitetura.
   - Escreve o teste negativo que reproduz e falha se a brecha existir (Red).
   - Corrige a vulnerabilidade na aplicação (Green).
   - Mantém o teste no suíte de regressão de segurança permanente (Refactor/Shield).

---

## 2. As Duas Frentes da Skill

### Frente A: Auditoria de Código e Threat Modeling
Ao inspecionar o código-fonte da aplicação, o agente audita:
- **Autenticação & Sessões**: Armazenamento de tokens (cookies `HttpOnly; Secure; SameSite` vs `localStorage`), expiração e fluxo de logout.
- **Autorização (RBAC/ABAC)**: Presença de middlewares de autorização em todas as rotas sensíveis; ausência de validação apenas por front-end.
- **Validação de Entrada e Tipagem**: Uso de schemas estritos (Zod, Joi, Yup), sanitização de HTML e prevenção de injeções.
- **Exposição de Dados e Segredos**: Ausência de segredos (`.env`, chaves privadas, senhas de teste) hardcoded no código ou expostos em endpoints públicos.
- **Abuso de Taxa (Rate Limiting)**: Proteção em endpoints de login, recuperação de senha, geração de tokens e envio de mensagens.

### Frente B: Testes Automatizados no Playwright (`*.spec.sec.ts`)
Para diferenciar a intenção dos testes no projeto:
- `*.spec.ts` ou `*.spec.func.ts` -> **Testes Funcionais**: Fluxos reais de usuário e caminhos felizes.
- `*.spec.sec.ts` -> **Testes de Segurança**: Tentativas automatizadas de bypass, injeção, CSRF, IDOR/BOLA e abuso de fluxo.

---

## 3. O Fluxo de Execução com Playwright CLI

```bash
# 1. Mapear formulários e seletores sensíveis (se necessário)
npx playwright codegen http://localhost:3000

# 2. Executar apenas os testes de segurança
npx playwright test --grep "@security"

# 3. Diagnosticar falhas ou vazamentos via Trace Viewer
npx playwright show-trace path/to/trace.zip
```

### Configuração Recomendada de Scripts (`package.json`)
```json
{
  "scripts": {
    "test:sec": "playwright test --grep \"@security\"",
    "test:sec:report": "playwright test --grep \"@security\" --reporter=html"
  }
}
```

---

## 4. Anti-Padrões a Evitar

- ❌ **Mocks em Validação de Acesso**: Nunca mocke permissões de usuário ou autenticação em testes de segurança. O teste deve bater contra os middlewares reais.
- ❌ **Apenas Validação Visual**: Validar que "o botão admin sumiu da tela" não comprova segurança. O endpoint subjacente deve retornar HTTP 403.
- ❌ **Credenciais Hardcoded**: Não utilize credenciais reais ou senhas estáticas no repositório. Utilize fixtures seguras e variáveis de ambiente (`process.env.TEST_USER_PASSWORD`).
- ❌ **Poluição da Base de Testes**: Garanta que payloads de injeção ou usuários criados em testes negativos sejam isolados ou limpos ao final (fixtures de teardown).
