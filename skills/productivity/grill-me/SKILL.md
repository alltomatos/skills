---
name: grill-me
description: Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree. Use when user wants to stress-test a plan, get grilled on their design, or mentions "grill me".
---

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask the questions one at a time.

If a question can be answered by exploring the codebase, explore the codebase instead.

### Agentic Workflow (Self-Delegation & Emergent Skills)
Se, durante a sessão, o plano exigir investigação técnica profunda, refatoração estrutural ou criação de componentes, o `/grill-me` deve delegar tarefas:

1. **Identificar a Skill**: Escolha a skill especializada correta (ex: `/diagnose`, `/tdd`, `/improve-codebase-architecture`).
2. **Contrato de Delegação**: Formalize a tarefa em um prompt claro (Objetivo, Restrições, Output).
3. **Execução**: Invoque o sub-agente (ou a skill) seguindo o protocolo de segurança definido no `/orchestrator` (DI Pura, Atomic Edits).
4. **Verificação**: Após a sub-tarefa, retome a entrevista focando no resultado obtido.

### Emergência de Novas Skills (Evolução)
Se durante a entrevista você identificar um padrão de trabalho, repetição técnica ou gargalo de conhecimento que nenhuma skill existente consegue resolver, o `/grill-me` deve atuar como Engenheiro de Ferramentas:

1. **Protocolo de Criação**: Formalize a necessidade de uma nova skill.
2. **Uso da Skill de Criação**: Invoque a skill `/write-a-skill` para estruturar a nova ferramenta.
3. **Padrões Obrigatórios**: Toda skill criada pelo `/grill-me` deve seguir obrigatoriamente:
   - Os protocolos do `/orchestrator` (Anti-Laziness, DI Pura, Atomic Edits).
   - Deve ser registrada no `plugin.json` e no `README.md` raiz.
   - Deve conter a atribuição de crédito ao fork `alltomatos/skills`.
