---
name: tdd
description: Test-driven development with red-green-refactor loop. Use when user wants to build features or fix bugs using TDD, mentions "red-green-refactor", wants integration tests, or asks for test-first development.
---

# TDD - Test Driven Development

## PRINCÍPIO
Testar comportamento via interfaces públicas. Não testar detalhes de implementação. Testes devem resistir a refatoraçoes.
* **Bons testes (Integração)**: Exercitam fluxos por APIs públicas. Funcionam como especificação viva. 
* **Bad tests**: Acoplados a métodos privados ou mocks internos. Quebram se código interno muda mesmo sem alteração de comportamento.

*Exemplos em [tests.md](tests.md) e regras de mock em [mocking.md](mocking.md).*

## ANTI-PATTERN: HORIZONTAL SLICES
Proibido escrever todos os testes de uma vez antes de codificar.
* **Razão**: Testes em lote adivinham comportamento, testando tipo/shape em vez de valor de negócio.

## RITO DE EXECUÇÃO: VERTICAL SLICES

### 1. Scope (Alinhamento)
Mapear comportamentos críticos com usuário. Focar apenas em caminhos felizes e regras principais.

### 2. Tracer Bullet (Primeiro Fluxo)
Escrever UM teste para confirmar UM comportamento end-to-end:
```
RED:   Escrever teste para fluxo 1 -> teste quebra
GREEN: Código mínimo para passar -> teste passa
```

### 3. Loop Incremental
Para os comportamentos seguintes:
```
RED:   Novo teste -> quebra
GREEN: Código mínimo -> passa
```
* **Regras**: 1 teste por vez. Código apenas para passar teste atual. Não prever futuro.

### 4. Refactor
Em GREEN (passando):
* Eliminar duplicações.
* Ocultar complexidade por interfaces simples.
* Aplicar SOLID.
* **Regra Ouro**: Proibido refatorar em RED.

```checklist
[ ] Teste valida comportamento por API pública
[ ] Teste resiste a refatoramento interno
[ ] Código é o mínimo para aprovar teste
[ ] Sem features especulativas
```

## FECHAMENTO OBRIGATÓRIO
GREEN alcançado -> registrar a evidencia e aguardar o portão obrigatório de `/qa-analyst`. Só depois da aprovação do QA orientar o fluxo de PR disponível no ambiente:
* Commit semântico (`feat:`, `fix:`, `refactor:`).
* Branch organizada.
* Template de PR preenchido.
