---
name: setup-skills
description: Provisiona a governanca documental do projeto e valida o GitHub como tracker obrigatorio antes do uso das skills de engenharia.
---

# Setup Skills

## Processo

### 1. Explorar

Verifique `git status`, `git remote -v`, `AGENTS.md` ou `CLAUDE.md`, `CONTEXT.md`, `docs/adr/` e `docs/agents/`.

### 2. Governanca GitHub

Este framework usa GitHub como fonte de Issues, rastreabilidade e revisao.

- Se nao houver Git, oriente a inicializacao local.
- Se nao houver remote GitHub, oriente a criacao do repositorio e a configuracao de `origin`.
- Valide acesso com `gh repo view` ou ferramenta equivalente.
- Nao configure tracker local como fallback silencioso.

### 3. Escolhas do projeto

Pergunte apenas o que ainda nao puder ser descoberto:

- vocabulario de triage, usando `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human` e `wontfix` como defaults;
- layout de dominio: `CONTEXT.md` + `docs/adr/` ou `CONTEXT-MAP.md`;
- convencoes de branches, testes e deploy.

### 4. Artefatos

Crie ou atualize, sem apagar conteudo existente:

- `AGENTS.md` ou `CLAUDE.md` com a secao `## Agent skills`;
- `CONTEXT.md` ou `CONTEXT-MAP.md`;
- `docs/agents/issue-tracker.md`;
- `docs/agents/triage-labels.md`;
- `docs/agents/domain.md`;
- `docs/adr/` quando houver decisoes arquiteturais.

Registre o remote GitHub e as escolhas feitas. A instalacao das skills ocorre pelo script do framework e nao deve ser presumida neste projeto.

### 5. Conclusao

Informe os arquivos criados, a URL do GitHub, o tracker configurado e os proximos passos. Se a pre-condicao GitHub falhar, encerre com instrucoes de desbloqueio.
