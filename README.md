<p>
<a href="https://www.aihero.dev/s/skills-newsletter">
<picture>
<source media="(prefers-color-scheme: dark)" srcset="https://res.cloudinary.com/total-typescript/image/upload/v1777382277/skills-repo-dark_2x.png">
<source media="(prefers-color-scheme: light)" srcset="https://res.cloudinary.com/total-typescript/image/upload/v1777382277/skill-repo-light_2x.png">
<img alt="Skills" src="https://res.cloudinary.com/total-typescript/image/upload/v1777382277/skill-repo-light_2x.png" width="369">
</picture>
</a>
</p>

# Skills Para Engenheiros de Verdade (Fork)

[![skills.sh](https://skills.sh/b/alltomatos/skills)](https://skills.sh/alltomatos/skills)

Este repositorio e um fork de [mattpocock/skills](https://github.com/mattpocock/skills). Todo credito pela concepcao e arquitetura original vai para **Matt Pocock** e para os contribuidores do projeto original.

Este fork adiciona governanca orientada a GitHub, documentacao persistente, planejamento por Issues, verificacao automatica do framework, re-deploy das skills e um portao obrigatorio de QA. A ideia e tornar o desenvolvimento com agents rapido sem perder rastreabilidade, feedback e controle humano.

As skills sao pequenas, compostas e adaptaveis. Funcionam com diferentes modelos e CLIs de agents. Hackeie, adapte e faca delas as suas.

## Quickstart

Nao e necessario clonar este repositorio. A instalacao pode ser executada diretamente:

```bash
curl -fsSL https://raw.githubusercontent.com/alltomatos/skills/main/scripts/setup-alltomatos-skills.sh | bash
```

O script pergunta em qual ambiente instalar e aceita mais de um destino:

| Opcao | Ambiente | Diretorio padrao |
| --- | --- | --- |
| `1` | Codex | `~/.codex/skills` |
| `2` | Claude | `~/.claude/skills` |
| `3` | Hermes | `~/.hermes/skills` |
| `4` | Outro CLI | caminho informado pelo usuario |

Para instalar em Codex e Claude, informe `1 2`. O script baixa o framework temporariamente, instala as skills nos ambientes escolhidos e nao cria um clone permanente.

### Instalacao a partir de um clone

Tambem e possivel usar um clone local:

```bash
git clone https://github.com/alltomatos/skills.git
cd skills
chmod +x scripts/setup-alltomatos-skills.sh
./scripts/setup-alltomatos-skills.sh
```

### Re-deploy das skills

Quando o `/orchestrator` detectar uma nova revisao, ele executara o re-deploy automaticamente. Para executar manualmente:

```bash
curl -fsSL https://raw.githubusercontent.com/alltomatos/skills/main/scripts/setup-alltomatos-skills.sh | bash -s -- --redeploy
```

Ou, a partir de um clone:

```bash
./scripts/setup-alltomatos-skills.sh --redeploy ~/.codex/skills ~/.claude/skills
```

As instalacoes existentes sao preservadas em backups quando necessario.

## Primeiro uso

Depois da instalacao, abra um projeto no agent e execute:

```text
/orchestrator
```

O projeto consumidor precisa estar versionado no Git e possuir um repositorio remoto no GitHub. Em um projeto novo:

```bash
git init
git add .
git commit -m "chore: initialize repository"
gh repo create <nome> --source . --remote origin --push
```

Se o ambiente estiver vazio, sem Git ou sem remote GitHub, o orchestrator deve parar e orientar esse processo antes de implementar qualquer coisa.

## Fluxo de trabalho: engenharia de ciclo fechado

1. **Atualizacao do framework**: o orchestrator localiza o clone de origem associado as skills instaladas, consulta o remote GitHub, informa commits novos e faz o re-deploy nos ambientes em uso.
2. **Governanca**: valida Git, remote GitHub, autenticacao e estado do projeto.
3. **Documentacao**: cria ou atualiza `AGENTS.md`/`CLAUDE.md`, `CONTEXT.md`, `docs/agents/`, ADRs e `ORCHESTRATOR-ROADMAP.md`.
4. **Estrategia**: usa `/roadmap` e `/grill-with-docs` para definir Epics, linguagem de dominio e decisoes.
5. **Fragmentacao**: usa `/to-issues` para publicar slices verticais no GitHub com criterios de aceite e dependencias.
6. **Execucao**: delega tarefas pequenas, usando worktrees para paralelismo seguro.
7. **Feedback**: usa `/tdd`, `/query-docs`, `/diagnose` e `/secure-e2e` conforme o risco.
8. **QA**: invoca `/qa-analyst` obrigatoriamente antes de qualquer PR, sem excecao de tier.
9. **Entrega**: somente apos QA aprovado, executa o fluxo de PR disponivel no ambiente com confirmacao humana.

O GitHub e a fonte persistente de Issues, escopo, criterios de aceite, dependencias, revisao e historico. `ESTADO_ORQUESTRATOR.md` e somente a visao operacional da DAG.

## O Orchestrator

O `/orchestrator` e a Skill Mestra deste fork, um conceito que nao existe no repositorio original. Ele avalia, documenta, delega, fiscaliza e expande o fluxo de engenharia.

### Regra de ouro

O orchestrator nao executa trabalho pesado diretamente. Ele identifica o problema e delega para a skill correta. Se nao existe skill para o gargalo, invoca `/write-a-skill` para cria-la.

### Tiers de risco

| Tier | Uso | Comportamento |
| --- | --- | --- |
| T1 | typo, lint, documentacao simples | execucao atomica e verificacao local |
| T2 | testes, pequenos ADRs, mudancas limitadas | valida roadmap e reporta evidencia |
| T3 | schema, autenticacao, dados ou API publica | pausa e exige aprovacao humana |

## Por que estas skills existem

### 1. O agent nao fez o que eu queria

O modo de falha mais comum e o desalinhamento. `grill-me`, `grill-with-docs` e `grill-feature-with-docs` conduzem uma sessao de perguntas para transformar intencao em requisitos, linguagem de dominio e decisoes registradas.

### 2. O agent e muito verboso

Uma linguagem compartilhada reduz ambiguidades, melhora nomes de arquivos e funcoes e torna a base de codigo mais navegavel. O `/grill-with-docs` registra essa linguagem em `CONTEXT.md` e ADRs. Consulte tambem o exemplo de [`CONTEXT.md`](https://github.com/mattpocock/course-video-manager/blob/076a5a7a182db0fe1e62971dd7a68bcadf010f1c/CONTEXT.md) do repositorio `course-video-manager` original.

### 3. O codigo nao funciona

O agent precisa de loops de feedback: tipos, browser, testes automatizados e reproducoes minimas. `/tdd` aplica red-green-refactor e `/diagnose` conduz o ciclo reproduzir, minimizar, hipotetizar, instrumentar, corrigir e testar regressao.

### 4. Construimos uma bola de lama

Agents aceleram a codificacao e tambem podem acelerar a entropia. `/improve-codebase-architecture` promove design continuo, limites claros e uma base mais testavel e navegavel.

### 5. Risco do desenvolvimento autonomo

Roadmap, GitHub Issues, documentacao, worktrees e QA formam um ciclo de governanca que limita deriva de escopo e torna as decisoes auditaveis.

## Tabela de delegacao

| Problema | Skill |
| --- | --- |
| Governanca e orquestracao | [`/orchestrator`](./skills/engineering/orchestrator/SKILL.md) |
| Roadmap e Epics | [`/roadmap`](./skills/engineering/roadmap/SKILL.md) |
| Setup documental | [`/setup-skills`](./skills/engineering/setup-skills/SKILL.md) |
| Linguagem de dominio e ADRs | [`/grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md) |
| Modulo ou feature especifica | [`/grill-feature-with-docs`](./skills/engineering/grill-feature-with-docs/SKILL.md) |
| Fragmentacao em GitHub Issues | [`/to-issues`](./skills/engineering/to-issues/SKILL.md) |
| PRD | [`/to-prd`](./skills/engineering/to-prd/SKILL.md) |
| Bug dificil ou regressao | [`/diagnose`](./skills/engineering/diagnose/SKILL.md) |
| Codigo sem testes | [`/tdd`](./skills/engineering/tdd/SKILL.md) |
| APIs de terceiros | [`/query-docs`](./skills/engineering/query-docs/SKILL.md) |
| E2E e seguranca | [`/secure-e2e`](./skills/engineering/secure-e2e/SKILL.md) |
| Analise de qualidade | [`/qa-analyst`](./skills/engineering/qa-analyst/SKILL.md) |
| Arquitetura degradada | [`/improve-codebase-architecture`](./skills/engineering/improve-codebase-architecture/SKILL.md) |
| Prototipo descartavel | [`/prototype`](./skills/engineering/prototype/SKILL.md) |
| Bootstrap de MVP | [`/scaffold-mvp`](./skills/engineering/scaffold-mvp/SKILL.md) |
| Falta de contexto | [`/zoom-out`](./skills/engineering/zoom-out/SKILL.md) |
| Gargalo nao mapeado | [`/write-a-skill`](./skills/productivity/write-a-skill/SKILL.md) |
| Alinhamento de plano | [`/grill-me`](./skills/productivity/grill-me/SKILL.md) |
| Handoff | [`/handoff`](./skills/productivity/handoff/SKILL.md) |

## Referencia de skills

### Engineering

Skills para trabalho diario com codigo: `diagnose`, `grill-with-docs`, `grill-feature-with-docs`, `triage`, `improve-codebase-architecture`, `setup-skills`, `tdd`, `to-issues`, `to-prd`, `zoom-out`, `scaffold-mvp`, `prototype`, `roadmap`, `secure-e2e`, `qa-analyst`, `query-docs` e `orchestrator`.

### Productivity

Skills de workflow geral: `caveman`, `grill-me`, `handoff` e `write-a-skill`.

### Misc

Skills mantidas para casos especificos: `git-guardrails-claude-code`, `migrate-to-shoehorn`, `scaffold-exercises` e `setup-pre-commit`.

Skills em `personal/`, `in-progress/` e `deprecated/` nao sao instaladas pelo script.

## Governanca documental

O projeto consumidor deve manter `AGENTS.md` ou `CLAUDE.md`, `CONTEXT.md` ou `CONTEXT-MAP.md`, `ORCHESTRATOR-ROADMAP.md`, `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md` e `docs/adr/` quando houver decisoes relevantes.

## Creditos e origem

Este projeto e um fork de [mattpocock/skills](https://github.com/mattpocock/skills). A arquitetura original, a inspiracao e grande parte das skills vieram de Matt Pocock. Consulte tambem a [newsletter de skills](https://www.aihero.dev/s/skills-newsletter) para acompanhar o trabalho original.
