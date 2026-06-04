# alltomatos/skills

Coleção de skills de agent (slash commands e comportamentos) carregadas pelo Claude Code. Skills são organizadas em buckets e consumidas pela configuração por repositório emitida por `/setup-matt-pocock-skills`.

Fork de [mattpocock/skills](https://github.com/mattpocock/skills) — arquitetura original por Matt Pocock.

## Linguagem

**Issue tracker**:
A ferramenta que hospeda as issues de um repositório — GitHub Issues, Linear, uma convenção de markdown local em `.scratch/`, ou similar. Skills como `to-issues`, `to-prd`, `triage` e `qa` leem e escrevem nela.
_Evitar_: backlog manager, backlog backend, issue host

**Issue**:
Uma unidade rastreada de trabalho dentro de um **Issue tracker** — um bug, tarefa, PRD ou slice produzido por `to-issues`.
_Evitar_: ticket (usar apenas quando citando sistemas externos que os chamam de tickets)

**Triage role**:
Um label canônico de máquina de estados aplicado a uma **Issue** durante a triagem (ex: `needs-triage`, `ready-for-afk`). Cada papel mapeia para uma string de label real no **Issue tracker** via `docs/agents/triage-labels.md`.

**Skill**:
Uma unidade de instrução compostável que estende o comportamento do agent. Definida por um diretório contendo `SKILL.md` com frontmatter YAML. Pode ser persistente (ex: `/caveman`, `/localize-pt-br`) ou one-shot (ex: `/triage`, `/diagnose`).

**Bucket**:
Categoria de organização de skills — `engineering/`, `productivity/`, `misc/`. Skills em `personal/`, `in-progress/` e `deprecated/` são excluídas do pipeline de instalação.

## Relações

- Um **Issue tracker** contém muitas **Issues**
- Uma **Issue** carrega um **Triage role** por vez
- Uma **Skill** pertence a um **Bucket**
- **Skills** em `engineering/`, `productivity/`, `misc/` → listadas em `plugin.json` e `README.md`
- **Skills** em `personal/`, `in-progress/`, `deprecated/` → excluídas de `plugin.json` e `README.md`

## Ambiguidades sinalizadas

- "backlog" era usado para significar tanto a *ferramenta* que hospeda issues quanto o *corpo de trabalho* dentro dela — resolvido: a ferramenta é o **Issue tracker**; "backlog" não é mais usado como termo de domínio.
- "backlog backend" / "backlog manager" — resolvido: colapsados em **Issue tracker**.
- "skill" vs "plugin" — resolvido: **Skill** é a unidade atômica; o `plugin.json` é o manifest do repositório, não uma skill.
