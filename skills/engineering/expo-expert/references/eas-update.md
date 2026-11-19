# EAS Update - OTA, runtime versions, channels and rollouts

Anchor docs: `eas-update/introduction.md`, `.../getting-started.md`, `.../how-it-works.md`,
`.../deployment.md`.

## What it is

EAS Update delivers **Over-The-Air (OTA) updates** of the JavaScript bundle and assets without going
through the stores. It only updates what is JS/assets - **a native code change still requires a new
build** and a new submission. It is built on the `expo-updates` library.

```bash
npx expo install expo-updates
eas update:configure
eas update --branch production --message "fix: checkout crash"
eas update --auto     # infers the branch from the git context
```

## Runtime version - the concept most people get wrong

The **runtime version** describes the JS<->native interface defined by the app's native layer. An
update only runs on a build if the **build's runtime version matches the update's EXACTLY**.

Golden rule: **whenever the native layer changes in a way that affects the JS<->native interface (a
new native library, an SDK upgrade, a native config change), `runtimeVersion` MUST change.** If it
does not, an OTA lands on incompatible native builds and breaks the app in production. This is the
number one OTA footgun.

Configuration in `app.config`:

```json
{
  "expo": {
    "runtimeVersion": { "policy": "fingerprint" }
  }
}
```

`runtimeVersion` policies:

- **`fingerprint`** (the modern recommendation) - EAS computes a hash of the project's native state;
  it changes by itself when the native side changes. Removes the manual error. (See `fingerprint` /
  `expo-updates`.)
- **`appVersion`** - ties it to the app's `version`.
- **`nativeVersion`** - ties it to `version` + build number.
- **String literal** (e.g. `"1.0.0"`) - you control it manually; more error-prone.

## Channels and branches

Two distinct concepts that connect:

- **Channel** - a name assigned to **builds**, defined in `eas.json` (e.g. `production`, `preview`,
  `staging`). It is the binary's label.
- **Branch** - an object on the EAS server that holds a **list of updates** (the most recent one is
  active). Think of it as a git branch, but for updates.

By default a channel points to the branch of the same name, but the link is editable:

```bash
eas channel:edit production --branch hotfix-2026-08
eas branch:list
eas channel:list
```

### Conditions for an update to run on a build

All three must be true:

1. **Platform** matches (Android or iOS).
2. **Runtime version** matches exactly.
3. The build's **channel** is linked to the **branch** holding the update.

The flow: `eas update` creates the bundle and uploads it to a branch; `expo-updates` on the device
checks the manifest and downloads the update (manifest first, then the needed assets) for builds whose
channel points to that branch.

## Rollout and rollback

- **Gradual rollout**: publish the update with a percentage rollout to expose it to a fraction of
  users and increase it slowly while watching metrics. (See `deployment.md` / rollout options.)
- **Rollback**: since the channel<->branch link is editable and the branch keeps the update history,
  you **revert by pointing the channel to a previous branch/state** or by republishing the good
  update - **without** rebuilding the app. That is OTA's big advantage for incident response.
- **Channel surfing**: moving builds between branches by swapping channel links lets you promote the
  same binary from `staging` -> `production` with no new build.

## Deployment pattern with builds

`eas.json` links build and update through `channel`:

```json
{
  "build": {
    "preview":    { "channel": "preview" },
    "production": { "channel": "production" }
  }
}
```

That way the production binary only receives updates from the production branch. Combine it with
[EAS Workflows](eas-build-submit-workflows.md) to automate `build -> submit -> update`.

## Senior gotchas

- **OTA does not replace a build for a native change.** Added a native library? New build + submit,
  even with EAS Update enabled.
- **A misaligned runtime version = a silent crash** for people who already have the app. Prefer the
  `fingerprint` policy so you do not depend on human discipline.
- **Store rules**: OTA is allowed for fixes and content, but not to bypass review of substantial
  feature changes. Use common sense.
- **`expo-updates` must be installed and configured** in the build, otherwise the app never looks for
  updates.
- **Test the update on the preview channel before production** - publish to the `preview` branch,
  validate on a `preview` build, and only then promote.
