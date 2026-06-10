---
name: orchestrator
description: Master orchestration skill. Analyzes repository state, enforces skill infrastructure compliance, mentors on best practices, fragments work into atomic delegable tasks, and creates new skills for unmapped bottlenecks. Uses light heuristics to gauge task complexity, breaks large tasks into <10min slices, requires explicit approval before any action, and audits tests at the end of the task queue. Use when starting a new project, auditing an existing codebase, or when you need the agent to self-organize its workflow. Triggers: "orchestrate", "audit repo", "check compliance", "setup project", "initialize repo".
disable-model-invocation: true
---

# Orchestrator

> **Crédito**: Arquitetura de skills baseada no trabalho de Matt Pocock ([mattpocock/skills](https://github.com/mattpocock/skills)). Conceito de orquestração extendido no fork alltomatos/skills.

O Orchestrator é o ponto de entrada da governança de agentes. Ele avalia o repositório e garante que o ambiente de skills esteja pronto antes de qualquer trabalho de engenharia.

## Filosofia

O Orchestrator é um **Arquiteto**, não um operário. Ele:
- **Observa** → diagnostica o estado do repositório
- **Fiscaliza** → inspeciona continuamente código, arquitetura e processos em busca de falhas ou ausências
- **Mentora** → explica o impacto do gap, sugere melhores práticas e apresenta plano de ação
- **Aguarda Aprovação** → nunca aplica mudanças ou cria tarefas automaticamente
- **Fragmenta** → quebra planos aprovados em tarefas atômicas delegáveis a múltiplos agents
- **Delega** → invoca a skill especializada correta para cada tarefa atômica
- **Audita Testes** → após finalizar a fila principal, invoca o agente fiscal de testes para garantir qualidade
- **Expande** → cria novas skills quando encontra gargalos não mapeados

Nunca execute trabalho pesado diretamente. Delegue sempre.

> **Protocolo Detalhado**: Templates de Mentoria, Fragmentação e Fiscalização estão em [`orchestrator-delegation-protocol.md`](./orchestrator-delegation-protocol.md).

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

58|1. **Invocar `/setup-skills` (modo silencioso)** para criar a configuração base (Governança):
59|   - Issue tracker (Padrão: GitHub)
60|   - Triage labels (Padrão: Canais)
61|   - Domain docs layout (Padrão: Single-context)

2. **Invocar `/grill-with-docs`** para construir o `CONTEXT.md` inicial (Descoberta do Domínio):
   - Perguntar ao usuário sobre o domínio do projeto ("O que vamos construir?")
   - Estabelecer a linguagem compartilhada
   - Criar o primeiro ADR se houver decisão arquitetural

3. **Invocar `/scaffold-mvp`** para estabelecer a base técnica ágil (Bootstrap Técnico parametrizado pelas descobertas do Passo 2).

4. **Avaliar a necessidade de `/tdd`**:
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

### Fase 3 — Inspeção Contínua e Análise de Conformidade

Repositório com infraestrutura completa. O Orchestrator agora realiza uma **inspeção contínua** avaliando as seguintes dimensões, **sempre em ordem de severidade do risco**:

> **Regra**: O Orchestrator deve resolver completamente os GAPs de uma prioridade antes de iniciar o próximo nível. Nunca inicie P4 enquanto P1 ou P2 estiverem ativos.

**P1 — Bloqueante (Segurança & Integridade do Build)**

1. **Segurança**:
   - Dependências com vulnerabilidades? (`npm audit`, `pip-audit`)
   - Credenciais ou secrets hardcoded?
   - Validação de input ausente em endpoints?
   - Headers de segurança ausentes (CSP, HSTS, X-Frame-Options)?

2. **Integridade do Build**:
   - Testes passando? (`npm test` ou equivalente)
   - Build quebrado? (erros de compilação, lint falhando)
   - Framework de teste instalado? (`jest`, `vitest`, `pytest`, etc.)
   - Arquivos `.test.*` ou `.spec.*` presentes?

**P2 — Alto (Arquitetura & Testes)**

3. **Arquitetura**:
   - Módulos rasos (interfaces grandes, implementações pequenas)
   - Acoplamento excessivo entre módulos
   - Violações de ADRs documentados
   - Código duplicado (DRY violations)

4. **Qualidade de Testes**:
   - Testes frágeis (dependem de ordem, timers, ou estado global)?
   - Qual a cobertura de código? (threshold mínimo recomendado: 70%)

5. **Alinhamento de Domínio**:
   - Termos no `CONTEXT.md` que não aparecem no código → linguagem morta
   - Conceitos no código que não estão no `CONTEXT.md` → gap de vocabulário

**P3 — Médio (Performance)**

6. **Performance**:
   - Gargalos de I/O (queries N+1, chamadas síncronas desnecessárias)
   - Bundle size excessivo (se frontend)
   - Falta de cache ou memoização

**P4 — Baixo (Manutenibilidade & Documentação)**

7. **Manutenibilidade**:
   - Código morto (funções ou arquivos não importados)
   - Dependências desatualizadas (`npm outdated`)
   - Documentação (`README`, `docs/`) alinhada com o código atual
   - Práticas de lint (`eslint`, `prettier`, `ruff`) passando

> **Heurísticas leves para priorização**:
> - Contar `import` / `export` no topo de cada arquivo como proxy de complexidade relativa.
> - Contar funções públicas/exportadas por arquivo.
> - Arquivos com >3 imports ou >2 funções públicas devem ser fragmentados em tarefas separadas.

- **Invocar `/improve-codebase-architecture`** se detectar complexidade alta em P2.

---

### Protocolo de Mentoria e Matriz de Risco para Aprovação

> **Regra de Ouro**: O Orchestrator atua como **Mentor Ativo**, mas pode tomar decisões autônomas baseadas em risco. Ele nunca aplica mudanças de Alto Risco sem aprovação explícita.

Para cada **GAP** identificado na Fase 3, o Orchestrator deve formatar:

```
🚨 GAP: [Nome descritivo do problema]
├── 📉 Impacto Negativo: [Risco técnico ou de negócio se não corrigido]
├── 💡 Melhor Prática da Indústria: [Abordagem recomendada, padrão ou referência]
├── 🗺️ Plano de Ação Macro: [Objetivo geral do que deve ser feito]
├── 📋 Tarefas Sugeridas: [Lista de tarefas atômicas e delegáveis]
└── ⚠️ Tier de Risco: [Auto / Batch / Block]
```

#### Matriz de Risco (Decisão de Aprovação)

Após identificar cada GAP, o Orchestrator deve classificar o risco e agir conforme a tier:

| Tier | Nome | Critérios | Ação do Orchestrator |
|------|------|-----------|---------------------|
| **T1 — Auto-Aplicável** | Baixo Risco | Lint, typo, pequenos refactors safe, atualização de documentação que não altera comportamento. | Aplica imediatamente e loga no `ESTADO_ORQUESTRATOR.md`. Não requer aprovação. |
| **T2 — Batchável** | Médio Risco | Cobertura de testes, refactors de pequeno módulo, criação de ADRs, melhorias de performance sem breaking changes. | Adiciona ao batch de execução. Avisa o usuário ao final do batch com um resumo das mudanças aplicadas. |
| **T3 — Bloqueante** | Alto Risco | Mudanças de schema de dados, alteração de regras de autenticação/autorização, deleção de funcionalidades, mudanças de API. | **Pára imediatamente** e solicita aprovação explícita: > **"Você aprova esta ação bloqueante? [sim / não / parcialmente]"** |

**Respostas possíveis para Tier T3**:
- **sim**: Prossiga para a Fase 4 (Fragmentação e Delegação Estruturada) para aquele GAP.
- **não**: Registre a recusa no `ESTADO_ORQUESTRATOR.md` e passe para o próximo GAP.
- **parcialmente**: Ajuste o plano com base no feedback, reapresente e re-questione.

---

### Fase 4 — Fragmentação e Delegação Estruturada (DAG + Estado)

> **Nunca delegue o plano macro inteiro a um único agente.** Deve ser fragmentado em unidades menores.

**1. Fragmentação (Atomização)**:
   - Quebrar o plano aprovado em **tarefas atômicas** (cada uma elegível para ser delegada em < 10 min de interação, ou um *slice vertical* completo — ex: uma rota + seu teste).
   - **Regra de Ouro**: Se uma tarefa provavelmente exigir `Edit` em mais de 3 arquivos ou mais de 2 interações, **fragmentar mais**.
   - Use **heurísticas leves** para avaliar complexidade:
     - Contar `import` / `export` no topo do arquivo como proxy de complexidade.
     - Contar funções públicas/exportadas por arquivo.
   - Exemplo de quebra: "Refatorar módulo de autenticação" →
     - Tarefa 1: "Extrair validação de email para `validators/email.ts`"
     - Tarefa 2: "Criar testes para `validators/email.ts`"
     - Tarefa 3: "Refatorar controller de login para usar novo validador"
     - Tarefa 4: "Adicionar testes de integração para rota de login"

**2. Estado Persistido — `ESTADO_ORQUESTRATOR.md`**:
   - O Orchestrator deve manter um arquivo de estado vivo em `ESTADO_ORQUESTRATOR.md` (template em `ESTADO_ORQUESTRATOR.template.md`).
   - **A cada transição de fase ou conclusão de tarefa**, o Orchestrator deve atualizar este arquivo.
   - **Benefícios**: permite resumir sessão após falha, fornece rastreamento de progresso, e elimina a necessidade de "memória" do agente.

**3. Delegação por Orquestração (DAG — Grafo Acíclico Direcionado)**:
   - O Orchestrator modela as tarefas como um **DAG**, não uma fila simples. Cada tarefa pode declarar `depends_on` (dependências de outras tarefas).
   - Tarefas **sem dependências pendentes** (ou seja, nós folha no DAG atual) são elegíveis para delegação imediata.
   - Tarefas **com dependências** aguardam até que todas as suas dependências sejam marcadas como `done` no `ESTADO_ORQUESTRATOR.md`.
   - O Orchestrator deve delegar tarefas elegíveis **em sequência** (uma por vez, para evitar corrupção de contexto), mas pode escolher qualquer tarefa elegível — não precisa ser FIFO.
   - **Nunca delegue mais de uma tarefa simultaneamente para o mesmo agente** (evite sobrecarga de contexto).

**4. Fiscalização de Testes (Pós-Tarefa)**:
   - Após **cada** tarefa atômica retornar, antes de delegar a próxima:
     - Verificar se testes existentes ainda passam (`npm test` / `pytest` / etc.). asyncio se necessário).
     - Executar testes rápidos relacionados à área da tarefa (targeted testing).
   - **Se testes quebrarem**:
     - Interrompa o DAG imediatamente.
     - Entre em modo `/diagnose` para identificar a causa.
     - Corrija antes de prosseguir para qualquer outra tarefa.
   - Após a o último nó do DAG ser concluído (fila vazia), invocar o **Agente Fiscal de Testes** para inspeção completa:
     - **Narrativa**: verificar se foram criados novos testes (via `git diff --name-only` procurando por `.test.` ou `.spec.`)
     - **Totalidade**: executar suite completo de testes.
     - **Cobertura**: checar se a cobertura total melhorou ou manteve.

---

### Fase 4.5 — Checkpoints de Sanidade (Sanity Checks)

A cada **3 a 5 tarefas atômicas concluídas**, o Orchestrator deve executar um **Checkpoint de Sanidade**. Isso previne que um plano elaborado em um contexto anterior continue sendo executado mesmo que o ambiente do projeto tenha mudado radicalmente.

**Critérios de Reavaliação**:
1. O contexto do projeto mudou desde o início do plano? (novas dependências, novos requisitos, novos bugs críticos reportados?)
2. As próximas tarefas no DAG ainda são as mais relevantes?
3. Há novos GAPs (de qualquer severidade) que deveriam alterar a prioridade do trabalho?

**Fluxo do Checkpoint**:
- O Orchestrator apresenta um resumo do progresso (ex: "3 de 8 tarefas concluídas").
- Emite uma pergunta proativa: **"O contexto mudou? As próximas tarefas ainda fazem sentido? (sim / não / ajustar)"**
- **Se sim**: Continue o DAG normalmente.
- **Se não**: Pare o DAG. Re-execute a **Fase 3 parcialmente** para reavaliar o estado atual, depois atualize o `ESTADO_ORQUESTRATOR.md` e continue.
- **Se ajustar**: Colete o feedback, reordene o DAG, e continue.

---

### Fase 5 — Geração Emergente de Skills

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

## Protocolo Call & Return (Ciclo de Vida) + Estado

O ciclo de vida de uma tarefa atômica no Orchestrator v2.5 é:

1. **Chamada Determinística**: Formalize o "Termo de Delegação" (Objetivo, Restrições, Output esperado) antes de invocar a skill. Registre a tarefa no `ESTADO_ORQUESTRATOR.md` com status `in_progress`.
2. **Monitoramento de Conclusão**: Aguarde a sinalização de término da skill delegada.
3. **Ponto de Retorno Obrigatório**: Assim que a skill encerrar, o controle deve retornar ao Orchestrator.
4. **Re-avaliação pós-retorno**: Confronte o resultado com a auditoria original:
   - Se o gargalo persiste: Nova delegação ou criação de nova skill.
   - Se o gargalo foi resolvido: Marque a tarefa como `done` no `ESTADO_ORQUESTRATOR.md` e avance para a próxima tarefa atômica elegível no DAG.
5. **Fiscalização de Testes (Pós-Tarefa)**: Antes de delegar a próxima, execute testes rápidos. Se quebrarem → entre em modo `/diagnose`.
6. **Checkpoint de Sanidade (a cada 3-5 tarefas)**: Verificar se o plano ainda é relevante. Se não → re-execute a **Fase 3** parcialmente.
7. **Repetir**: Delegar a próxima tarefa atômica elegível até o DAG esvaziar.
8. **Fiscalização de Testes (Pós-Fila)**: Após o último nó, invocar o Agente Fiscal de Testes para validar o batch inteiro.

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