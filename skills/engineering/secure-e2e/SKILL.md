---
name: secure-e2e
description: End-to-end and security-first testing suite using Playwright. Generates tests to validate user flows and actively challenge safety barriers, input validation, authentication and permissions. Use when user wants to write E2E tests, verify security requirements, or prevent regression of bugs/vulnerabilities.
---

# Secure E2E & Playwright CLI Protocol

> **Crédito**: Arquitetura original por Matt Pocock ([mattpocock/skills](https://github.com/mattpocock/skills)). Adaptado para incluir a cultura de Segurança por Design no fork alltomatos/skills.

A maioria dos testes de ponta a ponta (E2E) valida apenas o "caminho feliz" (Happy Path). Este protocolo estabelece que **testar segurança significa testar o caminho infeliz (Negative Testing)**. Se a aplicação diz que uma rota é restrita a administradores, devemos provar isso escrevendo um teste que tenta burlá-la e falha (portanto, retornando HTTP 403/401).

## Filosofia: Segurança por Design e Negativa

1.  **Testes de Segurança Ativos**: Todo novo fluxo de autenticação, formulário de entrada, ou rota de administração deve possuir um teste de segurança Playwright associado.
2.  **Não Confie no Cliente**: Nós testamos o front-end manipulando o DOM e requests locais, mas também validamos os efeitos colaterais na API interceptando e disparando requisições diretas em paralelo com o contexto do browser.
3.  **Clean Code nos Testes**: Evite testes frágeis acoplados à estrutura visual. Use seletores baseados em acessibilidade (`aria-label`, `role`) ou atributos de teste dedicados (`data-testid`).

## Convenção de Arquivos de Teste

Para diferenciar a intenção, divida seus arquivos de teste:
-   `*.spec.ts` ou `*.spec.func.ts` -> **Testes Funcionais**: Fluxos reais de usuário, validações de cliques, caminhos felizes do app.
-   `*.spec.sec.ts` -> **Testes de Segurança**: Tentativas de burlar regras, injeção de scripts (XSS), adulteração de formulários, Broken Authentication e ataques contra sessões.

---

## O Ciclo com Playwright CLI (`npx playwright`)

Os agentes devem executar tarefas E2E seguindo este fluxo lógico e disciplinado:

### 1. Inicializar e Mapear (Codegen)
Se o fluxo for complexo, o agente pode utilizar o gerador de código do Playwright para mapear seletores ou gravar caminhos básicos de clique:
```bash
npx playwright codegen http://localhost:3000
```
*Observação: O agente deve refatorar o código gerado pelo codegen para usar Page Objects ou seletores semânticos resilientes.*

### 2. Construir o Teste Negativo (Security Spec)
Os testes de segurança devem usar múltiplos contextos de navegador para validar que as fronteiras não vazam dados.
Exemplo:
-   **Contexto A (Admin)**: Faz login, obtém e armazena os tokens de sessão.
-   **Contexto B (Usuário Básico)**: Tenta ler recursos reservados do Admin simulando requisições com tokens corrompidos ou IDs de outros usuários (IDOR).

### 3. Rodar e Capturar Relatórios/Traces
Execute o suíte de testes apontando para os testes específicos criados:
```bash
npx playwright test --grep "@security"
```
Se o teste falhar por motivos desconhecidos, use o **Trace Viewer** para capturar o exato estado de tela e rede:
```bash
npx playwright show-trace path/to/trace.zip
```
O agente deve ler o output do trace para diagnosticar se o problema foi uma falha técnica (timeout) ou um erro real de segurança exposto.

## Anti-Padrões a Evitar

-   ❌ **Mocks Excessivos**: Não mocke a API em testes de segurança. Se você mockar a API que valida a role do usuário, você não está testando a segurança da aplicação, está apenas testando seu próprio mock.
-   ❌ **Verificação Visual apenas**: Validar que "o botão admin não aparece na tela" para um usuário básico não é segurança de verdade. O teste deve validar que, se aquele usuário tentar disparar a request HTTP direta ou navegar na URL de admin, ele receberá um bloqueio HTTP 403.
-   ❌ **Deixar Credenciais em Texto Plano**: Não commite senhas de teste no código dos arquivos `*.spec.ts`. Use variáveis de ambiente (`process.env.TEST_ADMIN_PASSWORD`) ou carregue credenciais seguras a partir de fixtures locais não versionadas.
