# Skills Framework

Framework de skills para desenvolvimento assistido por agentes, com foco em vibecoding governado: alinhamento explicito, documentacao persistente, GitHub Issues, testes, QA e rastreabilidade.

Este repositorio e uma fonte de distribuicao. As skills nao sao instaladas dentro deste clone: o script cria links no ambiente do agent escolhido.

## O que o framework garante

- GitHub como fonte de governanca, Issues, revisao e historico;
- bootstrap de `AGENTS.md`/`CLAUDE.md`, `CONTEXT.md`, ADRs e `docs/agents/`;
- roadmap e linguagem de dominio antes de mudancas complexas;
- decomposicao em GitHub Issues por slices verticais;
- execucao isolada quando houver paralelismo;
- testes e portao obrigatorio de QA antes da entrega.

## Instalacao

Clone este repositorio e execute:

```bash
git clone <URL_DO_REPOSITORIO>
cd skills
chmod +x scripts/setup-alltomatos-skills.sh
./scripts/setup-alltomatos-skills.sh
```

O script pergunta onde instalar e aceita mais de um ambiente na mesma execucao:

1. Codex: `~/.codex/skills`
2. Claude: `~/.claude/skills`
3. Hermes: `~/.hermes/skills`
4. Outro caminho informado pelo usuario

Exemplo para instalar em Codex e Claude: informe `1 2`.

Se o agent usar outra pasta, escolha `4` e informe o caminho absoluto.

## Primeiro uso em um projeto

O projeto precisa estar versionado no Git e possuir um repositorio remoto no GitHub. Em um projeto novo:

```bash
git init
git add .
git commit -m "chore: initialize repository"
gh repo create <nome> --source . --remote origin --push
```

Depois, abra o projeto no agent e execute:

```text
/orchestrator
```

Em toda execucao, o orchestrator verifica o clone de origem associado as skills instaladas e seu remote GitHub para detectar commits novos. Se houver atualizacao, ele informa os commits e faz automaticamente o re-deploy nos ambientes em uso. Para executar manualmente, use `./scripts/setup-alltomatos-skills.sh --redeploy`.

Se o projeto estiver vazio, sem Git ou sem remote GitHub, o orchestrator deve parar e orientar a criacao do repositorio antes de qualquer implementacao.

## Fluxo recomendado

```text
GitHub remoto
    -> /setup-skills
    -> /roadmap + /grill-with-docs
    -> /scaffold-mvp ou auditoria existente
    -> /to-issues
    -> execucao com /tdd, /diagnose e /query-docs
    -> /secure-e2e quando aplicavel
    -> /qa-analyst
    -> PR e merge com aprovacao humana
```

O `/orchestrator` cria e atualiza a documentacao do projeto antes da fragmentacao. O `/to-issues` publica as slices aprovadas no GitHub; `ESTADO_ORQUESTRATOR.md` serve apenas como visao operacional da DAG.

## Skills por grupo

### Engineering

`orchestrator`, `setup-skills`, `roadmap`, `grill-with-docs`, `grill-feature-with-docs`, `to-issues`, `to-prd`, `scaffold-mvp`, `prototype`, `tdd`, `diagnose`, `query-docs`, `secure-e2e`, `qa-analyst`, `improve-codebase-architecture` e `zoom-out`.

### Productivity

`grill-me`, `handoff`, `write-a-skill` e `caveman`.

### Misc

`setup-pre-commit`, `git-guardrails-claude-code`, `migrate-to-shoehorn` e `scaffold-exercises`.

Skills em `personal/`, `in-progress/` e `deprecated/` nao sao instaladas pelo script.

## Governanca documental

O projeto consumidor deve manter:

- `AGENTS.md` ou `CLAUDE.md`;
- `CONTEXT.md` ou `CONTEXT-MAP.md`;
- `ORCHESTRATOR-ROADMAP.md`;
- `docs/agents/issue-tracker.md`;
- `docs/agents/triage-labels.md`;
- `docs/agents/domain.md`;
- `docs/adr/` para decisoes relevantes.

Consulte [`AGENTS.md`](./AGENTS.md), [`CONTEXT.md`](./CONTEXT.md) e [`docs/adr/`](./docs/adr/) para as regras deste framework.

## Compatibilidade

O manifesto principal esta em [`.claude-plugin/plugin.json`](./.claude-plugin/plugin.json). O instalador e independente do manifesto para permitir ambientes Codex, Claude, Hermes e caminhos customizados.
