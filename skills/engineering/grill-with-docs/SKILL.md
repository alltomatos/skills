---
name: grill-with-docs
description: Sessão de interrogatório que desafia seu plano contra o modelo de domínio existente, afia terminologia e atualiza CONTEXT.md e ADRs. Use sempre antes de iniciar mudanças estruturais.
---

# Grill with Docs

Esta skill é uma evolução do `/grill-me`, focada especificamente em manter a integridade da linguagem de domínio (`CONTEXT.md`) e do registro de decisões arquiteturais (`ADRs`).

## Quando usar

1. **Início de Feature**: Antes de escrever qualquer código, para garantir que os termos usados no PRD estão alinhados com o domínio.
2. **Mudança de Rumo**: Quando uma decisão técnica impacta a arquitetura existente.
3. **Refatoração**: Para garantir que a nova estrutura não viole princípios estabelecidos.

## Processo

### 1. Interrogatório
O agente deve fazer perguntas profundas sobre o que está sendo construído, focando em:
- Entidades envolvidas.
- Fluxos de dados.
- Trade-offs de performance e segurança.

### 2. Atualização de Domínio
Ao final da sessão, o agente deve sugerir atualizações para o arquivo `CONTEXT.md` se novos termos foram descobertos ou se os existentes mudaram de significado.

### 3. Registro de Decisões (ADR)
Se a discussão levar a uma decisão técnica significativa, um novo ADR deve ser criado em `docs/adr/` seguindo o template [ADR-FORMAT.md](./ADR-FORMAT.md).

## Saída Esperada
- Um entendimento claro do problema.
- `CONTEXT.md` atualizado (se necessário).
- Novos ADRs documentando decisões (se necessário).
