# Orchestrator Delegation Protocol

> Templates e estruturas auxiliares para o `/orchestrator` v2.
> Importado por `SKILL.md` nas seções de Mentoria, Fragmentação e Fiscalização.

---

## Template: Modo Mentoria e Matriz de Risco

Para cada **GAP** identificado, o Orchestrator deve emitir o seguinte bloco estruturado:

```
🚨 GAP: [Nome descritivo e conciso do problema]
│
├── 📉 Impacto Negativo
│   └── [Risco técnico ou de negócio: ex: Quebra silenciosa de regras fiscais]
│
├── 💡 Melhor Prática da Indústria
│   └── [Prática de mercado recomendada: ex: TDD / Injeção via Construtor]
│
├── 🗺️ Plano de Ação Macro
│   └── [Objetivo final claro para o GAP]
│
└── 📋 Matriz de Resolução Proposta (Tiers de Risco)
    ├── [ ] Ação de Risco Alto (Tier 3) -> [x] REQUER APROVAÇÃO IMEDIATA
    ├── [ ] Ação de Risco Médio (Tier 2) -> [x] Batchado (Confirmação ao final)
    └── [ ] Ação de Risco Baixo (Tier 1) -> [x] Auto-Aplicável (Somente Logger)
```

---

## Gatilho de Aprovação por Risco

O Orquestrador possui autonomia de execução para tarefas Tiers 1 e 2. 
- **Tier 1 e 2:** Execução contínua. O Orquestrador agrupa o resultado e reporta apenas ao finalizar o bloco de trabalho ou se detectar falhas.
- **Tier 3 (Risco Alto):** O Orquestrador tentará a execução apenas se:
  1. O suite de testes (TDD) passar totalmente.
  2. A análise estática de tipos não reportar quebra de contrato.
  Caso ambos sejam verdadeiros, o Orquestrador assume o risco e prossegue, logando a decisão no `ESTADO_ORQUESTRATOR.md` como "DECISÃO AUTÔNOMA". Se houver falha, ele interrompe e solicita intervenção.

---

## Regras de Fragmentação (DAG & Atomização)

> **Regra de Ouro**: A autonomia é total. O Orquestrador fragmenta o plano macro em tarefas atômicas e identifica nós independentes no DAG.

### Delegação Paralela (Concorrência)
O Orquestrador pode delegar tarefas simultâneas desde que:
1. Sejam nós independentes no DAG (não dependam um do outro).
2. Não alterem o mesmo arquivo simultaneamente (evitar Race Conditions).
O limite de concorrência é gerenciado dinamicamente para manter a performance do ambiente sem corromper o contexto.

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

## Protocolo de Segurança (Fail-Fast)

1. **Auditoria de Existência**: Antes de qualquer delegação (ex: de `setup-skills` para `grill-with-docs`), o Orquestrador **deve** realizar uma verificação de arquivos (ex: `test -f CONTEXT.md && test -s CONTEXT.md`).
2. **Abordagem de Falha**: Se a verificação falhar, o Orquestrador **deve abortar** a cadeia de delegação, invocar o `/diagnose` para identificar o motivo da falha de persistência e solicitar intervenção humana.
3. **Deploy Automático**: Caso o projeto não possua a infraestrutura de skills (link simbólico), o Orquestrador deve invocar o script `scripts/setup-alltomatos-skills.sh` automaticamente na Fase 0 (Auditoria).
4. **Gatilho de Validação**: Após a execução da `setup-skills`, o Orquestrador deve verificar se os artefatos de integração (ex: `docs/agents/issue-tracker.md`) foram validados e criados em disco. Se não, deve invocar `/diagnose`.
5. **Governança de Setup**: O Orquestrador **nunca** deve invocar a `setup-skills` com flags de modo silencioso (`--silent` ou similares). O setup deve ser sempre uma experiência interativa e validada pelo usuário.
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

### 3. Protocolo de PR e Fechamento de Ciclo (Mandatário)
Para toda tarefa que resultar em alteração de código, o ciclo de conclusão **não** termina com o teste. O Orchestrator deve invocar obrigatoriamente a skill `git-flow-pr-standard` para garantir que as alterações sejam versionadas corretamente:
- [ ] O commit segue Conventional Commits?
- [ ] A branch seguiu o padrão `tipo/issue-descricao`?
- [ ] O template de PR foi preenchido?
- [ ] Nenhuma credencial/secreto foi exposta?
---


## Referência Rápida: Mapeamento GAP → Skill

| GAP Identificado | Skill Delegada | Tier de Risco |
|------------------|----------------|---------------|
| Testes ausentes ou frágeis | `/tdd` | Batch |
| Arquitetura degradada/acoplada | `/improve-codebase-architecture` | Batch |
| Bug/regressão | `/diagnose` | Block |
| Linguagem de domínio desalinhada | `/grill-with-docs` | Auto |
| Repositório vazio requer base técnica e frameworks para MVP ágil | `/scaffold-mvp` | Block |
| Não há skill para o gargalo | `/write-a-skill` | Block |
