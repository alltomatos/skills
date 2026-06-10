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

1. Execute o instalador skills.sh apontando para este fork:

```bash
npx skills@latest add alltomatos/skills
```

2. Escolha as skills que quer, e em quais coding agents quer instalá-las. **Certifique-se de selecionar `/setup-skills`**.

3. Execute `/setup-skills` no seu agent. Ele vai:
- Perguntar qual issue tracker você quer usar (GitHub, Linear ou arquivos locais)
- Perguntar quais labels você aplica aos tickets quando faz triagem (`/triage` usa labels)
- Perguntar onde quer salvar os documentos que criarmos

4. Pronto — você está pronto para começar.

### Instalação alternativa (clone local)

Se preferir instalar diretamente a partir de um clone local:

```bash
git clone https://github.com/alltomatos/skills.git
cd skills
bash scripts/link-skills.sh
```

Isso cria symlinks em `~/.claude/skills/` apontando para cada skill do repositório local.

## Primeiros Passos

Após instalar as skills, o ponto de entrada recomendado é o `/orchestrator`. Ele avalia o estado do seu repositório e garante que tudo está pronto para o trabalho.

### Repositório novo (sem código)

1. Execute `/orchestrator` no seu agent
2. Ele detecta que o repositório está vazio e invoca automaticamente:
   - `/setup-skills` → configura issue tracker, labels e docs de domínio
   - `/grill-with-docs` → constrói a linguagem compartilhada (`CONTEXT.md`)
3. Ao final, seu repositório estará com toda a infraestrutura de governança pronta

### Repositório existente (com código)

1. Execute `/orchestrator` no seu agent
2. Ele audita a infraestrutura e identifica gaps
3. Para cada gap, delega para a skill especializada:
   - Falta `CONTEXT.md` → `/grill-with-docs`
   - Falta `docs/agents/` → `/setup-skills`
   - Arquitetura degradada → `/improve-codebase-architecture`
   - Código sem testes → `/tdd`
4. Gera um relatório de conformidade antes/depois


## O Orchestrator
### O Orchestrator

O `/orchestrator` é a **Skill Mestra** deste fork — um conceito que não existe no repositório original. Ele implementa um **Agentic Workflow Autônomo**: avalia, delega (concorrentemente), fiscaliza e expande.

### Como funciona
O Orchestrator opera em modo de alta autonomia, utilizando uma DAG (Grafo Acíclico Direcionado) para delegar tarefas a subagentes de forma paralela e validar resultados via integração TDD + Git-Flow.

- **Autonomia de Tier**: Tarefas de Tier 1 e 2 são executadas e monitoradas sem interrupção humana.
- **Fechamento de Ciclo**: Nenhum trabalho de código é considerado concluído sem passar pelo protocolo `git-flow-pr-standard`.
- **Fiscalização**: Auditoria contínua de testes e conformidade.

### Regra de ouro

O Orchestrator **nunca** executa trabalho pesado diretamente. Ele é um arquiteto: identifica o problema e delega para a skill correta. Se não existe skill para o gargalo, ele invoca `/write-a-skill` para criá-la.

### Tabela de delegação

| Problema | Skill |
| --- | --- |
| Governança & Orquestração | `/orchestrator` |
| Versionamento & PRs | `/git-flow-pr-standard` |
| Infraestrutura ausente | `/setup-skills` |
| Linguagem de domínio ausente | `/grill-with-docs` |
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

