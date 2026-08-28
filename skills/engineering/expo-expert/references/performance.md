# Performance, Nova Arquitetura, Hermes, Metro e Expo Atlas

Doc-âncora: `guides/new-architecture.md`, `guides/react-compiler.md`. Para Metro e Atlas, busque as
páginas específicas via `llms.txt` (`guides/customizing-metro`, `guides/analyzing-bundles`).

## Nova Arquitetura do React Native

A New Architecture substitui a bridge assíncrona antiga por integração direta JS↔nativo. Duas peças:

- **Fabric** — o novo renderer (UI), com layout mais previsível e interoperabilidade melhor.
- **TurboModules** — o novo sistema de módulos nativos, com lazy loading e tipagem via Codegen.

Estado por versão de SDK (confirme sempre na `new-architecture.md`, muda rápido):

- **SDK 52+**: New Arch **habilitada por default**.
- **SDK 53**: todos os pacotes do próprio Expo suportam New Arch.
- **SDK 55+**: New Arch **sempre ligada, não dá pra desabilitar** — o flag `newArchEnabled` é
  ignorado. Usa React Native 0.83. (RN 0.82 foi a 1ª versão a remover a opção de desligar.)
- **Arquitetura legada congelada em jun/2025** — sem novas features/bugfixes.

Opt-in/opt-out (só faz sentido em **SDK 52–54**):

```json
{ "expo": { "newArchEnabled": true } }
```

Também dá para controlar por plataforma: `"android": { "newArchEnabled": true }`. No SDK 55+ é
inócuo.

**Implicação prática**: ao adicionar libs RN de terceiros, verifique compatibilidade com New Arch.
Libs antigas sem suporte podem quebrar — não há mais fallback para a arquitetura legada no SDK 55+.
Ver [native-modules.md](native-modules.md) (a Expo Modules API já é New-Arch-ready).

## Hermes

Hermes é o motor JavaScript padrão em apps Expo — otimizado para startup rápido e menor uso de
memória em mobile. Habilita:
- **Bytecode pré-compilado** (menos parse em runtime, TTI menor).
- **Source maps do Hermes** para simbolizar stack traces de produção (importante para crash
  reporting — ver [observability.md](observability.md)).

Debug: use o inspetor via `npx expo start` → tecla `j` (abre o React Native DevTools/Hermes
inspector). Evite recomendar JSC salvo caso muito específico.

## React Compiler

O **React Compiler** (`guides/react-compiler.md`) memoiza componentes automaticamente em tempo de
build, reduzindo re-renders sem `useMemo`/`useCallback` manuais. É opt-in via config do Expo; ótimo
ganho de perf de UI quando o app tem muitas re-renderizações. Confirme o status/estabilidade na doc
antes de ligar em produção.

## Metro bundler

Metro é o bundler do Expo/React Native. Customização via `metro.config.js` estendendo o preset:

```js
// metro.config.js
const { getDefaultConfig } = require("expo/metro-config");
const config = getDefaultConfig(__dirname);
// ex.: adicionar extensão de asset, resolver, transformer...
config.resolver.assetExts.push("db");
module.exports = config;
```

Alavancas comuns:
- **`resolver`** (extensões, aliases, `unstable_enablePackageExports`), **`transformer`** (inline
  requires, minifier).
- **Monorepo**: configurar `watchFolders` e `nodeModulesPaths` para workspaces.
- **Tree-shaking / package exports**: recursos mais novos do Metro para reduzir bundle — confirme
  flags na doc.

## Expo Atlas — análise de bundle

**Expo Atlas** é a ferramenta oficial para inspecionar visualmente o bundle JS: ver o tamanho por
módulo, dependências e o que está inflando o app.

```bash
EXPO_ATLAS=1 npx expo start        # coleta dados do bundle
npx expo-atlas                     # abre o visualizador (ou via a UI do dev tools)
```

Use Atlas para: caçar dependências pesadas, achar código duplicado, medir o efeito de tree-shaking,
e priorizar o que enxugar. É o primeiro passo antes de "otimizar no escuro".

## Playbook de diagnóstico de performance

1. **Meça primeiro.** Startup lento? Bundle grande? Janks de UI? Cada um tem ferramenta diferente.
2. **Bundle**: rode Expo Atlas; corte deps pesadas, use imports específicos, cheque duplicatas.
3. **Startup (TTI)**: confirme Hermes ligado; reduza trabalho síncrono no boot; considere inline
   requires; lazy-load telas via Expo Router.
4. **UI/render**: use o React DevTools profiler; considere React Compiler; memoize listas
   (`FlashList`/`FlatList` com `keyExtractor`, `getItemLayout`).
5. **Nativo/New Arch**: confirme que libs críticas suportam Fabric/TurboModules; meça no dev build,
   não no Expo Go (perfis diferem).
6. **Produção ≠ dev**: sempre valide perf num build de release; o dev mode é mais lento por design.
