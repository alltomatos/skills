---
name: setup-skills
description: Sets up an `## Agent skills` block in AGENTS.md/CLAUDE.md and `docs/agents/`. Run before first use of engineering skills.
---

# Setup Skills

Provisionamento de configurações do agente por repositório.

## PROCESSO DIRETO

### 1. Explore (Pesquisa Inicial)
Identificar o ambiente atual (obrigatório modo interativo):
* `git remote -v` -> Repositório ativo e remoto correspondente.
* `AGENTS.md` ou `CLAUDE.md` na raiz -> seção `## Agent skills` ativa?
* `CONTEXT.md` ou `CONTEXT-MAP.md` na raiz.
* Pastas públicas: `docs/adr/`, `src/*/docs/adr/`, `docs/agents/`.
* Presença do diretório `.scratch/` (indicação de tracker local).

### 2. Escolha
Perguntar escolhas ao usuário:
* **Issue Tracker**:
  * GitHub: autenticar remotos.
  * GitLab: obter configurações.
  * Local markdown: usar arquivos sob `.scratch/<feature>/`.
  * Outros (Jira/Linear): armazenar fluxo livre de texto.
* **Triage Vociabulário** (Default se ausente):
  * `needs-triage` (eval)
  * `needs-info` (aguardando)
  * `ready-for-agent` (pronto ia)
  * `ready-for-human` (humano)
  * `wontfix` (morto)
* **Domain Layout**:
  * Single-context: `CONTEXT.md` + `docs/adr/` na raiz.
  * Multi-context: `CONTEXT-MAP.md` mapeando sub-pastas de contexto.

### 3. Validação e Deploy
* **Conectividade**: Testar `gh repo view` (GitHub) ou `git remote` (GitLab). Caso local, garantir pasta `.scratch/` gravável.
* **Provisionamento das Skills**: Verificar primeiro se `~/.claude/skills/` existe e contém ao menos `orchestrator` e `setup-skills`. Se já existirem, pular instalação — skills já estão no perfil do usuário. Somente se ausentes: localizar o repositório `alltomatos/skills` (ex: `~/dev/skills`) e rodar `./scripts/setup-alltomatos-skills.sh` a partir dele.
* **Context7**: Iniciar Context7 via `npx ctx7 setup` e gerar `.claude/context7.json` com dependências preliminares descobertas.
* **Health Check**: Verificar que `~/.claude/skills/` contém as skills esperadas (`ls ~/.claude/skills/`). Diretório ausente ou vazio -> redirecione para `/diagnose`.

### 4. Escrita dos Artefatos
Criar e salvar os seguintes arquivos após validação em `docs/agents/`:
* `issue-tracker.md` (github, gitlab ou local)
* `triage-labels.md`
* `domain.md`
Persistir configurações do projeto em `.claude/config.json` e o manifesto `.claude/context7.json` gerado.

### 5. Fim
Confirmar setup completo. Registrar na raiz do projeto `CLAUDE.md` ou `AGENTS.md` o bloco correspondente de `## Agent skills`.
