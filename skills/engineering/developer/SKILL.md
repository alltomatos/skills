---
name: developer
description: Governa projetos com agentes, audita pre-condicoes, cria documentacao, transforma gaps em GitHub Issues e coordena execucao, testes e QA.
---

# DEVELOPER - Central de Controle

Planeja, governa, audita e delega execucao. Nao execute tarefas complexas diretamente quando uma skill especializada existir.

## Fase - Atualizacao do framework

Esta verificacao deve ocorrer no inicio de toda execucao do developer, antes das pre-condicoes do projeto.

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
- Acao: deseja atualizar agora ou prosseguir sem atualizar?
```

6. Se houver commits novos, pergunte ao usuario se deseja atualizar agora ou prosseguir sem atualizar. Nao execute o re-deploy sem essa confirmacao explicita.
   - Se o usuario confirmar a atualizacao, execute o re-deploy das skills nos ambientes em uso. Use o instalador em modo nao interativo, por exemplo `scripts/setup-alltomatos-skills.sh --redeploy <diretorios-detectados>`. O re-deploy deve acontecer depois do `fetch`, sem sobrescrever backups existentes. Depois do re-deploy, confirme que `developer` aponta para a revisao nova e informe o resultado ao usuario antes de continuar.
   - Se o usuario optar por prosseguir sem atualizar, registre a decisao e continue o fluxo normalmente com a revisao atual.
8. Se nao houver mudancas, registre `Framework atualizado (<commit>)` sem interromper o fluxo.
9. Se nao for possivel localizar o clone, o remote ou a rede, informe `Nao foi possivel verificar atualizacoes do framework` e continue apenas se as skills locais estiverem disponiveis. Nao faca re-deploy sem confirmar uma revisao nova.

Quando uma revisao nova for confirmada, o re-deploy so ocorre mediante confirmacao explicita do usuario nesta mesma execucao — nunca automaticamente. Para uma instalacao inicial ou troca de ambientes, a decisao continua sendo explicita do usuario por meio de `scripts/setup-alltomatos-skills.sh`.

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
5. retornar ao developer.

Nao substitua o GitHub silenciosamente por tracker local. GitHub e a fonte de rastreabilidade, Issues, revisao e historico deste framework.

## Fase 1 - Provisionamento documental, arquitetura e estrategia

1. Se a arquitetura tecnica, ADD/SAD, C4, mockups ou design system ainda nao estiverem definidos, orientar ou invocar `/architect`.
2. Invocar `/roadmap` para criar ou atualizar `DEVELOPER-ROADMAP.md` e Epics.
3. Invocar `/grill-with-docs` para consolidar linguagem de dominio (`CONTEXT.md`, `docs/agents/`, `docs/adr/`) e decisoes arquiteturais.
4. Em repositorio vazio, invocar `/scaffold-mvp` apos o alinhamento de dominio e arquitetura.
5. Revisar e persistir a documentacao antes de iniciar implementacao.

Documentacao nao e uma etapa opcional: o developer deve deixar um estado compreensivel para outro agent continuar o trabalho.

### Caso especial - projeto novo com apenas um PRD na pasta

Quando o repositorio for inicializado a partir de uma pasta que contem somente um PRD (sem codigo):

1. Garantir repositorio GitHub inicializado, com remote `origin` configurado (Fase 0).
2. Criar e fazer checkout da branch `develop` a partir da branch padrao.
3. Transformar o PRD em Epics e registra-los como Issue(s) no GitHub (uma Issue por Epic, ou Issue mestre com os Epics listados).
4. Invocar `/to-issues` para fatiar cada Epic em Issues atomicas (slices verticais, rastreaveis, com criterios de aceite), registrando o mapeamento Epic -> Issues conforme Fase 3.
5. Seguir para a Fase 4 usando o modo de fila sequencial descrito abaixo.

## Fase 2 - Triage, Auditoria & Leitura dos Artefatos

1. **Triagem de Issues com `/triage`:**
   - Execute o `/triage` para auditar e organizar o estado das Issues do GitHub, classificar prioridades e preparar as tarefas para o ciclo de desenvolvimento.
2. **Leitura e Absorção dos Artefatos do Arquiteto:**
   - Leia rigorosamente todos os artefatos gerados pelo `/architect`:
     - ADD/SAD (`docs/architecture/ADD.md` ou `SAD.md`);
     - Decisões registradas em `docs/adr/`;
     - Design Tokens e Mockups em `design-system/MASTER.md` e `design-system/pages/`;
     - Diagramas C4, DERs e contratos de API.
3. **Checklist de Governança:**

```text
[ ] Git inicializado
[ ] Remote GitHub configurado e acessivel
[ ] AGENTS.md ou CLAUDE.md
[ ] CONTEXT.md ou CONTEXT-MAP.md
[ ] docs/architecture/ (ADD/SAD) e docs/adr/ produzidos pelo /architect
[ ] design-system/ e mockups prontos
[ ] docs/agents/ com tracker e labels
[ ] DEVELOPER-ROADMAP.md
[ ] Issues fatiadas no GitHub prontas para execução
```

Classifique gaps como P1 (seguranca/tipos), P2 (arquitetura), P3 (performance) ou P4 (higiene/documentacao). Use `/improve-codebase-architecture`, `/diagnose`, `/query-docs` ou `/zoom-out` conforme o caso.

## Fase 3 - Fragmentacao no GitHub

Os gaps aprovados devem ser transformados em Issues por `/to-issues`. O GitHub e a fonte persistente de escopo, criterios de aceite, dependencias e status; `ESTADO_DEVELOPER.md` e apenas a visao operacional da DAG.

1. Passe para `/to-issues` os gaps, roadmap e documentacao aprovados.
2. Apresente a decomposicao para aprovacao quando houver decisao HITL.
3. Publique as Issues em ordem de dependencia, usando IDs reais em `Blocked by`.
4. Registre o mapeamento `Tarefa -> Issue GitHub -> branch/worktree`.
5. Nunca crie uma DAG apenas em memoria ou apenas em arquivo local quando a tarefa puder ser rastreada no GitHub.

## Fase 4 - Execução em Loop com TDD

O developer trabalha nas Issues criadas pelo Arquiteto em **loop sequencial e ordenado** (respeitando o grafo de dependências e `Blocked by`), até que **todas as Issues do escopo sejam implementadas e fechadas**.

### Loop de Desenvolvimento por Issue:
1. **Seleção da Próxima Issue Desbloqueada:** Escolha a próxima Issue elegível na melhor ordem de dependência.
2. **Desenvolvimento Orientado a Testes com `/tdd`:**
   - **TDD Obrigatório:** Toda funcionalidade ou correção deve ser construída pelo ciclo Red-Green-Refactor do `/tdd` (escrever teste de unidade/integração que falha -> implementar a solução mínima -> refatorar mantendo os testes verdes).
   - Invoque skills especializadas complementares conforme o domínio:
     - `/query-docs` para APIs e bibliotecas de terceiros;
     - `/expo-expert` para stack Expo/React Native;
     - `/diagnose` diante de bugs ou regressões imprevistas.
3. **Validação Atômica:** Garanta que a suite de testes da Issue passou e que o build está íntegro.
4. **Fechamento da Issue & Avanço:** Faça o commit semântico (`feat:`, `fix:`), feche/atualize a Issue no GitHub e avance para a próxima Issue do loop até esgotar todas as pendências criadas pelo Arquiteto.

## Fase 5 - Verificação Final, Segurança e QA Completo

Quando **todas as Issues do escopo forem concluídas no loop**, o Developer deve obrigatoriamente submeter o resultado integrado para os dois gates de qualidade e segurança:

1. **Gate 1 - Testes E2E e Segurança com `/secure-e2e`:**
   - Executar os fluxos de ponta a ponta e testes de segurança/vulnerabilidade (OWASP, autenticação, autorização e regressão).
2. **Gate 2 - Garantia de Qualidade com `/qa-analyst`:**
   - O `/qa-analyst` deve confrontar todos os requisitos do ADD/SAD do `/architect`, as Issues fechadas, cobertura de testes e possíveis regressões.
   - Se o QA apontar qualquer inconformidade, reabra a Issue ou crie uma tarefa corretiva e reexecute o ciclo.
3. **Entrega / PR:** Somente após a aprovação com status verde de `/secure-e2e` e `/qa-analyst`, o Developer finaliza o trabalho e prepara o Pull Request para merge.
