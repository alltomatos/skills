# Orchestrator Delegation Protocol

> Templates e estruturas auxiliares para o `/orchestrator` v2.
> Importado por `SKILL.md` nas seções de Mentoria, Fragmentação e Fiscalização.

---

## Matriz de Autonomia de Delegação

O Orquestrador opera com base em **Tiers de Risco**. A autonomia é concedida conforme a natureza da tarefa:

### Tier 1: Rota Direta ("Fast Path" - Risco Mínimo)
O Orquestrador reconhece tarefas T1 (limpeza, documentações simples que não alteram lógica, refatorações safe e setups de ferramentas/linters) como elegíveis para o **Fast Path**:
- **Bypass de Processo**: Pula obrigatoriamente a atualização/auditoria de Roadmap estratégico global e as sessões burocráticas/extensivas de interrogatório via `/grill-with-docs` ou `/grill-me`.
- **Execução Atômica**: O Orquestrador planeja e executa a tarefa imediatamente de forma direta.
- **Guardrails de Qualidade Mandatórios**: O fluxo deve honrar rigorosamente o rito de TDD para assegurar que nada foi quebrado e acionar a skill `/git-flow-pr-standard` para garantir commit semântico correto.
- **Ação**: Executa silenciosamente → Loga no `ESTADO_ORQUESTRATOR.md` → Finaliza o PR da mudança atômica.

### Tier 2: Execução em Batch (Risco Médio)
- **Configuração de ambiente**: Instalação de linters e formatadores, instrumentação de cobertura de testes, criação de ADRs estruturais e melhorias de performance localizada sem breaking changes.
- **Burocracia Reduzida**: Exige alinhamento com o `/roadmap` ativo antes de rodar os batches, mas permite agregação de commits.
- **Ação**: Executa o lote sob guardrail do TDD → Loga no `ESTADO_ORQUESTRATOR.md` → Reporta no final do batch.

### Tier 3: Governança Estratégica (Interativa Obrigatória)
Para decisões que impactam o domínio do projeto, a autonomia é **suspensa**. O Orquestrador deve pausar, apresentar o plano e aguardar o "Go" humano.
- **Mudanças de Domínio**: Definição de modelos de dados, novas funcionalidades, mudanças de arquitetura macro (ex: mudar de Monólito para Microserviços).
- **Roadmap**: Qualquer alteração na direção estratégica, priorização de Epics ou definição de prazos.
- **Regras de Negócio**: Qualquer modificação que altere o comportamento da aplicação conforme a regra do usuário.
- **Ação**: Para o fluxo → Apresenta PRD/Roadmap → Aguarda aprovação do usuário.

---



## Gatilho de Aprovação por Risco

O Orquestrador possui autonomia diferenciada baseada na criticidade técnica:
- **Tier 1 (Fast Path):** Execução sem interrupção humana. Pula as etapas de interrogatório/grill e auditoria do Roadmap. Execução atômica e direta, validando apenas o TDD local e commits semânticos no Git Flow.
- **Tier 2 (Batchável):** Execução contínua do lote. O Orquestrador agrupa o resultado, requer verificação do Roadmap, e reporta apenas ao finalizar o bloco de tarefas ou se detectar falhas no TDD.
- **Tier 3 (Risco Alto):** Requer aprovação explícita inicial do plano geral de tarefas. Para tarefas individuais na execução do DAG, o Orquestrador tentará prosseguir autonomamente após o "Go" inicial apenas se:
  1. O suite de testes (TDD) passar totalmente.
  2. A análise estática de tipos não reportar quebra de contrato.
  Caso ambos sejam verdadeiros, o Orquestrador assume o risco e prossegue, logando a decisão no `ESTADO_ORQUESTRATOR.md` como "DECISÃO AUTÔNOMA". Se houver falha de validação, ele interrompe a execução do DAG imediatamente e solicita intervenção.

---

## Regras de Fragmentação (DAG & Atomização)

> **Regra de Ouro**: A autonomia é total. O Orquestrador fragmenta o plano macro em tarefas atômicas e identifica nós independentes no DAG.

### Delegação Paralela e Isolamento (Concorrência via Git Worktrees)
O Orquestrador pode e deve delegar tarefas simultâneas para otimizar o tempo de desenvolvimento, respeitando as seguintes diretrizes:

