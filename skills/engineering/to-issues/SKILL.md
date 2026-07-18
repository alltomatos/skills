---
name: to-issues
description: Transforma planos, specs e PRDs em GitHub Issues independentes usando slices verticais, dependencias rastreaveis e criterios de aceite verificaveis.
---

# To Issues

Use GitHub como tracker obrigatorio. Se o remote ou acesso nao estiver configurado, pare e invoque `/setup-skills`.

## Processo

1. Leia o roadmap, contexto, ADRs, requisitos e comentarios da Issue pai, quando houver.
2. Explore o codigo apenas o necessario para entender o estado atual.
3. Divida o trabalho em slices verticais completos, pequenos e verificaveis.
4. Marque cada slice como HITL ou AFK e defina dependencias.
5. Apresente a proposta ao usuario quando houver decisao de granularidade, risco ou arquitetura.
6. Publique as Issues em ordem de dependencia e use IDs reais no campo `Blocked by`.
7. Nunca feche ou altere uma Issue pai sem autorizacao explicita.

## Template

```markdown
## Parent

Referencias a Issue pai, quando aplicavel.

## What to build

Descricao concisa do comportamento completo da slice.

## Acceptance criteria

- [ ] Criterio verificavel 1
- [ ] Criterio verificavel 2

## Blocked by

- #123

## Verification

Comandos, testes ou evidencia esperada.
```
