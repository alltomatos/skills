# SDK upgrade

Anchor docs: `workflow/upgrading-expo-sdk-walkthrough.md`.

## Core principle

**Go up one SDK at a time, never skip versions.** Each jump better isolates which change caused which
break - jumping from SDK 51 straight to 55 mixes four sets of breaking changes into one giant,
hard-to-debug diff.

## Manual flow (the official walkthrough)

```bash
# 1. Raise the expo package to the target version
npm install expo@^57.0.0        # replace with the target SDK number

# 2. Align the rest of the dependencies to the new SDK version
npx expo install --fix

# 3. Diagnose
npx expo-doctor
```

**CNG projects** (the overwhelming majority - see [cng-config-plugins.md](cng-config-plugins.md)):

```bash
rm -rf android ios     # or delete them manually
npx expo prebuild --clean
```

The folders are an artifact; deleting and regenerating is safer than trying to migrate the native
content by hand.

**Projects without CNG** (native versioned manually - rare/legacy): run `npx pod-install` and apply
the changes indicated by the docs' *Native project upgrade helper*, or use the upgrade as the moment
to migrate to CNG.

**4. Read the target version's changelog.** Every SDK has release notes with the breaking changes - do
not skip this step even with `expo-doctor` green; the doctor catches dependency misalignment, not
runtime behavior changes.

## Agent-assisted upgrade

Expo itself maintains an official AI skill for this - **`expo-upgrade`**, part of the
`github.com/expo/skills` package - which guides the upgrade with dependency fix recommendations. When
available in the environment, it is a good complement to this manual flow (it has MCP access to live
compatibility data); this reference covers the mental model and the commands for when it is not
installed or you prefer manual control.

## Senior checklist before shipping an SDK upgrade to production

1. **Dedicated branch**, never directly on the release branch.
2. `npx expo install --fix` + `npx expo-doctor` **clean** before proceeding.
3. `npx expo prebuild --clean` and a **local build** (`expo run:android`/`run:ios`) before spending
   EAS Build queue.
4. Run the whole app manually (or the E2E tests, if any - see Maestro in
   [eas-build-submit-workflows.md](eas-build-submit-workflows.md)), not only the main screen.
5. **Check New Architecture compatibility** for every third-party native library - on SDK 55+ there
   is no opt-out (see [performance.md](performance.md)). It is the most common cause of "the upgrade
   broke a library" in recent versions.
6. **Check `runtimeVersion`** - an SDK bump almost always changes the native interface; with the
   `fingerprint` policy that is automatic, otherwise a manual bump is mandatory (see
   [eas-update.md](eas-update.md)) so you do not ship an incompatible OTA.
7. Ship a **preview/internal build** first, validate with the team, and only then production.

## Senior gotchas

- **A clean `expo-doctor` is not a guarantee of a working app** - it checks dependency alignment, not
  behavior. Manual testing remains mandatory.
- **Do not skip the changelog** assuming "it worked, so everything is fine" - some breaking changes
  only show up on code paths your initial smoke test did not touch.
- **Deleting `android`/`ios` is safe** in CNG projects - resisting it (thinking you will lose
  customization) usually means the customization was not in a config plugin, which was already a
  problem before the upgrade.
