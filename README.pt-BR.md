<p>
<a href="https://www.aihero.dev/s/skills-newsletter">
<picture>
<source media="(prefers-color-scheme: dark)" srcset="https://res.cloudinary.com/total-typescript/image/upload/v1777382277/skills-repo-dark_2x.png">
<source media="(prefers-color-scheme: light)" srcset="https://res.cloudinary.com/total-typescript/image/upload/v1777382277/skill-repo-light_2x.png">
<img alt="Skills" src="https://res.cloudinary.com/total-typescript/image/upload/v1777382277/skill-repo-light_2x.png" width="369">
</picture>
</a>

# Skills for Real Engineers (Fork)

[English](README.md) | [Português (Brasil)](README.pt-BR.md)

[![skills.sh](https://skills.sh/b/alltomatos/skills)](https://skills.sh/alltomatos/skills)

Este repositório é um fork de [mattpocock/skills](https://github.com/mattpocock/skills). Todo o crédito pelo design e pela arquitetura originais pertence a **Matt Pocock** e aos contribuidores do projeto.

Este fork adiciona governança baseada no GitHub, documentação persistente, planejamento por Issues, verificação automática do framework, redistribuição das skills e uma etapa obrigatória de QA. A ideia é tornar o desenvolvimento assistido por agentes rápido sem perder rastreabilidade, feedback e controle humano.

As skills são pequenas, combináveis e adaptáveis. Funcionam com diferentes modelos e CLIs de agentes. Adapte-as ao seu uso.

## Como usar (sem instalação)

O repositório é a fonte. Cole o link e peça as skills que deseja usar: não há instalador, clone permanente nem variável de ambiente.

```text
https://github.com/alltomatos/skills
```

| Onde você está | O que fazer |
| --- | --- |
| Claude Code | `/plugin marketplace add alltomatos/skills` e depois `/plugin install alltomatos-skills@alltomatos-skills` |
| Codex, OpenCode, Cursor, Gemini, Copilot e outras CLIs | `npx skills add alltomatos/skills` |
| Qualquer agente, sem CLI | Peça: "use as skills de https://github.com/alltomatos/skills - leia SKILLS.md e carregue apenas as que eu solicitar" |

`SKILLS.md` é o catálogo completo (nome, quando usar, caminho, URL raw e arquivos de suporte). `llms.txt` é o índice compacto que os agentes leem primeiro. Ambos são gerados a partir de `.claude-plugin/plugin.json`, a única fonte de verdade sobre quais skills são distribuídas.

### Idioma

As instruções das skills são escritas em **inglês**, em uma única versão. O idioma da resposta depende de quem está usando a skill: responda em português e produza em português tudo o que chegar à pessoa — PRDs, ADRs, relatórios de QA e mockups. Defina `output_language` no `AGENTS.md` do seu projeto para fixar o idioma. O contrato completo está em [`AGENTS.md`](AGENTS.md).

### Adicionar ou alterar uma skill

1. Crie a pasta em `skills/<bucket>/<name>/` com o `SKILL.md` e seus arquivos de suporte.
2. Adicione o caminho em `skills` no `.claude-plugin/plugin.json`.
3. Execute `node scripts/build-catalog.mjs` para regenerar `SKILLS.md` e `llms.txt`.

As skills em `skills/personal/` não são distribuídas nem aparecem no manifesto.

## Primeira execução

Com as skills carregadas, abra um projeto no seu agente e execute `architect` para alinhar o escopo, o design system e a arquitetura técnica:

```text
architect
```

A skill `architect` conduz a descoberta e o alinhamento de requisitos, cria mockups e artefatos de arquitetura e prepara a passagem para a execução.

O projeto que consome as skills precisa estar versionado no Git e ter um repositório remoto no GitHub. Para iniciar um projeto:

```bash
git init
git add .
git commit -m "chore: initialize repository"
gh repo create <name> --source . --remote origin --push
```

Se o ambiente estiver vazio, sem Git ou sem um remoto no GitHub, `architect`/`developer` deve interromper o fluxo e orientar a configuração antes da implementação.

## Fluxo de engenharia em ciclo fechado

1. **Atualização do framework**: verifica o repositório (clone local, quando disponível, ou GitHub) e informa novos commits. Para atualizar, adicione o marketplace novamente ou execute `npx skills add`.
2. **Governança e escopo**: valida Git, remoto do GitHub, autenticação e estado do projeto.
3. **Arquitetura e design (`architect`)**: alinha o escopo por meio de perguntas, projeta a solução (ADD/SAD, C4, ADRs, esquemas DER), define tokens de design e mockups (`MASTER.md` + overrides), guias do usuário e obtém a aprovação obrigatória da pessoa.
4. **Fatiamento em Issues (`to-issues`)**: divide os Epics e especificações aprovadas em entregas verticais, com critérios de aceitação verificáveis e dependências `Blocked by` no GitHub.
5. **Orquestração (`developer`)**: coordena a fila de tarefas e o ciclo de desenvolvimento de cada Issue, gerenciando branches e worktrees.
6. **Desenvolvimento orientado a testes (`tdd`)**: aplica o ciclo Red-Green-Refactor, com apoio de `query-docs`, `expo-expert` e `diagnose`.
7. **Garantia funcional da qualidade (`qa-analyst`)**: etapa obrigatória antes da segurança; confronta requisitos, casos extremos, testes funcionais e critérios de aceitação.
8. **Auditoria E2E e segurança (`secure-e2e`)**: etapa obrigatória antes do PR; audita o código (OWASP) e executa testes ofensivos/negativos no navegador e na API (`*.spec.sec.ts`).
9. **Entrega (PR)**: somente após QA e segurança aprovados, executa o fluxo de Pull Request com confirmação humana.

O GitHub é a fonte persistente para Issues, escopo, critérios de aceitação, dependências, revisão e histórico. `ESTADO_DEVELOPER.md` é apenas a visão operacional do DAG.

## A skill `developer`

`developer` é a skill principal deste fork (renomeada de `orchestrator`), um conceito que não existe no repositório original. Ela avalia, documenta, delega, supervisiona e expande o fluxo de engenharia.

`orchestrator` continua disponível como atalho de compatibilidade: chama a mesma skill e evita que instalações anteriores à renomeação deixem de funcionar.

### Regra de ouro

`developer` não executa diretamente trabalhos pesados. Identifica o problema e delega à skill adequada. Se nenhuma skill cobrir o gargalo, chama `write-a-skill` para criar uma.

### Níveis de risco

| Nível | Uso | Comportamento |
| --- | --- | --- |
| T1 | Correções de texto, lint e documentação simples | execução atômica e verificação local |
| T2 | Testes, ADRs pequenos e alterações limitadas | valida o roadmap e registra evidências |
| T3 | Esquema, autenticação, dados ou API pública | pausa e exige aprovação humana |

## Por que estas skills existem

### 1. O agente não fez o que eu queria

O desalinhamento é uma causa comum de falhas. `grill-me`, `grill-with-docs` e `grill-feature-with-docs` conduzem uma sessão de perguntas para transformar a intenção em requisitos, linguagem de domínio e decisões registradas.

### 2. O agente é prolixo

Uma linguagem compartilhada reduz ambiguidades e torna arquivos e funções mais fáceis de entender. `grill-with-docs` registra essa linguagem em `CONTEXT.md` e nos ADRs. Veja também o exemplo de [`CONTEXT.md`](https://github.com/mattpocock/course-video-manager/blob/076a5a7a182db0fe1e62971dd7a68bcadf010f1c/CONTEXT.md) do projeto original `course-video-manager`.

### 3. O código não funciona

O agente precisa de ciclos de feedback: tipos, navegador, testes automatizados e reproduções mínimas. `tdd` aplica Red-Green-Refactor; `diagnose` percorre o ciclo reproduzir, reduzir, formular hipótese, instrumentar, corrigir e testar a regressão.

### 4. Criamos um código difícil de manter

Agentes podem acelerar a entropia do código. `improve-codebase-architecture` promove evolução contínua da arquitetura, limites claros e maior facilidade de teste e navegação.

### 5. O risco do desenvolvimento autônomo

Roadmap, Issues do GitHub, documentação, worktrees e QA formam um ciclo de governança que limita desvios de escopo e torna as decisões auditáveis.

## Tabela de delegação

| Problema | Skill |
| --- | --- |
| Governança e orquestração | [`developer`](./skills/engineering/developer/SKILL.md) |
| Arquitetura de sistemas, ADD/SAD, C4, mockups/UI e ADRs | [`architect`](./skills/engineering/architect/SKILL.md) |
| Roadmap e Epics | [`roadmap`](./skills/engineering/roadmap/SKILL.md) |
| Triagem e gestão de Issues | [`triage`](./skills/engineering/triage/SKILL.md) |
| Linguagem de domínio e ADRs | [`grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md) |
| Um módulo ou recurso específico | [`grill-feature-with-docs`](./skills/engineering/grill-feature-with-docs/SKILL.md) |
| Fatiamento em Issues do GitHub | [`to-issues`](./skills/engineering/to-issues/SKILL.md) |
| PRD | [`to-prd`](./skills/engineering/to-prd/SKILL.md) |
| Bug difícil ou regressão | [`diagnose`](./skills/engineering/diagnose/SKILL.md) |
| Código sem testes | [`tdd`](./skills/engineering/tdd/SKILL.md) |
| APIs de terceiros | [`query-docs`](./skills/engineering/query-docs/SKILL.md) |
| Aplicativos Expo/React Native (EAS, Router, plugins de configuração e upgrades) | [`expo-expert`](./skills/engineering/expo-expert/SKILL.md) |
| E2E e segurança | [`secure-e2e`](./skills/engineering/secure-e2e/SKILL.md) |
| Análise de qualidade | [`qa-analyst`](./skills/engineering/qa-analyst/SKILL.md) |
| Arquitetura degradada | [`improve-codebase-architecture`](./skills/engineering/improve-codebase-architecture/SKILL.md) |
| Protótipo descartável | [`prototype`](./skills/engineering/prototype/SKILL.md) |
| Estrutura inicial de MVP | [`scaffold-mvp`](./skills/engineering/scaffold-mvp/SKILL.md) |
| Falta de contexto | [`zoom-out`](./skills/engineering/zoom-out/SKILL.md) |
| Servidores MCP | [`mcp-builder`](./skills/engineering/mcp-builder/SKILL.md) |
| Deploy e monitoramento do SuperKuma | [`superkuma-monitoring`](./skills/engineering/superkuma-monitoring/SKILL.md) |
| Hooks pre-commit com Husky/Prettier | [`setup-pre-commit`](./skills/misc/setup-pre-commit/SKILL.md) |
| Proteções de Git no agente | [`git-guardrails-claude-code`](./skills/misc/git-guardrails-claude-code/SKILL.md) |
| Criar, avaliar e otimizar skills | [`skill-creator`](./skills/productivity/skill-creator/SKILL.md) |
| Comunicação ultracompacta (economia de tokens) | [`caveman`](./skills/productivity/caveman/SKILL.md) |
| Gargalo sem mapeamento | [`write-a-skill`](./skills/productivity/write-a-skill/SKILL.md) |
| Alinhamento de plano | [`grill-me`](./skills/productivity/grill-me/SKILL.md) |
| Passagem de contexto | [`handoff`](./skills/productivity/handoff/SKILL.md) |

## Referência das skills

### Engenharia

Skills para o trabalho diário com código: `architect`, `diagnose`, `grill-with-docs`, `grill-feature-with-docs`, `triage`, `improve-codebase-architecture`, `tdd`, `to-issues`, `to-prd`, `zoom-out`, `scaffold-mvp`, `prototype`, `roadmap`, `secure-e2e`, `qa-analyst`, `query-docs`, `expo-expert`, `mcp-builder`, `superkuma-monitoring` e `developer`.

`architect` atua como arquiteto sênior de software, soluções e engenharia: projeta sistemas prontos para produção, alinha o escopo com perguntas, define tokens de design e mockups (padrão MASTER + Overrides), aplica rigor de engenharia (Clean Architecture, DDD, sem N+1, OWASP e zero regressões) e produz artefatos essenciais (ADD/SAD, modelo C4 em Mermaid, ADRs, esquemas DER/MER, contratos OpenAPI/gRPC e topologias de nuvem/infraestrutura).

`orchestrator` é um atalho de compatibilidade para a mesma skill `developer` (nome antigo, mantido para não quebrar instalações existentes).

`expo-expert` reúne conhecimento específico de Expo/React Native: CNG e plugins de configuração, Expo Modules API, EAS Build/Submit/Update/Workflows, Expo Router, Nova Arquitetura, animações (Reanimated/Skia), Native UI, componentes DOM, busca de dados e upgrades do SDK. Orienta o agente a consultar a documentação atual do Expo (`llms.txt` + `.md`) em vez de confiar em conhecimento desatualizado.

`mcp-builder` orienta a criação de servidores MCP (Model Context Protocol) de alta qualidade em Python (FastMCP) e Node/TypeScript, com schemas rigorosos, tratamento de erros voltado a agentes e scripts de avaliação e benchmark.

`superkuma-monitoring` cobre o ciclo completo de monitoramento SuperKuma: implantação de instância (VM Proxmox, Docker Compose + MariaDB), atualização de instâncias e operação do servidor MCP do SuperKuma para descobrir a infraestrutura de um site (AD, Proxmox, VMware, Linux, pfSense, Mikrotik, switches, UniFi, TrueNAS e câmeras) e transformá-la em monitores, tags, notificações e páginas de status.

### Produtividade

Skills de fluxo de trabalho geral: `caveman`, `grill-me`, `handoff`, `write-a-skill` e `skill-creator`.

`skill-creator` é uma meta-skill para criar, testar, avaliar (qualitativa e quantitativamente, com avaliações e visualizador HTML) e otimizar a precisão de ativação das descrições das skills.

### Miscelânea

Skills mantidas para casos específicos: `git-guardrails-claude-code`, `migrate-to-shoehorn`, `scaffold-exercises` e `setup-pre-commit`.

As skills em `personal/`, `in-progress/` e `deprecated/` não são distribuídas.

## Governança da documentação

O projeto que consome as skills deve manter `AGENTS.md` ou `CLAUDE.md`, `CONTEXT.md` ou `CONTEXT-MAP.md`, `DEVELOPER-ROADMAP.md`, `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md` e `docs/adr/` quando houver decisões relevantes.

## Créditos e origem

Este projeto é um fork de [mattpocock/skills](https://github.com/mattpocock/skills). A arquitetura original, a inspiração e boa parte das skills vieram de Matt Pocock. Consulte também a [newsletter de skills](https://www.aihero.dev/s/skills-newsletter) para acompanhar o projeto original.
