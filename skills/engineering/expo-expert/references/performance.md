# Performance, New Architecture, Hermes, Metro and Expo Atlas

Anchor docs: `guides/new-architecture.md`, `guides/react-compiler.md`. For Metro and Atlas, search the
specific pages through `llms.txt` (`guides/customizing-metro`, `guides/analyzing-bundles`).

## React Native's New Architecture

The New Architecture replaces the old asynchronous bridge with direct JS<->native integration. Two
parts:

- **Fabric** - the new renderer (UI), with more predictable layout and better interoperability.
- **TurboModules** - the new native module system, with lazy loading and typing through Codegen.

Status per SDK version (always confirm in `new-architecture.md`, it changes fast):

- **SDK 52+**: New Arch **enabled by default**.
- **SDK 53**: every Expo package supports New Arch.
- **SDK 55+**: New Arch **always on, cannot be disabled** - the `newArchEnabled` flag is ignored. It
  uses React Native 0.83. (RN 0.82 was the first version to remove the option to turn it off.)
- **Legacy architecture frozen in June 2025** - no new features/bugfixes.

Opt-in/opt-out (only meaningful in **SDK 52-54**):

```json
{ "expo": { "newArchEnabled": true } }
```

You can also control it per platform: `"android": { "newArchEnabled": true }`. On SDK 55+ it is a
no-op.

**Practical implication**: when adding third-party RN libraries, check New Arch compatibility. Old
libraries without support may break - there is no longer a fallback to the legacy architecture on SDK
55+. See [native-modules.md](native-modules.md) (the Expo Modules API is already New-Arch-ready).

## Hermes

Hermes is the default JavaScript engine in Expo apps - optimized for fast startup and lower memory
usage on mobile. It enables:

- **Pre-compiled bytecode** (less parsing at runtime, lower TTI).
- **Hermes source maps** to symbolize production stack traces (important for crash reporting - see
  [observability.md](observability.md)).

Debugging: use the inspector via `npx expo start` -> key `j` (opens React Native DevTools/Hermes
inspector). Avoid recommending JSC unless there is a very specific case.

## React Compiler

The **React Compiler** (`guides/react-compiler.md`) memoizes components automatically at build time,
reducing re-renders without manual `useMemo`/`useCallback`. It is opt-in through Expo config; a great
UI perf win when the app re-renders a lot. Confirm status/stability in the docs before enabling it in
production.

## Metro bundler

Metro is the Expo/React Native bundler. Customization goes through `metro.config.js`, extending the
preset:

```js
// metro.config.js
const { getDefaultConfig } = require("expo/metro-config");
const config = getDefaultConfig(__dirname);
// e.g. add an asset extension, resolver, transformer...
config.resolver.assetExts.push("db");
module.exports = config;
```

Common levers:

- **`resolver`** (extensions, aliases, `unstable_enablePackageExports`), **`transformer`** (inline
  requires, minifier).
- **Monorepo**: configure `watchFolders` and `nodeModulesPaths` for workspaces.
- **Tree-shaking / package exports**: newer Metro features to shrink the bundle - confirm the flags in
  the docs.

## Expo Atlas - bundle analysis

**Expo Atlas** is the official tool to inspect the JS bundle visually: size per module, dependencies
and what is inflating the app.

```bash
EXPO_ATLAS=1 npx expo start        # collects bundle data
npx expo-atlas                     # opens the viewer (or through the dev tools UI)
```

Use Atlas to: hunt heavy dependencies, find duplicated code, measure the effect of tree-shaking, and
prioritize what to trim. It is the first step before "optimizing in the dark".

## Performance diagnosis playbook

1. **Measure first.** Slow startup? Big bundle? UI jank? Each one has a different tool.
2. **Bundle**: run Expo Atlas; cut heavy deps, use specific imports, check for duplicates.
3. **Startup (TTI)**: confirm Hermes is on; reduce synchronous work at boot; consider inline requires;
   lazy-load screens through Expo Router.
4. **UI/render**: use the React DevTools profiler; consider React Compiler; memoize lists
   (`FlashList`/`FlatList` with `keyExtractor`, `getItemLayout`).
5. **Native/New Arch**: confirm critical libraries support Fabric/TurboModules; measure on a dev
   build, not in Expo Go (the profiles differ).
6. **Production != dev**: always validate perf on a release build; dev mode is slower by design.
