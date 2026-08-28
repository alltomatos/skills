# Navegação na documentação do Expo

A doc do Expo é a fonte da verdade e é publicada em formato amigável a LLM. Dominar como buscar
nela vale mais do que qualquer fato memorizado — os fatos mudam a cada SDK; o método não.

## Regras de ouro

1. **Append `.md` a qualquer URL de doc** para receber markdown limpo (mesmo conteúdo, fração dos
   tokens do HTML). Ex.: `https://docs.expo.dev/build/eas-json` → `https://docs.expo.dev/build/eas-json.md`.
   `/index.md` também funciona. Alternativa: header `Accept: text/markdown`.
2. **`https://docs.expo.dev/llms.txt`** (~54 kB) é o índice completo com URLs reais. Baixe quando
   não souber onde um tópico mora, depois busque a página específica em `.md`.
3. **Cheque a versão de SDK do projeto antes de responder** algo sensível a versão
   (`package.json` → `dependencies.expo`). A resposta certa quase sempre depende dela.
4. **Não há `llms-full.txt`.** O `llms.txt` + append `.md` são os mecanismos oficiais.

## Docs feitas para agentes de IA

O Expo mantém uma seção dedicada a agentes/LLMs — leia quando o trabalho for sobre integrar IA no
fluxo Expo, ou para alinhar seu comportamento com o que o Expo recomenda:

- `https://docs.expo.dev/agents.md` — visão geral "AI agents and Expo" (também descrito como o mapa da doc)
- `https://docs.expo.dev/agents/claude.md` — Claude Code + Expo
- `https://docs.expo.dev/agents/codex.md` · `https://docs.expo.dev/agents/cursor.md`
- `https://docs.expo.dev/skills.md` — Expo Skills para agentes
- `https://docs.expo.dev/mcp.md` — Model Context Protocol com Expo
- `https://docs.expo.dev/llms.md` — como agentes/LLMs devem consumir a doc

## Mapa de URLs por domínio (verbatim)

### Development builds
- `https://docs.expo.dev/develop/development-builds/introduction.md`
- `https://docs.expo.dev/develop/development-builds/use-development-builds.md`
- `https://docs.expo.dev/develop/development-builds/share-with-your-team.md`
- `https://docs.expo.dev/develop/development-builds/development-workflows.md`
- `https://docs.expo.dev/develop/development-builds/faq.md`

### CNG / Prebuild
- `https://docs.expo.dev/workflow/continuous-native-generation.md`
- `https://docs.expo.dev/guides/adopting-prebuild.md`

### Config plugins
- `https://docs.expo.dev/config-plugins/introduction.md`
- `https://docs.expo.dev/config-plugins/plugins.md`
- `https://docs.expo.dev/config-plugins/mods.md`
- `https://docs.expo.dev/config-plugins/dangerous-mods.md`
- `https://docs.expo.dev/config-plugins/development-for-libraries.md`
- `https://docs.expo.dev/config-plugins/development-and-debugging.md`
- `https://docs.expo.dev/config-plugins/patch-project.md`

### Expo Modules API (nativo custom)
- `https://docs.expo.dev/modules/overview.md`
- `https://docs.expo.dev/modules/get-started.md`
- `https://docs.expo.dev/modules/native-module-tutorial.md`
- `https://docs.expo.dev/modules/native-view-tutorial.md`
- `https://docs.expo.dev/modules/config-plugin-and-native-module-tutorial.md`
- `https://docs.expo.dev/modules/module-api.md`

### EAS Build
- `https://docs.expo.dev/build/introduction.md`
- `https://docs.expo.dev/build/setup.md`
- `https://docs.expo.dev/build/eas-json.md`
- `https://docs.expo.dev/build/internal-distribution.md`

### EAS Submit
- `https://docs.expo.dev/submit/android.md` · `https://docs.expo.dev/submit/ios.md`
- `https://docs.expo.dev/submit/testflight.md` · `https://docs.expo.dev/submit/eas-json.md`

### EAS Update
- `https://docs.expo.dev/eas-update/introduction.md`
- `https://docs.expo.dev/eas-update/getting-started.md`
- `https://docs.expo.dev/eas-update/deployment.md`
- `https://docs.expo.dev/eas-update/how-it-works.md`

### EAS Workflows
- `https://docs.expo.dev/eas/workflows/introduction.md`
- `https://docs.expo.dev/eas/workflows/get-started.md`
- `https://docs.expo.dev/eas/workflows/pre-packaged-jobs.md`
- `https://docs.expo.dev/eas/workflows/syntax.md`

### Expo Router
- `https://docs.expo.dev/router/introduction.md`
- `https://docs.expo.dev/router/basics/core-concepts.md`
- `https://docs.expo.dev/router/basics/navigation.md`
- `https://docs.expo.dev/router/advanced/stack.md`
- `https://docs.expo.dev/router/advanced/authentication.md`

### Nova Arquitetura / performance
- `https://docs.expo.dev/guides/new-architecture.md`
- `https://docs.expo.dev/guides/react-compiler.md`

## Quando o mapa não basta

Se o tópico não estiver acima (ex.: uma API de `expo-*` específica, um guia novo, uma flag
recente), baixe `llms.txt` e faça `grep` pelo termo — ele lista a página. Depois busque a página
`.md`. Nunca "chute" URLs, nomes de flag ou números de SDK: confirme e cite.
