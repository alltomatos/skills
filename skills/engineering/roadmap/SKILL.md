---
name: roadmap
description: Gerencia o estado estrategico e as Epics do projeto, mantendo IDs estaveis e links diretos para GitHub Issues. Deve ser consultado por qualquer skill de planejamento.
---

# Roadmap

Gerencie `ORCHESTRATOR-ROADMAP.md` como a bussola estrategica do projeto. O roadmap resume o plano; o GitHub Issue da Epic e a fonte detalhada de contexto e rastreabilidade.

## Estrutura obrigatoria

O arquivo deve conter:

1. **Epics**: grandes objetivos, cada um com ID estavel `E##` e GitHub Issue vinculada;
2. **Milestones**: marcos entregaveis compostos por tarefas;
3. **Estado**: `todo`, `in_progress`, `done`;
4. **Links**: sempre no formato `[**[E10] Titulo**](https://github.com/OWNER/REPO/issues/123)`.

## Fluxo

1. Leia o roadmap atual e liste todos os Epics.
2. Preserve IDs existentes e atribua o proximo ID disponivel a Epics novas.
3. Valide o remote GitHub e localize ou crie a Issue de cada Epic.
4. Atualize cada titulo para conter o identificador e o link direto.
5. Sincronize estado, objetivo e criterios de sucesso entre roadmap e Issue.
6. Valide duplicidades e links quebrados antes de concluir.

## Checklist de integridade

```text
[ ] Todo Epic tem ID E##
[ ] IDs nao se repetem
[ ] Todo Epic tem Issue GitHub
[ ] Todo Epic tem link direto /issues/<numero>
[ ] Nenhum Epic ficou sem link
[ ] Milestones apontam para Epics existentes
[ ] Estados refletem a realidade atual
```

Se `ORCHESTRATOR-ROADMAP.md` nao existir, crie-o somente depois de confirmar GitHub e o contexto do projeto. Se nao houver Epics, registre essa situacao; nao crie Epics ficticias.
