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

Se houver ações de **Tier 3 (Risco Alto)**, o Orchestrator DEVE interromper a execução e perguntar:

> **"Você aprova as tarefas de Tier 3 propostas? (sim / não / parcialmente)"**

Para tarefas de **Tier 1 (Baixo)** ou **Tier 2 (Médio)** executadas de forma automatizada ou agrupadas, o Orchestrator reporta no início da fase e solicita confirmação apenas como resumo formal de entrega final (Fase 4.3).

---

## Regras de Fragmentação (DAG & Atomização)

> **Regra de Ouro**: Uma tarefa atômica não deve durar mais que 10-15 minutos ou alterar mais do que 3 arquivos. Cada tarefa deve expor explicitamente suas dependências.

### Estrutura de Declaração de DAG (Grafo de Dependências):
Ao fragmentar o plano macro, o Orchestrator monta e persiste a modelagem no arquivo local `.claude/ESTADO_ORCHESTRATOR.md` seguindo o formato:

```markdown
### Tarefas
- [ ] T1: Configurar ambiente e scripts básicos (Tier 1) | depends_on: []
- [ ] T2: Implementar validador de domínio (Tier 2) | depends_on: [T1]
- [ ] T3: Alteração de schema Crítico (Tier 3) | depends_on: [T2]
```

O Orchestrator está livre para delegar tarefas com dependências resolvidas (ex: `depends_on: []` ou cujos pais estejam com status `completed`).

---

## Protocolo de Fila Sequencial e Gestão de Estado

O Orchestrator **nunca** gerencia tarefas apenas na memória curta. O estado persistido é rei.

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
