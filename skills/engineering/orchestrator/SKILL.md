---
name: orchestrator
description: Governa projetos com agentes, audita pre-condicoes, cria documentacao, transforma gaps em GitHub Issues e coordena execucao, testes e QA.
---

# ORCHESTRATOR - Central de Controle

Planeja, governa, audita e delega execucao. Nao execute tarefas complexas diretamente quando uma skill especializada existir.

## Fase - Atualizacao do framework

Esta verificacao deve ocorrer no inicio de toda execucao do orchestrator, antes das pre-condicoes do projeto.

1. Identifique de onde as skills foram instaladas. Para cada skill carregada, resolva o caminho real do link e procure o clone que contem `.claude-plugin/plugin.json` e `scripts/setup-alltomatos-skills.sh`.
2. No clone encontrado, leia o remote `origin`, a branch atual e o commit local instalado.
3. Consulte o remote do framework com `git fetch origin --quiet` ou mecanismo equivalente de leitura. Nunca faca `pull`, merge ou reset no clone do framework.
4. Compare o commit local com `origin/<branch>` ou com a referencia remota equivalente.
5. Se houver commits novos, informe imediatamente:

```text
Atualizacao do framework disponivel
- Framework: alltomatos/skills
- Instalado: <commit ou data>
- Disponivel: <commit ou data>
- Novidades: <resumo dos commits ou arquivos alterados>
- Acao: execute novamente o instalador apos revisar as mudancas
```

6. Se houver commits novos, informe a atualizacao disponivel e execute o re-deploy das skills nos ambientes em uso. Use o instalador em modo nao interativo, por exemplo `scripts/setup-alltomatos-skills.sh --redeploy <diretorios-detectados>`. O re-deploy deve acontecer depois do `fetch`, sem sobrescrever backups existentes.
7. Depois do re-deploy, confirme que `orchestrator` e `setup-skills` apontam para a revisao nova e informe o resultado ao usuario antes de continuar.
8. Se nao houver mudancas, registre `Framework atualizado (<commit>)` sem interromper o fluxo.
9. Se nao for possivel localizar o clone, o remote ou a rede, informe `Nao foi possivel verificar atualizacoes do framework` e continue apenas se as skills locais estiverem disponiveis. Nao faca re-deploy sem confirmar uma revisao nova.

Quando uma revisao nova for confirmada, o re-deploy e automatico e faz parte do contrato do orchestrator. Para uma instalacao inicial ou troca de ambientes, a decisao continua sendo explicita do usuario por meio de `scripts/setup-alltomatos-skills.sh`.

## Fase 0 - Pre-condicoes de governanca

Antes de criar arquivos ou delegar trabalho:

1. Verifique se o projeto tem Git inicializado.
2. Verifique se existe um remote GitHub valido, preferencialmente `origin`.
3. Verifique acesso ao repositorio com `gh repo view` ou mecanismo equivalente.

Se o ambiente estiver vazio, nao tiver Git ou nao tiver repositorio remoto no GitHub, pare o fluxo e oriente o usuario a:

1. criar o repositorio no GitHub;
2. inicializar o repositorio local;
3. configurar o remote `origin`;
4. fazer o primeiro commit e push;
5. retornar ao orchestrator.

Nao substitua o GitHub silenciosamente por tracker local. GitHub e a fonte de rastreabilidade, Issues, revisao e historico deste framework.

## Fase 1 - Provisionamento documental

1. Invocar `/setup-skills` para completar `AGENTS.md` ou `CLAUDE.md`, `CONTEXT.md`, `docs/agents/` e `docs/adr/`.
2. Invocar `/roadmap` para criar ou atualizar `ORCHESTRATOR-ROADMAP.md` e Epics.
3. Invocar `/grill-with-docs` para consolidar linguagem de dominio e decisoes arquiteturais.
4. Em repositorio vazio, invocar `/scaffold-mvp` apos o alinhamento de dominio.
5. Revisar e persistir a documentacao antes de iniciar implementacao.

Documentacao nao e uma etapa opcional: o orchestrator deve deixar um estado compreensivel para outro agent continuar o trabalho.

### Caso especial - projeto novo com apenas um PRD na pasta

Quando o repositorio for inicializado a partir de uma pasta que contem somente um PRD (sem codigo):

