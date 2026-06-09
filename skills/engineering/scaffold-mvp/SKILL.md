---
name: scaffold-mvp
description: Initialize a new project with an agile, high-productivity MVP stack. Use when starting a new project in an empty repository immediately after /grill-with-docs has defined the domain context. Do not build UI components or infrastructure from scratch—always use shared components and mature libraries.
---

# Scaffold MVP

## Gatilho
Ativada **apenas** em repositórios novos, logo após a execução do `/grill-with-docs` (que estabelece a linguagem compartilhada e o domínio).

## Regra de Ouro (Inviolável)
**É expressamente proibido construir componentes de UI base ou infraestrutura do zero.** 
O reuso de componentes compartilhados e de bibliotecas maduras focado em velocidade de prototipação é prioridade máxima e inegociável.

## Fluxo de Trabalho

### Fase 1: Ingestão de Contexto e Proposta Técnica (Bootstrap Alinhado)
Você não deve realizar "interrogatórios genéricos" sobre o negócio, pois o domínio já foi estabelecido pela skill predecessora.

1. **Leia obrigatoriamente** o `CONTEXT.md` e a pasta `docs/adr/`.
2. Baseado no domínio do negócio descoberto, elabore uma infraestrutura hiper-produtiva. Assuma uma postura consultiva e opinativa a favor da velocidade.
3. Se o contexto sugerir uma aplicação web padrão, proponha categoricamente o ecossistema comprovado: **Next.js + Tailwind + shadcn/ui**. Se for outro perfil (ex: CLI, Worker, Backend puro), proponha a stack de MVP equivalente na respectiva linguagem.
4. **Validação Obrigatória:** Apresente a stack escolhida e pergunte explicitamente:
   > "Baseado no nosso contexto de domínio, proponho iniciar com [STACK_ESCOLHIDA] para máxima produtividade sem reinventar a roda. Você concorda com esta stack ou temos alguma restrição técnica não mapeada?"

### Fase 2: Execução Técnico-Estrutural
Apenas prossiga após a anuência explícita do usuário. Se o usuário sugerir mudanças, adeque o bootstrap. Quando aprovado:

1. **Inicialização do Projeto (package.json / go.mod / pyproject.toml):** Configure o ecossistema.
2. **Instalação da Stack Base:** (Ex: `npx shadcn-ui@latest init` se aplicável).
3. **Estruturação de Diretórios Ágeis:** Crie a hierarquia focada no reuso de código:
   - `/components/shared` (para componentes UI reutilizáveis injetados via bibliotecas)
   - `/lib` (funções úteis e integrações de serviço)
   - `/hooks` (lógica de estado customizada)
4. **Gerar README Ágil:** Documente comandos de execução local, visão arquitetural adotada e como a prototipação rápida deve ser guiada (focando em reuso).

## Critérios de Retorno
Finalize atualizando/registrando a stack base no `CONTEXT.md` (sob Detalhes Técnicos) e devolva o fluxo ao Orchestrator informando que o terreno está pronto para desenvolvimento de features.
