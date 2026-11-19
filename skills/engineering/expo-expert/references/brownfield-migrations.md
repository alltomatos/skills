# Brownfield and migrations to Expo

Anchor docs: search through `llms.txt` - `guides/adopting-prebuild`, `bare/*` (brownfield
integration), and `guides/monorepo`. These guides change; confirm the exact steps in the docs before
running them.

## Two distinct scenarios

1. **Migration from React Native CLI -> Expo** (the project is already RN and wants to adopt the Expo
   ecosystem).
2. **Brownfield** (embedding React Native/Expo inside an **existing native** iOS/Android app).

They are different problems; do not confuse them.

## Migrating from RN CLI to Expo

The point that surprises people coming from old RN: **you do not need to "start over" or choose
managed vs bare** - those concepts no longer exist (see
[cng-config-plugins.md](cng-config-plugins.md)). Adopting Expo in an RN project is incremental.

Typical steps (confirm in the `guides/adopting-prebuild` doc and in the guide for installing Expo in an
existing project):

1. **Install the `expo` package** and run the installer/`expo install expo`, which wires in the base
   modules.
2. **Align dependencies** with `npx expo install --fix` and diagnose with `npx expo-doctor`.
3. **Adopt Prebuild (CNG)**: move the native customizations out of `android/`/`ios/` into `app.json`
   + **config plugins**, then generate the native side with `npx expo prebuild`. The end goal is to
   be able to delete the native folders from git and treat them as artifacts.
4. **Migrate libraries** to `expo-*` equivalents where they exist (better CNG/EAS support).
5. **Adopt EAS Build/Update** for cloud builds and OTA (see
   [eas-build-submit-workflows.md](eas-build-submit-workflows.md), [eas-update.md](eas-update.md)).
6. **Optional**: adopt Expo Router if you want file-based routing.

Senior strategy: **migrate in stages and keep the app buildable at every step**. Start by installing
`expo` and running the apps as they are; only then adopt prebuild; only then migrate libraries. Do not
attempt a big bang.

### Existing native customizations -> config plugins

The core work of the migration is translating each manual native edit (a permission in the manifest, a
key in `Info.plist`, a Gradle snippet, a copied file) into a **config plugin** or a mod. Where a plugin
is not viable in the short term, `patch-project` versions the patch. The target is a state where
`npx expo prebuild --clean` reproduces 100% of the native side from config.

## Brownfield - Expo inside an existing native app

Here the **host** app is native (Swift/Kotlin) and you embed React Native/Expo screens. Key points (see
the `bare`/brownfield guides in the docs):

- It is more advanced and less of a "happy path" than a pure Expo app - some ecosystem features (e.g.
  parts of the CNG/EAS flow) assume Expo controls the native project. Check the current support for
  your SDK in the docs before promising it.
- The native host initializes the RN runtime and mounts the RN views at specific points; you manage the
  lifecycle from the native side.
- Autolinking and Expo Modules may require extra manual setup in the host project.
- Tools such as EAS Build may need custom configuration when the build is not fully managed by Expo.

## Diagnosis and tools

- **`npx expo-doctor`** - the first command in any migration: it points out incompatible versions and
  broken config.
- **`npx expo install --check` / `--fix`** - aligns library versions with the SDK.
- **SDK upgrade**: `npx expo install expo@latest` + `npx expo install --fix`, then
  `npx expo prebuild --clean`. Always read the **SDK changelog/upgrade guide** in the docs first.
- Check the **New Architecture compatibility** of the libraries when migrating/upgrading the SDK - on
  SDK 55+ there is no opt-out (see [performance.md](performance.md)).

## Senior gotchas

- **Do not version `android/`/`ios/` "just in case"** during the migration and then forget them - that
  reintroduces the problem CNG solves. Decide: either pure CNG (gitignore + plugins), or deliberately
  versioned folders (a "prebuild partially adopted" flow).
- **Migrate libraries one at a time**, testing the build after each swap - native libraries are the
  biggest source of breakage.
- **Follow the upgrade docs, not memory**: every SDK has documented breaking changes.
