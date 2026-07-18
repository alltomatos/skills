---
name: to-issues
description: Transforma planos, specs, PRDs e Epics em GitHub Issues rastreaveis usando IDs estaveis, links diretos, slices verticais, dependencias e criterios de aceite verificaveis.
---

# To Issues

Use GitHub como tracker obrigatorio. Se o remote ou acesso nao estiver configurado, pare e invoque `/setup-skills`.

## Contrato de rastreabilidade de Epics

Cada Epic do `ORCHESTRATOR-ROADMAP.md` deve possuir:

1. um identificador estavel no formato `E10`, `E11`, `E12`;
2. uma GitHub Issue correspondente;
3. um link direto para essa Issue no titulo ou linha principal do roadmap;
4. descricao, estado e criterios de sucesso sincronizados com a Issue.

Formato obrigatorio no roadmap:

```markdown
## Epics

- [**[E10] Fundacao do produto**](https://github.com/OWNER/REPO/issues/101) - `in_progress`
- [**[E11] Fluxo de notificacoes**](https://github.com/OWNER/REPO/issues/102) - `todo`
```

O identificador `E##` nao pode ser reutilizado, mesmo quando uma Epic for concluida. O numero da Issue GitHub nao substitui o identificador da Epic: `E10` permanece estavel mesmo se a Issue for editada.

## Processo

1. Leia `ORCHESTRATOR-ROADMAP.md`, contexto, ADRs, requisitos e comentarios da Issue pai, quando houver.
2. Liste todas as Epics existentes e extraia seus IDs, estados e links.
3. Para cada Epic sem ID, atribua o proximo ID disponivel sem renumerar Epics existentes.
4. Para cada Epic sem link, localize a Issue correspondente por titulo, labels e corpo; se nao existir, crie uma Issue no GitHub.
5. Atualize o roadmap com o link direto no formato `[**[E10] Titulo**](URL)`.
6. Valide que nao restaram Epics sem ID, sem Issue ou sem link.
7. Divida a Epic aprovada em slices verticais completos, pequenos e verificaveis.
8. Marque cada slice como HITL ou AFK e defina dependencias.
9. Apresente a proposta ao usuario quando houver decisao de granularidade, risco ou arquitetura.
10. Publique as Issues em ordem de dependencia e use IDs reais no campo `Blocked by`.
11. Atualize a Issue da Epic com links para as slices filhas e mantenha o roadmap sincronizado.
12. Nunca feche ou altere uma Issue pai sem autorizacao explicita.

## Validacao obrigatoria

Antes de concluir, confirme:

```text
[ ] Todo Epic possui identificador E##
[ ] Todo Epic possui uma GitHub Issue
[ ] Todo Epic possui link direto no roadmap
[ ] Todo link aponta para /issues/<numero>
[ ] Nenhum ID de Epic esta duplicado
[ ] Issue da Epic referencia suas slices filhas
[ ] Estados do roadmap e GitHub estao coerentes
```

Se o roadmap estiver ausente, informe que nao ha Epics locais para mapear e nao invente Epics. Se o GitHub estiver indisponivel, pare antes de publicar ou declarar uma Epic como rastreada.

## Template da Issue de Epic

```markdown
## Epic

E10 - Nome da Epic

## Objetivo

Resultado de negocio ou tecnico esperado.

## Criterios de sucesso

- [ ] Criterio verificavel 1
- [ ] Criterio verificavel 2

## Slices

- [ ] #123 - Slice vertical 1
- [ ] #124 - Slice vertical 2

## Estado

todo | in_progress | done
```

## Template da Issue de slice

```markdown
## Parent

Epic: E10 - [link para a Issue da Epic]

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
