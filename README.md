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

Este repositório é um fork de [mattpocock/skills](https://github.com/mattpocock/skills). Todo crédito pela concepção e arquitetura original vai para **Matt Pocock**.

Este fork contém customizações específicas para o nosso fluxo de trabalho.

Minhas skills de agent que uso todo dia para fazer engenharia de verdade — não vibe coding.

Desenvolver aplicações reais é difícil. Abordagens como GSD, BMAD e Spec-Kit tentam ajudar assumindo o controle do processo. Mas ao fazer isso, elas tiram seu controle e tornam os bugs no processo difíceis de resolver.

Essas skills são projetadas para serem pequenas, fáceis de adaptar e compostas. Funcionam com qualquer modelo. São baseadas em décadas de experiência em engenharia. Hackeie, adapte, faça delas as suas. Aproveite.

Se quiser acompanhar mudanças nessas skills e as novas que eu criar, você pode se juntar a ~60.000 outros devs na minha newsletter:

[Inscreva-se na Newsletter](https://www.aihero.dev/s/skills-newsletter)

## Quickstart (setup em 30 segundos)

1. Execute o script de instalação para linkar as skills ao seu ambiente (suporta Claude Code e Hermes):

```bash
chmod +x scripts/setup-alltomatos-skills.sh
./scripts/setup-alltomatos-skills.sh
```

2. Execute o `/orchestrator` no seu agent. Ele garantirá que o ambiente esteja configurado (incluindo o uso do `/setup-skills` se for a primeira vez).
3. O `/orchestrator` guiará você pelo planejamento interativo (Roadmap, PRD e Domínio) antes de iniciar o desenvolvimento.

### Deploy das Skills em Novos Agentes

Para disponibilizar estas skills em um novo ambiente ou agente (ex: novo repositório ou outra instância do Hermes/Claude):

1. **Clone** o repositório em uma pasta local.
2. **Execute** `scripts/setup-alltomatos-skills.sh`.
3. O script detectará automaticamente se você está usando o ecossistema do Claude (`~/.claude/skills`) ou do Hermes (`~/.hermes/skills`) e criará os links simbólicos necessários.
4. **Verifique** a instalação executando `skills_list` dentro do seu agente.


## Primeiros Passos

Após instalar as skills, o ponto de entrada recomendado é o `/orchestrator`. Ele assume o controle do repositório, define a bússola estratégica via `/roadmap` e executa o ciclo de engenharia de forma autônoma.

### Fluxo de Trabalho (Engenharia de Ciclo Fechado)

1. **Estratégia**: Execute `/orchestrator`. Ele auditará o repositório e, se não houver um `ORCHESTRATOR-ROADMAP.md`, invocará o `/roadmap` para definir as Epics e Milestones com você.
2. **Execução Concorrente**: Com as Milestones definidas, o Orquestrador cria um grafo de tarefas (DAG) e despacha subagentes em paralelo com isolamento via **Git Worktrees** (`isolation: "worktree"`).
3. **Mapeamento e Anti-Alucinação**: O Orquestrador e os executores usam o `/query-docs` (via Context7) para resolver assinaturas reais e atualizadas de terceiros (Next.js, Prisma, Tailwind), com suporte a fallback de leitura de tipagem local (`*.d.ts`) caso offline.
4. **Qualidade (TDD) e Segurança**: O agente é obrigado a usar `/tdd` para codificação em ciclos RED/GREEN/REFACTOR e construir testes de ataque (`*.spec.sec.ts`) com o `/secure-e2e` (Playwright) para validação defensiva contra vulnerabilidades (OWASP).
5. **Portão de QA (obrigatório, sem exceção de Tier)**: Ao final de todo desenvolvimento — antes de qualquer PR — o `/qa-analyst` é invocado para analisar o código gerado, confrontar a implementação contra os requisitos originais e cobrir cenários de erro/comportamento inesperado. Bugs ou lacunas encontrados reabrem a DAG como novas tarefas.
6. **Integridade (Git Flow)**: Somente após o Portão de QA aprovar, o `/git-flow-pr-standard` é invocado para consolidar as branches e registrar o commit semântico.


## O Orchestrator

O `/orchestrator` é a **Skill Mestra** deste fork — um conceito que não existe no repositório original. Ele implementa um **Agentic Workflow Autônomo**: avalia, delega concorrentemente, fiscaliza e expande.

### Como funciona
O Orchestrator opera em modo de alta autonomia, utilizando uma DAG (Grafo Acíclico Direcionado) para fragmentar tarefas em pacotes atômicos:

- **Concorrência Segura (Worktrees)**: Despacha subagentes in paralelo para tarefas independentes sob isolamento de Git Worktree, defendendo a branch de trabalho local da máquina do usuário.
- **Auto-Bootstrap de Configuração**: Cria de forma silenciosa e atômica a pasta `./.claude/` local com variáveis de ambiente e cache do Context7 se ausentes.
- **Autonomia de Tier**: Tarefas de Tier 1 (Fast Path) e Tier 2 (Batch) são executadas sob validação local do TDD. Tier 3 (Bloqueante) exige consentimento pelo chat.
- **Fechamento de Ciclo**: Nenhum incremento de código é dado como pronto sem passar pelos suites de testes unificados, pelo Portão de QA obrigatório (`/qa-analyst`) e pelo protocolo `git-flow-pr-standard`.
- **Fiscalização**: Auditoria contínua de integridade estática e regressão.

### Regra de ouro

O Orquestrador **nunca** executa trabalho pesado diretamente. Ele é um arquiteto: identifica o problema e delega para a skill correta. Se não existe skill para o gargalo, ele invoca `/write-a-skill` para criá-la.

**Regra de Ouro do Roadmap:**
O Orquestrador deve validar toda tarefa delegada contra o `/roadmap`. Se uma tarefa não estiver mapeada em uma Milestone ativa, o Orquestrador deve pausar e invocar o `/grill-with-docs` para alinhar a estratégia.

### Tabela de delegação

| Problema | Skill |
| --- | --- |
| Governança & Orquestração | `/orchestrator` |
| Bússola Estratégica (Roadmap) | `/roadmap` |
| Análise de QA pós-desenvolvimento (obrigatório antes do PR, todos os Tiers) | `/qa-analyst` |
| Versionamento & PRs | `/git-flow-pr-standard` |
| Infraestrutura ausente | `/setup-skills` |
| Linguagem de domínio ausente | `/grill-with-docs` |
| Trabalhar em módulo/feature específico | `/grill-feature-with-docs` |
| Arquitetura degradada | `/improve-codebase-architecture` |
| Bug difícil ou regressão | `/diagnose` |
| Código sem testes | `/tdd` |
| Falta de contexto | `/zoom-out` |
| Gargalo não mapeado | `/write-a-skill` |
| Alinhamento antes de mudança | `/grill-me` |
| Handoff para outro agent | `/handoff` |

## Por Que Essas Skills Existem

Eu construí essas skills como forma de corrigir modos de falha comuns que vejo no Claude Code, Codex e outros coding agents.

### #1: O Agent Não Fez O Que Eu Queria

> "Ninguém sabe exatamente o que quer"
>
> David Thomas & Andrew Hunt, [The Pragmatic Programmer](https://www.amazon.co.uk/Pragmatic-Programmer-Anniversary-Journey-Mastery/dp/B0833F1T3V)

**O Problema**. O modo de falha mais comum em desenvolvimento de software é o desalinhamento. Você acha que o dev sabe o que você quer. Aí vê o que foi construído — e percebe que não entendeu nada.

Na era da IA é a mesma coisa. Existe uma lacuna de comunicação entre você e o agent. A correção para isso é uma **sessão de interrogatório** — fazer o agent te fazer perguntas detalhadas sobre o que você está construindo.

**A Solução** é usar:

- [`/grill-me`](./skills/productivity/grill-me/SKILL.md) - para usos não-relacionados a código
- [`/grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md) - mesmo que [`/grill-me`](./skills/productivity/grill-me/SKILL.md), mas com recursos adicionais (veja abaixo)
- [`/grill-feature-with-docs`](./skills/engineering/grill-feature-with-docs/SKILL.md) - para quando você quer trabalhar em um **módulo ou feature específico**: lê o código e a documentação existente, verifica se estão consistentes entre si, e conduz uma sessão de mentoria para definir a mudança antes de chamar o `/orchestrator`

Essas são minhas skills mais populares. Elas ajudam você a se alinhar com o agent antes de começar, e a pensar profundamente sobre a mudança que está fazendo. Use _sempre_ que quiser fazer uma mudança.

### #2: O Agent É Muito Verboso

> Com uma linguagem onipresente, conversas entre desenvolvedores e expressões do código são todas derivadas do mesmo modelo de domínio.
>
> Eric Evans, [Domain-Driven-Design](https://www.amazon.co.uk/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215)

**O Problema**: No início de um projeto, devs e as pessoas para quem estão construindo o software (os especialistas de domínio) geralmente falam línguas diferentes.

Senti a mesma tensão com meus agents. Agents costumam ser jogados num projeto e precisam decifrar o jargão por conta própria. Então usam 20 palavras onde 1 bastaria.

**A Solução** para isso é uma linguagem compartilhada. É um documento que ajuda os agents a decodificar o jargão usado no projeto.

<details>
<summary>
Exemplo
</summary>

Aqui está um exemplo de [`CONTEXT.md`](https://github.com/mattpocock/course-video-manager/blob/076a5a7a182db0fe1e62971dd7a68bcadf010f1c/CONTEXT.md), do meu repositório `course-video-manager`. Qual é mais fácil de ler?

- **ANTES**: "Há um problema quando uma aula dentro de uma seção de um curso se torna 'real' (ou seja, ganha um local no sistema de arquivos)"
- **DEPOIS**: "Há um problema com a cascata de materialização"

Essa concisão se paga sessão após sessão.

</details>

Isso está embutido no [`/grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md). É uma sessão de interrogatório, mas que ajuda você a construir uma linguagem compartilhada com a IA, e a documentar decisões difíceis de explicar em ADRs.

É difícil explicar o quão poderoso isso é. Pode ser a técnica mais legal deste repositório. Experimente e veja.

> [!TIP]
> Uma linguagem compartilhada tem muitos outros benefícios além de reduzir verbosidade:
>
> - **Variáveis, funções e arquivos são nomeados de forma consistente**, usando a linguagem compartilhada
> - Como resultado, a **base de código é mais fácil de navegar** para o agent
> - O agent também **gasta menos tokens pensando**, porque tem acesso a uma linguagem mais concisa

### #3: O Código Não Funciona

> "Sempre dê passos pequenos e deliberados. A taxa de feedback é o seu limite de velocidade. Nunca assuma uma tarefa grande demais."
>
> David Thomas & Andrew Hunt, [The Pragmatic Programmer](https://www.amazon.co.uk/Pragmatic-Programmer-Anniversary-Journey-Mastery/dp/B0833F1T3V)

**O Problema**: Digamos que você e o agent estão alinhados sobre o que construir. O que acontece quando o agent _ainda_ produz lixo?

É hora de olhar para seus loops de feedback. Sem feedback sobre como o código que produz realmente roda, o agent estará voando às cegas.

**A Solução**: Você precisa do conjunto habitual de loops de feedback: tipos estáticos, acesso ao browser e testes automatizados.

Para testes automatizados, um loop red-green-refactor é essencial. É quando o agent escreve um teste falhando primeiro, depois faz o teste passar. Isso dá ao agent um nível consistente de feedback que resulta em código muito melhor.

Eu construí uma **skill de [`/tdd`](./skills/engineering/tdd/SKILL.md)** que você pode encaixar em qualquer projeto. Ela incentiva red-green-refactor e dá ao agent bastante orientação sobre o que faz testes bons e ruins.

Para depuração, eu também construí uma skill de **[`/diagnose`](./skills/engineering/diagnose/SKILL.md)** que empacota as melhores práticas de debugging em um loop simples.


### #4: Construímos Uma Bola de Lama
> "Invista no design do sistema todo dia."
>
> Kent Beck, [Extreme Programming Explained](https://www.amazon.co.uk/Extreme-Programming-Explained-Embrace-Change/dp/0321278658)

**O Problema**: Aceleração da entropia. Como agents aceleram a codificação, eles aceleram a desordem.

**A Solução**: Design contínuo via `/improve-codebase-architecture` e guardrails arquiteturais.

### #5: O Risco do Desenvolvimento Autônomo
**O Problema**: Agentes autônomos sem bússola (Roadmap) e sem fiscalização (Git Flow) tendem a "viajar" no escopo, criando soluções complexas para problemas inexistentes.

**A Solução**: Governança em ciclo fechado. O Orquestrador só executa o que está no `/roadmap`, passa obrigatoriamente pelo Portão de QA (`/qa-analyst`) ao final de todo desenvolvimento, e só finaliza o que é validado pelo `/git-flow-pr-standard`.

### Resumo

Fundamentos de engenharia de software importam mais do que nunca. Essas skills são meu melhor esforço para condensar esses fundamentos em práticas repetíveis, para ajudar você a entregar os melhores apps da sua carreira. Aproveite.

## Referência

### Engineering

Skills que uso diariamente para trabalho com código.

- **[diagnose](./skills/engineering/diagnose/SKILL.md)** — Loop de diagnóstico disciplinado para bugs difíceis e regressões de performance: reproduzir → minimizar → hipotetizar → instrumentar → corrigir → teste de regressão.
- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)** — Sessão de interrogatório que desafia seu plano contra o modelo de domínio existente, afia terminologia e atualiza `CONTEXT.md` e ADRs inline.
- **[grill-feature-with-docs](./skills/engineering/grill-feature-with-docs/SKILL.md)** — Mentoria de módulo/feature: lê o código existente, resume o que o módulo faz, conduz sessão de perguntas e gera documentação (CONTEXT.md, CLAUDE.md, ADRs, docs/agents/) com handoff para o orchestrator.
- **[triage](./skills/engineering/triage/SKILL.md)** — Triagem de issues através de uma máquina de estados de papéis de triagem.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)** — Encontra oportunidades de aprofundamento na base de código, informado pela linguagem de domínio em `CONTEXT.md` e pelas decisões em `docs/adr/`.
- **[setup-skills](./skills/engineering/setup-skills/SKILL.md)** — Scaffolding da configuração por repositório (issue tracker, vocabulário de labels de triagem, layout de docs de domínio) que as outras skills de engineering consomem. Rode uma vez por repo antes de usar `to-issues`, `to-prd`, `triage`, `diagnose`, `tdd`, `improve-codebase-architecture` ou `zoom-out`.
- **[tdd](./skills/engineering/tdd/SKILL.md)** — Desenvolvimento orientado a testes com loop red-green-refactor. Constrói features ou corrige bugs um slice vertical por vez.
- **[to-issues](./skills/engineering/to-issues/SKILL.md)** — Decompõe qualquer plano, spec ou PRD em issues do GitHub independentes usando slices verticais.
- **[to-prd](./skills/engineering/to-prd/SKILL.md)** — Transforma o contexto da conversa atual em um PRD e o submete como issue do GitHub. Sem entrevista — apenas sintetiza o que você já discutiu.
- **[zoom-out](./skills/engineering/zoom-out/SKILL.md)** — Diz ao agent para zoom out e dar contexto mais amplo ou uma perspectiva de alto nível sobre uma seção de código desconhecida.
- **[scaffold-mvp](./skills/engineering/scaffold-mvp/SKILL.md)** — Executador tecnológico para repositórios vazios. Realiza bootstrap ágil (ex: Next.js + Tailwind + shadcn) imediatamente após a definição do domínio, focando em reuso de ecossistema e máxima produtividade.
- **[prototype](./skills/engineering/prototype/SKILL.md)** — Constrói um protótipo descartável para explorar um design — seja um app de terminal executável para questões de estado/lógica de negócio, ou várias variações radicais de UI ativáveis a partir de uma rota.
- **[roadmap](./skills/engineering/roadmap/SKILL.md)** — Define e agenda as metas estratégicas e sprints em um plano macro de desenvolvimento de software (Milestones).
- **[secure-e2e](./skills/engineering/secure-e2e/SKILL.md)** — Suíte de testes ponta a ponta (E2E) com Playwright focada em segurança. Simula e dispara ataques contra autenticação, injeções HTML/SQL e permissões dinâmicas (OWASP Top 10) sob testes negativos.
- **[qa-analyst](./skills/engineering/qa-analyst/SKILL.md)** — Analista de QA para o ciclo completo de qualidade: interroga requisitos antes do código, planeja e cria casos de teste (incluindo cenários de erro e comportamentos inesperados), executa testes, relata bugs com reprodução mínima e conduz análise de causa raiz para melhoria de processos.
- **[query-docs](./skills/engineering/query-docs/SKILL.md)** — Resolve a documentação ativa de bibliotecas e busca trechos de código autoritativos usando o Context7. Evita a alucinação de APIs desatualizadas no consumo de pacotes externos.
- **[orchestrator](./skills/engineering/orchestrator/SKILL.md)** — Mestra de agentes. Analisa o estado do repositório, garante conformidade da infraestrutura de skills, delega tarefas, gera novas sub-skills para gargalos não mapeados e força a invocação obrigatória do `/qa-analyst` ao final de todo desenvolvimento antes de qualquer PR.

### Productivity

Ferramentas de workflow gerais, não específicas de código.

- **[caveman](./skills/productivity/caveman/SKILL.md)** — Modo de comunicação ultra-comprimido. Corta ~75% do uso de tokens eliminando enchimento enquanto mantém precisão técnica total.
- **[grill-me](./skills/productivity/grill-me/SKILL.md)** — Seja interrogado implacavelmente sobre um plano ou design até que cada branch da árvore de decisão esteja resolvido.
- **[handoff](./skills/productivity/handoff/SKILL.md)** — Compacta a conversa atual em um documento de handoff para outro agent continuar o trabalho.
- **[write-a-skill](./skills/productivity/write-a-skill/SKILL.md)** — Cria novas skills com estrutura adequada, disclosure progressivo e recursos empacotados.

### Misc

Ferramentas que guardo, mas raramente uso.

- **[git-guardrails-claude-code](./skills/misc/git-guardrails-claude-code/SKILL.md)** — Configura hooks do Claude Code para bloquear comandos git perigosos (push, reset --hard, clean, etc.) antes da execução.
- **[migrate-to-shoehorn](./skills/misc/migrate-to-shoehorn/SKILL.md)** — Migra arquivos de teste de type assertions `as` para @total-typescript/shoehorn.
- **[scaffold-exercises](./skills/misc/scaffold-exercises/SKILL.md)** — Cria estruturas de diretório de exercícios com seções, problemas, soluções e explicadores.
- **[setup-pre-commit](./skills/misc/setup-pre-commit/SKILL.md)** — Configura hooks de pre-commit com Husky, lint-staged, Prettier, verificação de tipos e testes.
