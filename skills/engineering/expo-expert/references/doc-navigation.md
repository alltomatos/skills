# Navigating the Expo documentation

The Expo docs are the source of truth and are published in an LLM-friendly format. Mastering how to
search them is worth more than any memorized fact - the facts change with every SDK; the method does
not.

## Golden rules

1. **Append `.md` to any doc URL** to receive clean markdown (same content, a fraction of the HTML
   tokens). Example: `https://docs.expo.dev/build/eas-json` -> `https://docs.expo.dev/build/eas-json.md`.
   `/index.md` also works. Alternative: the `Accept: text/markdown` header.
2. **`https://docs.expo.dev/llms.txt`** (~54 kB) is the full index with real URLs. Download it when
   you do not know where a topic lives, then fetch the specific page as `.md`.
3. **Check the project's SDK version before answering** anything version-sensitive
   (`package.json` -> `dependencies.expo`). The right answer almost always depends on it.
4. **There is no `llms-full.txt`.** `llms.txt` + the `.md` suffix are the official mechanisms.

## Docs written for AI agents

Expo maintains a section dedicated to agents/LLMs - read it when the work is about integrating AI
into the Expo flow, or to align your behavior with what Expo recommends:

- `https://docs.expo.dev/agents.md` - "AI agents and Expo" overview (also described as the doc map)
- `https://docs.expo.dev/agents/claude.md` - Claude Code + Expo
- `https://docs.expo.dev/agents/codex.md` · `https://docs.expo.dev/agents/cursor.md`
- `https://docs.expo.dev/skills.md` - Expo Skills for agents
- `https://docs.expo.dev/mcp.md` - Model Context Protocol with Expo
- `https://docs.expo.dev/llms.md` - how agents/LLMs should consume the docs

## URL map by domain (verbatim)

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

### Expo Modules API (custom native)
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

### New Architecture / performance
- `https://docs.expo.dev/guides/new-architecture.md`
- `https://docs.expo.dev/guides/react-compiler.md`

## When the map is not enough

If the topic is not above (e.g. a specific `expo-*` API, a new guide, a recent flag), download
`llms.txt` and `grep` for the term - it lists the page. Then fetch the `.md` page. Never "guess" URLs,
flag names or SDK numbers: confirm and cite.
