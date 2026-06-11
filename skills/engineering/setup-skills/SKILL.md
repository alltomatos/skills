---
name: setup-skills
description: Sets up an `## Agent skills` block in AGENTS.md/CLAUDE.md and `docs/agents/`. Run before first use of engineering skills.
---

# Setup Skills

> **Crédito**: Arquitetura original por Matt Pocock ([mattpocock/skills](https://github.com/mattpocock/skills)). Adaptado no fork alltomatos/skills.

Scaffold the per-repo configuration that the engineering skills assume:

- **Issue tracker** — where issues live (GitHub by default; local markdown is also supported out of the box)
- **Triage labels** — the strings used for the five canonical triage roles
- **Domain docs** — where `CONTEXT.md` and ADRs live, and the consumer rules for reading them

This is a prompt-driven skill, not a deterministic script. Explore, present what you found, confirm with the user, then write.

## Processo

### 1. Explore (Modo Interativo Obrigatório)
Esta skill opera exclusivamente no modo interativo para garantir que o planejamento e o alinhamento de contexto sejam validados pelo usuário. O modo silencioso foi removido para evitar atropelamentos no fluxo de engenharia.

Siga o fluxo abaixo:
...
- `git remote -v` and `.git/config` — is this a GitHub repo? Which one?
- `AGENTS.md` and `CLAUDE.md` at the repo root — does either exist? Is there already an `## Agent skills` section in either?
- `CONTEXT.md` and `CONTEXT-MAP.md` at the repo root
- `docs/adr/` and any `src/*/docs/adr/` directories
- `docs/agents/` — does this skill's prior output already exist?
- `.scratch/` — sign that a local-markdown issue tracker convention is already in use

- `.scratch/` — sign that a local-markdown issue tracker convention is already in use

### 3. Validação e Inicialização (Protocolo de Execução)

**Regra de Ouro**: A escolha do tracker não é apenas teórica. Após o usuário escolher o Issue Tracker (GitHub, GitLab ou Local), a skill **deve** validar a integração.

#### Fluxo de Execução Obrigatório:
1. **Teste de Conectividade**:
   - **GitHub**: O agente deve executar `gh repo view` para garantir que o repositório está clonado e autenticado.
   - **GitLab**: O agente deve testar a conexão com o repositório remoto via `git remote`.
   - **Local**: O agente deve garantir que a pasta `.scratch/` existe e é gravável.
2. **Provisionamento de Ferramentas (Deploy)**:
   - **Skills do Projeto**: O agente deve rodar obrigatoriamente `./scripts/setup-alltomatos-skills.sh` para garantir que o projeto tenha todas as skills necessárias.
   - **Context7**: O agente deve rodar `npx ctx7 setup` para garantir a inteligência contextual do projeto.
3. **Confirmação de Execução**: Se qualquer passo falhar, o agente deve interromper o setup e oferecer o `/diagnose`.
4. **Escrita de Artefatos**: Somente após o teste positivo, o agente deve gravar os arquivos de configuração em `docs/agents/`.

Assume the user does not know what these terms mean. Each section starts with a short explainer (what it is, why these skills need it, what changes if they pick differently). Then show the choices and the default.

**Section A — Issue tracker.**

> Explainer: The "issue tracker" is where issues live for this repo. Skills like `to-issues`, `triage`, `to-prd`, and `qa` read from and write to it — they need to know whether to call `gh issue create`, write a markdown file under `.scratch/`, or follow some other workflow you describe. Pick the place you actually track work for this repo.

Default posture: these skills were designed for GitHub. If a `git remote` points at GitHub, propose that. If a `git remote` points at GitLab (`gitlab.com` or a self-hosted host), propose GitLab. Otherwise (or if the user prefers), offer:

- **GitHub** — issues live in the repo's GitHub Issues (uses the `gh` CLI)
- **GitLab** — issues live in the repo's GitLab Issues (uses the [`glab`](https://gitlab.com/gitlab-org/cli) CLI)
- **Local markdown** — issues live as files under `.scratch/<feature>/` in this repo (good for solo projects or repos without a remote)
- **Other** (Jira, Linear, etc.) — ask the user to describe the workflow in one paragraph; the skill will record it as freeform prose

**Section B — Triage label vocabulary.**

> Explainer: When the `triage` skill processes an incoming issue, it moves it through a state machine — needs evaluation, waiting on reporter, ready for an AFK agent to pick up, ready for a human, or won't fix. To do that, it needs to apply labels (or the equivalent in your issue tracker) that match strings *you've actually configured*. If your repo already uses different label names (e.g. `bug:triage` instead of `needs-triage`), map them here so the skill applies the right ones instead of creating duplicates.

The five canonical roles:

- `needs-triage` — maintainer needs to evaluate
- `needs-info` — waiting on reporter
- `ready-for-agent` — fully specified, AFK-ready (an agent can pick it up with no human context)
- `ready-for-human` — needs human implementation
- `wontfix` — will not be actioned

Default: each role's string equals its name. Ask the user if they want to override any. If their issue tracker has no existing labels, the defaults are fine.

**Section C — Domain docs.**

> Explainer: Some skills (`improve-codebase-architecture`, `diagnose`, `tdd`) read a `CONTEXT.md` file to learn the project's domain language, and `docs/adr/` for past architectural decisions. They need to know whether the repo has one global context or multiple (e.g. a monorepo with separate frontend/backend contexts) so they look in the right place.

Confirm the layout:

- **Single-context** — one `CONTEXT.md` + `docs/adr/` at the repo root. Most repos are this.
- **Multi-context** — `CONTEXT-MAP.md` at the root pointing to per-context `CONTEXT.md` files (typically a monorepo).

### 3. Confirm and edit

Show the user a draft of:

- The `## Agent skills` block to add to whichever of `CLAUDE.md` / `AGENTS.md` is being edited (see step 4 for selection rules)
- The contents of `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md`

Let them edit before writing.

### 4. Write & Verify (Protocolo de Verificação Obrigatório)

**Regra de Ouro**: Nenhuma etapa do setup é considerada concluída até que o arquivo seja validado em disco.

Após cada operação de `write` ou `patch`:
1. **Verificação de Existência**: Execute imediatamente um `ls -la` no arquivo criado/editado.
2. **Validação de Conteúdo**: Execute um `cat` ou `read_file` para garantir que o conteúdo não está vazio ou corrompido.
3. **Abordagem de Falha (Fail-Fast)**: Se o arquivo não existir ou estiver vazio, **PARE O SETUP IMEDIATAMENTE** e reporte o erro. Não prossiga para o próximo passo se a fundação falhou.

O Orquestrador deve ser instruído a verificar o `ESTADO_ORQUESTRATOR.md` após o setup: se os arquivos em `docs/agents/` estiverem ausentes, o Orquestrador deve recusar o início de qualquer trabalho e reinvocar o setup.

The block:

```markdown
## Agent skills

### Issue tracker

[one-line summary of where issues are tracked]. See `docs/agents/issue-tracker.md`.

### Triage labels

[one-line summary of the label vocabulary]. See `docs/agents/triage-labels.md`.

### Domain docs

[one-line summary of layout — "single-context" or "multi-context"]. See `docs/agents/domain.md`.
```

Then write the three docs files using the seed templates in this skill folder as a starting point:

- [issue-tracker-github.md](./issue-tracker-github.md) — GitHub issue tracker
- [issue-tracker-gitlab.md](./issue-tracker-gitlab.md) — GitLab issue tracker
- [issue-tracker-local.md](./issue-tracker-local.md) — local-markdown issue tracker
- [triage-labels.md](./triage-labels.md) — label mapping
- [domain.md](./domain.md) — domain doc consumer rules + layout

For "other" issue trackers, write `docs/agents/issue-tracker.md` from scratch using the user's description.

### 5. Done

Tell the user the setup is complete and which engineering skills will now read from these files. Mention they can edit `docs/agents/*.md` directly later — re-running this skill is only necessary if they want to switch issue trackers or restart from scratch.