1. Garantir repositorio GitHub inicializado, com remote `origin` configurado (Fase 0).
2. Criar e fazer checkout da branch `develop` a partir da branch padrao.
3. Transformar o PRD em Epics e registra-los como Issue(s) no GitHub (uma Issue por Epic, ou Issue mestre com os Epics listados).
4. Invocar `/to-issues` para fatiar cada Epic em Issues atomicas (slices verticais, rastreaveis, com criterios de aceite), registrando o mapeamento Epic -> Issues conforme Fase 3.
5. Seguir para a Fase 4 usando o modo de fila sequencial descrito abaixo.

## Fase 2 - Auditoria

Verifique:

```text
[ ] Git inicializado
[ ] Remote GitHub configurado e acessivel
[ ] AGENTS.md ou CLAUDE.md
[ ] CONTEXT.md ou CONTEXT-MAP.md
[ ] docs/agents/ com tracker e labels
[ ] docs/adr/ quando houver decisoes relevantes
[ ] ORCHESTRATOR-ROADMAP.md
[ ] Skills instaladas no ambiente escolhido
```

Classifique gaps como P1 (seguranca/tipos), P2 (arquitetura), P3 (performance) ou P4 (higiene/documentacao). Use `/improve-codebase-architecture`, `/diagnose`, `/query-docs` ou `/zoom-out` conforme o caso.

## Fase 3 - Fragmentacao no GitHub

Os gaps aprovados devem ser transformados em Issues por `/to-issues`. O GitHub e a fonte persistente de escopo, criterios de aceite, dependencias e status; `ESTADO_ORQUESTRATOR.md` e apenas a visao operacional da DAG.

1. Passe para `/to-issues` os gaps, roadmap e documentacao aprovados.
2. Apresente a decomposicao para aprovacao quando houver decisao HITL.
3. Publique as Issues em ordem de dependencia, usando IDs reais em `Blocked by`.
4. Registre o mapeamento `Tarefa -> Issue GitHub -> branch/worktree`.
5. Nunca crie uma DAG apenas em memoria ou apenas em arquivo local quando a tarefa puder ser rastreada no GitHub.

## Fase 4 - Execucao

Use slices verticais pequenos. Tarefas independentes podem ser executadas em paralelo com worktrees isoladas. Tarefas que alterem schema, autenticacao, APIs publicas ou dados exigem confirmacao humana.

O orchestrator delega para skills especializadas, por exemplo:

- `/tdd` para implementacao orientada a testes;
- `/secure-e2e` para fluxos E2E e seguranca;
- `/diagnose` para bugs e regressao;
- `/query-docs` para APIs de terceiros;
- `/write-a-skill` para gargalos nao cobertos.

### Fila sequencial para Epics fatiados de um PRD

Quando as Issues vierem do caso especial "projeto novo com apenas um PRD" (Fase 1), a execucao **nao** e paralela: despachar **um unico agente por vez**, na ordem de dependencia das Issues.

1. Para o Epic atual, processar suas Issues fatiadas uma a uma: desenvolver -> QA (Fase 5) -> commit -> proxima Issue da fila. Repetir ate esgotar todas as Issues do Epic.
2. Epic esgotado -> abrir PR da branch de trabalho para `develop`.
   * PR verde (CI/testes passam) -> merge em `develop`.
   * PR falhar -> corrigir os problemas, reexecutar a verificacao e so entao mergear.
3. Apos o merge, voltar para a branch `develop` e avancar para o proximo Epic da fila, repetindo o loop ate que todos os Epics do PRD estejam finalizados.
4. Ao concluir todos os Epics, abrir o merge final de `develop` para `main`.

## Fase 5 - Verificacao e QA

Depois de cada tarefa, execute verificacoes proporcionais e registre evidencia. Se falhar, invoque `/diagnose` antes de continuar.

Quando a DAG estiver concluida, invoque obrigatoriamente `/qa-analyst`, sem excecao de tier. O QA deve confrontar requisitos, Issues, implementacao, testes, cenarios de erro e mudancas fora de escopo. Falhas reabrem Issues ou criam novas tarefas.

Somente depois da aprovacao do QA pode ocorrer a entrega por PR. Se nao existir uma skill de fluxo Git/PR instalada, descreva os passos e solicite confirmacao humana; nunca invoque uma skill inexistente.
