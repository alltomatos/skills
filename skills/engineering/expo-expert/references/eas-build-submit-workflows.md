# EAS Build, Submit and Workflows

Anchor docs: `build/introduction.md`, `build/setup.md`, `build/eas-json.md`,
`build/internal-distribution.md`, `submit/android.md`, `submit/ios.md`, `submit/testflight.md`,
`submit/eas-json.md`, `eas/workflows/introduction.md`, `.../get-started.md`, `.../syntax.md`,
`.../pre-packaged-jobs.md`.

## EAS Build

Expo's cloud build service. Compiles `.apk`/`.aab` (Android) and `.ipa` (iOS) without you maintaining a
local toolchain, with integrated credential management.

```bash
npm i -g eas-cli          # or: npx eas-cli@latest ...
eas login
eas build:configure       # creates/prepares eas.json
eas build --profile production --platform all
eas build --profile preview --platform android
eas build:list            # history
```

### `eas.json` - build profiles

`eas.json` defines build **profiles**. Typical structure:

```json
{
  "cli": { "version": ">= 12.0.0" },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "channel": "preview"
    },
    "production": {
      "channel": "production",
      "autoIncrement": true
    }
  },
  "submit": {
    "production": {}
  }
}
```

Key concepts:

- **`developmentClient: true`** -> build with `expo-dev-client` (dev build). See
  [cng-config-plugins.md](cng-config-plugins.md).
- **`distribution: "internal"`** -> internal distribution (link/QR) without going through the stores;
  great for QA. See `build/internal-distribution.md`.
- **`channel`** -> connects the build to an EAS Update channel. See [eas-update.md](eas-update.md).
- Profiles inherit through **`extends`**; use per-profile env vars (`"env": { ... }`) and **EAS
  Environment Variables / Secrets** for sensitive values (never commit a key in `eas.json`).
- `autoIncrement` handles the `versionCode`/`buildNumber` bump.

### Credentials

- **Android**: EAS generates/manages the **keystore** for you (recommended), or you provide your own.
- **iOS**: EAS manages distribution certificates and **provisioning profiles**; requires a paid Apple
  Developer account. `eas credentials` inspects/edits them.
- **Rule**: let EAS manage it unless there is a strong reason not to. Keep a backup of the Android
  keystore - losing it prevents you from updating the published app.

### Local build with EAS infrastructure

`eas build --local` compiles on your machine using the same pipeline - useful for debugging the build
or avoiding the cloud queue.

## EAS Submit

Automates uploading the binary to the stores.

```bash
eas submit --platform ios --profile production
eas submit --platform android --latest    # submits the most recent build
eas build --auto-submit --profile production --platform all   # build + submit in one go
```

- **iOS**: uploads to App Store Connect / TestFlight. Configure `submit.<profile>` in `eas.json`
  (Apple ID/ASC App ID/API Key). See `submit/ios.md`, `submit/testflight.md`.
- **Android**: uploads to Google Play through a **Service Account JSON**. Configure
  `serviceAccountKeyPath` and `track` (`internal`/`alpha`/`beta`/`production`). See
  `submit/android.md`.

## EAS Workflows (CI/CD)

EAS-native CI/CD pipelines, defined in YAML under `.eas/workflows/`. They automate build, submit,
update, tests and jobs in response to git events (push, PR).

```yaml
# .eas/workflows/production-deploy.yml
name: Production deploy
on:
  push:
    branches: ["main"]
jobs:
  build_android:
    type: build
    params:
      platform: android
      profile: production
  submit_android:
    needs: [build_android]
    type: submit
    params:
      platform: android
```

- **Pre-packaged jobs** (`pre-packaged-jobs.md`): `build`, `submit`, `update` and others - you
  reference them by `type` instead of writing shell.
- **`needs`** builds the dependency graph between jobs (sequence/parallel).
- **Full syntax** in `eas/workflows/syntax.md` (triggers, params, matrices, control flow).
- Run locally/manually with `eas workflow:run <file.yml>`.

### E2E tests with Maestro

Workflows integrate **Maestro** for end-to-end UI tests on builds - the standard quality gate before
deploy. Maestro flows (`.yaml` with `appId` + commands such as `tapOn`, `assertVisible`, etc.) run
against the build in a test job. Combine it with **preview builds on Pull Requests** (a workflow
triggered by a PR that builds with `distribution: internal` and comments the link) for visual review
before merge.

## Senior gotchas

- **`eas.json` is not `app.json`.** `eas.json` = how to build/submit; `app.config` = what the app is.
  Do not mix them.
- **Channel != profile.** The `channel` links a build to EAS Update; the profile is the build preset. A
  profile can set a channel, but they are distinct things.
- **Secrets**: use EAS Environment Variables/Secrets, never hardcode them in `eas.json` (it is
  committed).
- **CLI version**: pin `cli.version` in `eas.json` for reproducible builds across the team.
- **iOS without a Mac**: EAS Build solves it - building/submitting iOS does not require local macOS.
