---
name: orchestrator
description: Master orchestration skill. Analyzes repository state, enforces skill infrastructure compliance, delegates work to specialized skills, and creates new skills for unmapped bottlenecks. Use when starting a new project, auditing an existing codebase, or when you need the agent to self-organize its workflow. Triggers: "orchestrate", "audit repo", "check compliance", "setup project", "initialize repo".
disable-model-invocation: true
---

# Orchestrator

> **Crédito**: Arquitetura de skills baseada no trabalho de Matt Pocock ([mattpocock/skills](https://github.com/mattpocock/skills)). Conceito de orquestração extendido no fork alltomatos/skills.

O Orchestrator é o ponto de entrada da governança de agentes. Ele avalia o repositório e garante que o ambiente de skills esteja pronto antes de qualquer trabalho de engenharia.

## Filosofia

O Orchestrator é um **Arquiteto**, não um operário. Ele:
- **Observa** → diagnostica o estado do repositório
- **Delega** → invoca a skill especializada correta
- **Expande** → cria novas skills quando encontra gargalos não mapeados

Nunca execute trabalho pesado diretamente. Delegue sempre.

## Fluxo de Execução

### Fase 1 — Auditoria de Infraestrutura

Execute esta checklist em sequência. Para cada item, registre ✅ (presente) ou ❌ (ausente).

```checklist
[ ] CLAUDE.md existe na raiz do repositório
[ ] CONTEXT.md existe na raiz (ou CONTEXT-MAP.md para multi-context)
[ ] docs/adr/ existe e contém pelo menos 1 ADR
[ ] docs/agents/ existe
[ ] docs/agents/issue-tracker.md existe
[ ] docs/agents/triage-labels.md existe
[ ] docs/agents/domain.md existe
[ ] CLAUDE.md contém bloco "## Agent skills"
[ ] .claude/skills/ existe e contém symlinks válidos
[ ] Git remote configurado (origin)
```

**Resultado da Fase 1:**

- **0–3 itens** → Repositório **novo/vazio** → ir para Fase 2A
- **4–7 itens** → Repositório **parcialmente configurado** → ir para Fase 2B
- **8–10 itens** → Repositório **em conformidade** → ir para Fase 3

### Fase 2A — Inicialização de Repositório Novo

Repositório vazio ou sem infraestrutura. O Orchestrator deve:

1. **Invocar `/setup-skills`** para criar a configuração base:
   - Issue tracker
   - Triage labels
   - Domain docs layout

2. **Invocar `/grill-with-docs`** para construir o `CONTEXT.md` inicial:
   - Perguntar ao usuário sobre o domínio do projeto
   - Estabelecer a linguagem compartilhada
   - Criar o primeiro ADR se houver decisão arquitetural

3. **Avaliar a necessidade de `/tdd`**:
   - Se o projeto terá código testável, sugerir configuração do loop red-green-refactor

4. **Relatório final**: Listar o que foi criado e quais skills estão prontas para uso.

### Fase 2B — Reparo de Repositório Parcial

Repositório com alguma infraestrutura, mas fora de conformidade. O Orchestrator deve:

1. **Para cada item ❌ na checklist**, determinar a skill responsável:
   - `CONTEXT.md` ausente → `/grill-with-docs`
   - `docs/agents/*` ausentes → `/setup-skills`
   - `## Agent skills` ausente no CLAUDE.md → `/setup-skills`
   - `.claude/skills/` vazio → instruir o usuário a rodar `npx skills@latest add alltomatos/skills`

2. **Invocar as skills na ordem de dependência**:
   - Primeiro `/setup-skills` (cria `docs/agents/`)
   - Depois `/grill-with-docs` (preenche `CONTEXT.md` e ADRs)

3. **Re-executar a checklist** após cada reparo para confirmar progresso.

4. **Relatório de conformidade**: Mostrar antes/depois.

### Fase 3 — Análise de Conformidade do Codebase

Repositório com infraestrutura completa. O Orchestrator agora avalia a **saúde do código**:

1. **Análise Arquitetural**: Em vez de invocar `/zoom-out` (que é protegido), o Orchestrator deve realizar a tarefa manualmente:
   - Use `Glob` para mapear a árvore de arquivos.
   - Use `Read` no README e `CLAUDE.md` para entender as fronteiras.
   - Delegue a análise para `/improve-codebase-architecture` se detectar complexidade alta.

2. **Invocar `/improve-codebase-architecture`** para identificar:
   - Módulos rasos que precisam de aprofundamento
   - Violações da linguagem de domínio em `CONTEXT.md`
   - ADRs conflitantes com a implementação atual

3. **Avaliar gaps de testes**:
   - Se o código não tem testes → sugerir `/tdd` para setup inicial
   - Se testes existem mas são frágeis → sugerir `/diagnose`

4. **Verificar alinhamento entre `CONTEXT.md` e o código**:
   - Termos no `CONTEXT.md` que não aparecem no código → linguagem morta
   - Conceitos no código que não estão no `CONTEXT.md` → gap de vocabulário

### Fase 4 — Geração Emergente de Skills

Se durante qualquer fase o Orchestrator identificar um gargalo **sem skill existente**:

1. **Documentar o gargalo**: O que é, onde aparece, qual o impacto.

2. **Invocar `/write-a-skill`** para criar uma sub-skill especializada:
   - Exemplo: repositório com muitas migrações de DB sem controle → criar skill `/migrate-safely`
   - Exemplo: código com padrões repetitivos de validação → criar skill `/validate-schema`

3. **Registrar a nova skill**:
   - Adicionar ao bucket correto (`engineering/`, `productivity/`, `misc/`)
   - Atualizar `plugin.json`
   - Atualizar `README.md` do bucket
   - Atualizar `README.md` raiz

4. **Criar ADR** documentando por que a skill foi necessária.

## Mapeamento de Skills (Registry)

O Orchestrator deve manter-se atualizado sobre as ferramentas disponíveis:
1. **Leitura de Registry**: Ao iniciar, o Orchestrator deve ler `.claude-plugin/plugin.json` para inventariar as skills instaladas nos buckets disponíveis.
2. **Consciência de Domínio**: Ele deve entender o propósito contido na `description` de cada skill lida para realizar a escolha correta.

## Protocolo Call & Return (Ciclo de Vida)

Para garantir que o fluxo de trabalho nunca se perca após a delegação:
1. **Chamada Determinística**: Invoque a skill apenas após formalizar o "Termo de Delegação" (Objetivo, Restrições, Output esperado).
2. **Monitoramento de Conclusão**: O Orchestrator deve aguardar a sinalização de término da skill delegada.
3. **Ponto de Retorno Obrigatório**: Assim que a skill delegada encerrar, o controle do fluxo deve retornar ao Orchestrator.
4. **Re-avaliação pós-retorno**: O Orchestrator deve confrontar o resultado obtido da skill delegada com a auditoria original:
   - Se o gargalo persiste: Nova delegação ou criação de nova skill.
   - Se o gargalo foi resolvido: Avançar para o próximo item da checklist.

## File Size Management & Anti-Loop Protocol (Divide and Conquer)

1. **LIMITE DE ARQUIVO (Modularity First):** Arquivos muito extensos causam "cegueira de contexto" e falhas na ferramenta de edição. Sempre prefira dividir estruturas em múltiplos módulos dentro do mesmo contexto lógico. Se um arquivo ultrapassar ~250 linhas, sugira proativamente o seu desmembramento.
2. **O PODER DA MODULARIZAÇÃO:** Dividir arquivos em pequenas partes lógicas melhora a manutenibilidade e não quebra referências. Use a modularidade da linguagem a nosso favor.
3. **LEITURA COM OFFSET (Targeted Reads):** Ao editar arquivos que ainda são grandes, NUNCA faça edições cegas baseadas na memória. Use obrigatoriamente a ferramenta `Read` delimitando linhas precisas (`offset` e `limit`) para capturar o estado real do código antes de disparar o `Edit`.
4. **QUEBRA DE LOOP (Human Takeover):** Se um `Edit failed` ocorrer duas vezes seguidas, ou se a compilação/linting/testes acusarem erros de sintaxe estrutural repetidamente: PARE IMEDIATAMENTE. Não tente adivinhar. Alerte o desenvolvedor para realizar uma intervenção manual no IDE e aguarde a confirmação de que o arquivo foi corrigido visualmente.

## Anti-Laziness & Strict Editing Rules

1. **ZERO PSEUDOCÓDIGO (No Code Laziness):** É estritamente proibido o uso de omissões textuais como `// ...`, `// resto do código aqui`, ou `// rotas anteriores` ao utilizar a ferramenta de `Edit` ou `Write`. Você deve fornecer o código real, completo e funcional em todas as substituições.
2. **EDIÇÕES CIRÚRGICAS (Atomic Edits):** Ao utilizar a ferramenta `Edit`, o bloco `old_string` deve ser o menor possível para isolar a mudança. Nunca inclua uma função inteira no `old_string` se você só precisa alterar a assinatura ou uma única linha interna. Isso evita a deleção acidental de blocos inteiros de código.
3. **PROIBIDO INVENTAR CONTEXTO:** Nunca tente adivinhar o conteúdo de um bloco `old_string`. Se o compilador apontar um erro, utilize obrigatoriamente a ferramenta `Read` nas linhas específicas do erro ANTES de tentar aplicar um `Edit`.
4. **DI PURA (Injeção via Construtor):** É proibido criar ou utilizar *Service Locators*, Containers Globais ou Singletons para Injeção de Dependência. Todas as dependências devem ser instanciadas no ponto raiz de entrada da aplicação e injetadas explicitamente via parâmetros em rotas, serviços ou construtores de classe. Isso garante testabilidade e visibilidade total do grafo de dependências.