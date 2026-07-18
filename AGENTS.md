# Governanca de Skills

Este repositorio distribui skills para desenvolvimento assistido por agentes. O clone e a fonte do framework; as skills devem ser instaladas nos ambientes dos agents por `scripts/setup-alltomatos-skills.sh`.

## Buckets

Skills sao organizadas sob `skills/`:

- `engineering/` - trabalho diario de codigo;
- `productivity/` - workflow geral;
- `misc/` - utilitarios mantidos, mas raramente usados;
- `personal/` - setup pessoal, nao distribuido;
- `in-progress/` - rascunhos, nao distribuido;
- `deprecated/` - skills descontinuadas, nao distribuido.

Skills distribuidas devem ter `SKILL.md`, aparecer no `README.md` e estar no manifesto `.claude-plugin/plugin.json` quando aplicavel.

## Instalacao

O script de instalacao pergunta onde instalar as skills e aceita Codex, Claude, Hermes ou caminho customizado. Uma instalacao pode atender mais de um agent CLI.

```bash
./scripts/setup-alltomatos-skills.sh
```

O re-deploy apos atualizacao pode ser executado sem interacao:

```bash
./scripts/setup-alltomatos-skills.sh --redeploy
```

## Contrato do Orchestrator

O `/orchestrator` deve:

1. verificar no inicio se o framework tem atualizacoes no remote GitHub;
2. localizar o clone de origem atraves das skills instaladas, mesmo quando o projeto consumidor nao possui clone do framework;
3. informar commits novos e fazer automaticamente o re-deploy nos ambientes em uso;
4. verificar Git local e remote GitHub do projeto consumidor;
5. bloquear o fluxo de implementacao quando nao houver repositorio GitHub configurado;
6. criar ou atualizar documentacao antes da implementacao;
7. usar `/roadmap`, `/grill-with-docs` e `/setup-skills` para estabelecer estrategia, dominio e governanca;
8. fragmentar trabalho aprovado usando `/to-issues` no GitHub;
9. manter `ESTADO_ORQUESTRATOR.md` como visao operacional, sem substituir as GitHub Issues;
10. executar verificacoes, exigir `/qa-analyst` antes de qualquer PR e reabrir tarefas quando QA encontrar gaps.

O orchestrator nao deve executar trabalho complexo diretamente quando uma skill especializada puder ser delegada.

## Governanca do projeto consumidor

Antes da implementacao, o projeto deve possuir:

- Git inicializado;
- remote GitHub acessivel;
- `AGENTS.md` ou `CLAUDE.md`;
- `CONTEXT.md` ou `CONTEXT-MAP.md`;
- `ORCHESTRATOR-ROADMAP.md`;
- `docs/agents/issue-tracker.md`;
- `docs/agents/triage-labels.md`;
- `docs/agents/domain.md`;
- `docs/adr/` quando houver decisoes relevantes.

GitHub e a fonte de Issues, rastreabilidade, revisao e historico. Nao usar tracker local como fallback silencioso.

## Fluxo de qualidade

O ciclo padrao e:

```text
GitHub -> documentacao -> roadmap -> GitHub Issues -> implementacao -> testes -> QA -> PR
```

TDD, diagnostico, testes E2E de seguranca e consulta de documentacao devem ser delegados para as skills correspondentes quando aplicavel. O portao de QA e obrigatorio para qualquer tier de risco.
