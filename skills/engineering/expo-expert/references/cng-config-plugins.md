# CNG, Prebuild, Config Plugins and Dev Builds

Anchor docs: `continuous-native-generation.md`, `config-plugins/introduction.md`, `.../mods.md`,
`.../dangerous-mods.md`, `develop/development-builds/introduction.md`.

## Continuous Native Generation (CNG)

CNG is the model where the native `android/` and `ios/` folders are **artifacts generated on demand**,
not source code. They come from three inputs:

1. A default **template**, tied to the SDK version.
2. Your **config** in `app.json` / `app.config.js` / `app.config.ts` (the source of truth).
3. **Config plugins** that modify the template during generation.

Consequence: you keep only the *definition* of the customizations, not the whole native code. That is
what kills the concepts of "eject" and "managed vs bare" - they no longer exist. Every project is CNG.

### `npx expo prebuild`

Generates/updates `android/` and `ios/` from the three inputs above. It also has side effects: it
adjusts `package.json` scripts (swaps `expo start --android` for `expo run:android`) and may touch
dependencies.

```bash
npx expo prebuild                      # generates both platforms (incremental)
npx expo prebuild --clean              # deletes android/ios before regenerating - SAFE DEFAULT
npx expo prebuild --platform ios       # one platform only
npx expo prebuild --template /path/template.tgz   # rare; not recommended
```

- **Use `--clean` by default.** Config plugins are not always idempotent; applying them over
  already-modified folders produces inconsistent state. `--clean` regenerates from scratch.
- Running `npx expo run:android` / `run:ios` performs an implicit prebuild when needed.

### Gitignoring the native folders

In a pure CNG flow, `android/` and `ios/` are in `.gitignore` (new projects already do this). If a
project has versioned native folders and you want EAS Build to ignore them, add them to `.gitignore`
or `.easignore` so EAS does not treat them as source. Editing the generated folders by hand is an
anti-pattern - the next prebuild overwrites it.

### `npx expo prebuild --clean` vs editing native by hand

Need something `app.json` does not expose (a value in `AndroidManifest.xml`, a key in `Info.plist`, a
Gradle file)? The idiomatic answer is **to write a config plugin**, not to edit the generated folder.
For extreme cases where a plugin is not viable, there is `patch-project`
(`config-plugins/patch-project.md`), which versions a patch applied over the generated native code -
but treat it as a last resort.

## Config Plugins

Config plugins are **functions that run during prebuild** and transform the native files. They replace
manual edits, eliminating orphan code and letting library authors automate the native setup in a
versioned and testable way.

### Anatomy

A plugin is a function `(config, props) => config`. You register it in `app.config.js`:

```js
// app.config.js
export default {
  expo: {
    plugins: [
      "expo-camera",                          // a library's plugin
      ["./plugins/withCustomManifest", { foo: "bar" }],  // your plugin + props
    ],
  },
};
```

### Mods

A **mod** is a special async plugin that gives access to a specific native file so you can modify it.
The main ones (from `@expo/config-plugins`):

- `withAndroidManifest` - modifies `AndroidManifest.xml` (receives the parsed XML).
- `withInfoPlist` - modifies the iOS `Info.plist`.
- `withAppBuildGradle` / `withProjectBuildGradle` - Gradle files.
- `withEntitlementsPlist`, `withXcodeProject`, `withStringsXml`, `withColorsXml`, `withGradleProperties`, etc.

Example - add a permission and a `<meta-data>` entry to the manifest:

```js
const { withAndroidManifest, AndroidConfig } = require("@expo/config-plugins");

module.exports = function withCustomManifest(config, { apiKey }) {
  return withAndroidManifest(config, (config) => {
    const app = AndroidConfig.Manifest.getMainApplicationOrThrow(config.modResults);
    AndroidConfig.Manifest.addMetaDataItemToMainApplication(app, "com.example.API_KEY", apiKey);
    return config;
  });
};
```

Use the `AndroidConfig` / `IOSConfig` helpers (`AndroidConfig.Manifest`, `IOSConfig.Permissions`,
etc.) - they handle XML/plist manipulation safely instead of string replacement.

### Dangerous mods

`withDangerousMod` gives *raw* access to the native project's file system during prebuild, **without**
a structured parser. Use it only when no dedicated mod exists - e.g. creating/copying a file, or
touching a file no mod covers.

```js
const { withDangerousMod } = require("@expo/config-plugins");
const fs = require("fs");
const path = require("path");

module.exports = function withCopyAsset(config) {
  return withDangerousMod(config, [
    "ios",
    async (config) => {
      const root = config.modRequest.platformProjectRoot; // e.g. <proj>/ios
      fs.copyFileSync(path.join(__dirname, "GoogleService-Info.plist"),
                      path.join(root, "GoogleService-Info.plist"));
      return config;
    },
  ]);
};
```

Why "dangerous": they run with no ordering guarantee relative to other mods and no automatic
idempotency - you are responsible for not breaking what another plugin did. Make them idempotent
(check before writing) and keep them small.

### Debugging config plugins

- **`npx expo prebuild --clean` and inspect the result** in `android/`/`ios/` to see the plugin's real
  effect.
- `EXPO_DEBUG=1 npx expo prebuild` gives better stack traces when a plugin throws.
- `npx expo config --type prebuild` shows the resolved config after applying the plugins.
- Doc: `config-plugins/development-and-debugging.md`. Plugins written in TS may need a build to JS
  before they can be consumed.

## Development builds (dev client)

A *development build* is your version of the app with the `expo-dev-client` library - "your own Expo
Go". Unlike Expo Go, it runs **any** native library and custom native config, and brings a launcher to
switch between dev servers and deployments.

```bash
npx expo install expo-dev-client
npx expo run:android        # local build + install (needs the Android toolchain)
npx expo run:ios            # same for iOS (macOS/Xcode)
# or build in the cloud:
eas build --profile development --platform android
```

- **Mental rule**: added a library with native code? Expo Go no longer runs it - you need a dev build.
  Rebuild only when: installing a new native library, changing native config (`app.json`), or
  upgrading the SDK. Day to day, `npx expo start` is enough.
- Three ways to build: **local** (`expo run:*`, own toolchain), **EAS cloud build** (no local
  toolchain, needs an EAS account) and **EAS local build** (EAS infrastructure, compiles on your
  machine).