1. **Paralelismo da DAG**: Identifique tarefas independentes com dependências resolvidas no grafo e despache-as concorrentemente acionando múltiplos agentes executores em paralelo (ex: 2 subagentes operando em direções distintas).
2. **Uso de Git Worktree para Concorrência**: Sempre que a execução de tarefas paralelas for disparada, os subagentes associados **devem** rodar sob isolamento de worktree (`isolation: "worktree"`). Isso isola o ambiente de arquivos do usuário contra regressões sintáticas e conflitos no Git.
3. **Uso de Git Worktree por Tamanho de Atividade**: Mesmo no caso de uma única tarefa, se o tamanho da atividade envolver refatoração pesada de infra, transição de esquemas ou desenvolvimento de novos módulos inteiros (ou seja, tarefas que excedam a escrita de um único arquivo isolado ou demandem mais de 10 minutos de computação contínua), **instancie o subagente em uma worktree dedicada** para preservar a segurança da ramificação de desenvolvimento ativa do desenvolvedor.
4. **Resolução de Fusão (Merge)**: Ao finalizar as tarefas paralelas, o Orquestrador assume o papel de coletor das branches isoladas temporárias e executa a mesclagem estruturada (resolvendo conflitos se houverem) e valida a compilação geral da aplicação.

### Estrutura de Declaração de DAG (Grafo de Dependências):
Ao fragmentar o plano macro, o Orchestrator monta e persiste a modelagem no arquivo local `.claude/ESTADO_ORCHESTRATOR.md` seguindo o formato:

```markdown
### Tarefas
- [ ] T1: Configurar ambiente e scripts básicos (Tier 1) | depends_on: []
- [ ] T2: Implementar validador de domínio (Tier 2) | depends_on: [T1]
- [ ] T3: Alteração de schema Crítico (Tier 3) | depends_on: [T2]
```
O Orchestrator identifica tarefas elegíveis (dependências resolvidas) e pode disparar subagentes concorrentemente.
---

---

## Protocolo de Fila Sequencial e Gestão de Estado

O Orchestrator **nunca** gerencia tarefas apenas na memória curta. O estado persistido é rei.

### Guia de Delegação Rápida
O Orquestrador deve consultar esta tabela antes de disparar qualquer delegação:

| Problema | Skill |
| --- | --- |
| Governança & Orquestração | `/orchestrator` |
| Versionamento & PRs | `/git-flow-pr-standard` |
| Infraestrutura ausente | `/setup-skills` |
| Linguagem de domínio ausente | `/grill-with-docs` |
| Arquitetura degradada | `/improve-codebase-architecture` |
| Bug difícil ou regressão | `/diagnose` |
| Código sem testes | `/tdd` |
| Análise de QA pós-desenvolvimento (obrigatório antes do PR) | `/qa-analyst` |
| Falta de contexto | `/zoom-out` |
| Gargalo não mapeado | `/write-a-skill` |
| Alinhamento antes de mudança | `/grill-me` |
| Handoff para outro agent | `/handoff` |

---

### Ciclo de Execução do Gestor de Operações:

1. **Atualiza Estado**: O Orchestrator lê de/escreve em `.claude/ESTADO_ORCHESTRATOR.md` a cada tarefa concluída.
2. **Checa Bloqueios**: Identifica a próxima tarefa cujas dependências já foram finalizadas.
3. **Delegação e Retorno**:
   - Dispara a tarefa no agente/skill associada.
   - Aguarda conclusão.
4. **Sanity Checkpoint (A cada 3-5 conclusões)**:
   A cada 3 tarefas passadas à categoria de `completed`, o Orchestrator deve pausar para rodar a checklist de sanidade:
   ```checklist
   [ ] As premissas originais do projeto continuam válidas?
   [ ] Houve desvio técnico que necessita de replanejamento na DAG?
   [ ] Novas dependências ou GAPs de criticidade P1 surgiram durante a execução?
   ```
   *Se falhar*: Recalcula rotas, edita a DAG no arquivo de estado e reinicia a execução de forma controlada.

---

## Protocolo de Operação: Modo Eficiência (Qualidade e Validação)

A partir de agora, o Orquestrador opera em **Modo Eficiência**. O objetivo é zero retrabalho.