> "Invista no design do sistema _todo dia_."
>
> Kent Beck, [Extreme Programming Explained](https://www.amazon.co.uk/Extreme-Programming-Explained-Embrace-Change/dp/0321278658)

> "Os melhores módulos são profundos. Eles permitem que muita funcionalidade seja acessada através de uma interface simples."
>
> John Ousterhout, [A Philosophy Of Software Design](https://www.amazon.co.uk/Philosophy-Software-Design-2nd/dp/173210221X)

**O Problema**: A maioria dos apps construídos com agents são complexos e difíceis de mudar. Como agents podem acelerar radicalmente a codificação, eles também aceleram a entropia de software. Bases de código ficam mais complexas a uma taxa sem precedentes.

**A Solução** para isso é uma abordagem radical para desenvolvimento com IA: se importar com o design do código.

Isso está embutido em todas as camadas dessas skills:

- [`/to-prd`](./skills/engineering/to-prd/SKILL.md) te questiona sobre quais módulos você está modificando antes de criar um PRD
- [`/zoom-out`](./skills/engineering/zoom-out/SKILL.md) diz ao agent para explicar o código no contexto do sistema inteiro

E crucialmente, [`/improve-codebase-architecture`](./skills/engineering/improve-codebase-architecture/SKILL.md) ajuda você a resgatar uma base de código que se tornou uma bola de lama. Eu recomendo rodá-lo na sua base de código a cada poucos dias.

### Resumo

Fundamentos de engenharia de software importam mais do que nunca. Essas skills são meu melhor esforço para condensar esses fundamentos em práticas repetíveis, para ajudar você a entregar os melhores apps da sua carreira. Aproveite.

## Referência

### Engineering

Skills que uso diariamente para trabalho com código.

- **[diagnose](./skills/engineering/diagnose/SKILL.md)** — Loop de diagnóstico disciplinado para bugs difíceis e regressões de performance: reproduzir → minimizar → hipotetizar → instrumentar → corrigir → teste de regressão.
- **[git-flow-pr-standard](./skills/engineering/git-flow-pr-standard/SKILL.md)** — Protocolo obrigatório para versionamento, commits semânticos e abertura de PRs. Integrado automaticamente às skills de engenharia.
- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)** — Sessão de interrogatório que desafia seu plano contra o modelo de domínio existente, afia terminologia e atualiza `CONTEXT.md` e ADRs inline.
- **[triage](./skills/engineering/triage/SKILL.md)** — Triagem de issues através de uma máquina de estados de papéis de triagem.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)** — Encontra oportunidades de aprofundamento na base de código, informado pela linguagem de domínio em `CONTEXT.md` e pelas decisões em `docs/adr/`.
- **[setup-skills](./skills/engineering/setup-skills/SKILL.md)** — Scaffolding da configuração por repositório (issue tracker, vocabulário de labels de triagem, layout de docs de domínio) que as outras skills de engineering consomem. Rode uma vez por repo antes de usar `to-issues`, `to-prd`, `triage`, `diagnose`, `tdd`, `improve-codebase-architecture` ou `zoom-out`.
- **[tdd](./skills/engineering/tdd/SKILL.md)** — Desenvolvimento orientado a testes com loop red-green-refactor. Constrói features ou corrige bugs um slice vertical por vez.
- **[to-issues](./skills/engineering/to-issues/SKILL.md)** — Decompõe qualquer plano, spec ou PRD em issues do GitHub independentes usando slices verticais.
- **[to-prd](./skills/engineering/to-prd/SKILL.md)** — Transforma o contexto da conversa atual em um PRD e o submete como issue do GitHub. Sem entrevista — apenas sintetiza o que você já discutiu.
- **[scaffold-mvp](./skills/engineering/scaffold-mvp/SKILL.md)** — Executa o bootstrap técnico rápido de um novo repositório (ex: Next.js + Tailwind + shadcn/ui) baseado no domínio levantado pelo grill-with-docs. Prioriza bibliotecas de alta produtividade e proíbe invenção de código do zero.
- **[zoom-out](./skills/engineering/zoom-out/SKILL.md)** — Diz ao agent para zoom out e dar contexto mais amplo ou uma perspectiva de alto nível sobre uma seção de código desconhecida.
- **[scaffold-mvp](./skills/engineering/scaffold-mvp/SKILL.md)** — Executador tecnológico para repositórios vazios. Realiza bootstrap ágil (ex: Next.js + Tailwind + shadcn) imediatamente após a definição do domínio, focando em reuso de ecossistema e máxima produtividade.
- **[prototype](./skills/engineering/prototype/SKILL.md)** — Constrói um protótipo descartável para explorar um design — seja um app de terminal executável para questões de estado/lógica de negócio, ou várias variações radicais de UI ativáveis a partir de uma rota.
- **[orchestrator](./skills/engineering/orchestrator/SKILL.md)** — Mestra de agentes. Analisa o estado do repositório, garante conformidade da infraestrutura de skills, delega tarefas e gera novas sub-skills para gargalos não mapeados.

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