1. **Atraso Deliberado (The "Wait-and-Validate" Principle)**: Em vez de disparar delegações em paralelo, o Orquestrador deve esperar a confirmação completa da skill anterior (ex: `setup-skills`) antes de cogitar a próxima (ex: `grill-with-docs`).
2. **Qualidade em Tiers**:
   - **Fase de Setup**: Interatividade total. Nenhum comando é automatizado sem feedback positivo.
   - **Fase de Planejamento**: Obrigatório o uso do `roadmap` e `plan`. Nenhuma delegação de código ocorre sem o plano estar aprovado no `ORCHESTRATOR-ROADMAP.md`.
   - **Fase de Execução**: O foco é em atomicidade. Se uma tarefa complexa surgir, ela **deve** ser fatiada antes da execução.
3. **Paciência Estratégica**: É preferível perder 5 minutos a mais no setup do que ter que deletar e reconstruir arquivos por causa de falhas de contexto.
---

## Template: Fiscalização de Testes (Durante e Pós-Fila)

### 1. Checkpoint de Fila (Após cada tarefa que altere código)
Antes de marcar a tarefa como `completed` no estado, o Orchestrator deve validar o suite de teste localmente:
- A funcionalidade alterada possui testes? (verificado via `git diff` / `Read`)
- O runner de testes local (`npm test`, `pytest`, etc.) está verde?
Se falhar: Invocar `/diagnose` imediatamente na unidade afetada antes de passar para a próxima tarefa da DAG.

### 2. Fiscalização Pós-Fila (Conclusão Geral)
Após a última tarefa da DAG passar para `completed`, executa a fiscalização agregada final:
```checklist
[ ] Suite completa de testes passa?
[ ] Novos arquivos de teste (.test.* / .spec.*) foram criados/modificados?
[ ] A cobertura de código manteve ou aumentou em relação à baseline?
[ ] Nenhum teste flaky (falha intermitente) foi introduzido?
[ ] Nenhuma credencial/secreto foi exposta em arquivos de teste ou fixtures?
```
- Opcional: Gerar um resumo de impacto das mudanças.

### 3. Portão de QA (Mandatário, Pré-PR)
Para toda tarefa que resultar em alteração de código, o ciclo de conclusão **não** avança para o PR sem passar pela análise da skill `/qa-analyst`. Isso vale para **todos os Tiers**, incluindo Fast Path (T1) — não há bypass.
- [ ] `/qa-analyst` foi invocado sobre o diff/código gerado nesta tarefa?
- [ ] Requisitos originais foram confrontados com a implementação (ambiguidades? lacunas?)
- [ ] Casos de teste de erro/comportamento inesperado foram avaliados, não só o caminho feliz?
- [ ] Bugs encontrados pela análise de QA foram registrados e resolvidos (ou reabertos como nova tarefa na DAG) antes de prosseguir?

Falha neste portão -> **bloqueia** o avanço para o PR. O Orchestrator reabre a DAG com as tarefas de correção apontadas pela `/qa-analyst` e só prossegue após nova validação limpa.

### 4. Protocolo de PR e Fechamento de Ciclo (Mandatário)
Somente após o Portão de QA (item 3) ser aprovado, o Orchestrator deve invocar obrigatoriamente a skill `git-flow-pr-standard` para garantir que as alterações sejam versionadas corretamente:
- [ ] O commit segue Conventional Commits?
- [ ] A branch seguiu o padrão `tipo/issue-descricao`?
- [ ] O template de PR foi preenchido?
- [ ] Nenhuma credencial/secreto foi exposta?
---


## Referência Rápida: Mapeamento GAP → Skill

| GAP Identificado | Skill Delegada | Tier de Risco |
|------------------|----------------|---------------|
| Testes ausentes ou frágeis | `/tdd` | Batch |
| Fim de desenvolvimento — análise de QA obrigatória pré-PR | `/qa-analyst` | Mandatório (todos os Tiers) |
| Arquitetura degradada/acoplada | `/improve-codebase-architecture` | Batch |
| Bug/regressão | `/diagnose` | Block |
| Linguagem de domínio desalinhada | `/grill-with-docs` | Auto |
| Repositório vazio requer base técnica e frameworks para MVP ágil | `/scaffold-mvp` | Block |
| Não há skill para o gargalo | `/write-a-skill` | Block |
