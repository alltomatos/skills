# Observability - crash reporting, telemetry and EAS Insights

Anchor docs: search through `llms.txt` - `guides/using-sentry`, `guides/using-bugsnag`,
`guides/using-logrocket`, and the EAS Insights pages. The integrations evolve; confirm the plugin
version compatible with your SDK.

## Principles

A production app needs three signals: **crashes/errors** (what broke), **performance/traces** (why it
is slow) and **delivery metrics** (who received which build/update). In Expo that splits between an
APM/crash tool (Sentry is the market standard) and **EAS Insights** for build/update cycle metrics.

A critical mobile point: **symbolication**. Production JS runs minified as Hermes bytecode; without
uploading the **source maps** (JS + Hermes) and the native debug symbols (dSYM iOS / ProGuard mapping
Android), stack traces arrive unreadable. Every serious integration automates that upload in the
build.

## Sentry (recommended standard)

```bash
npx expo install @sentry/react-native
```

Idiomatic setup in Expo:

- Add Sentry's **config plugin** to `app.config` (`plugins: ["@sentry/react-native/expo"]`) - it
  injects what is needed into the native side during prebuild and configures **automatic source map
  upload** in EAS Build.
- Initialize it early in the app (`Sentry.init({ dsn, tracesSampleRate, ... })`) and wrap the root
  (`Sentry.wrap(App)`), or the root layout in Expo Router.
- The Sentry auth token goes in as an **EAS Secret**, never committed.

What Sentry delivers: crash/error reporting with breadcrumbs, **performance tracing**, and (with the
source map config) symbolized Hermes stack traces. It integrates with EAS Update to tie an error to
the **update/runtime version** that caused it.

## BugSnag / LogRocket

Supported alternatives when the team already uses them:

- **BugSnag** - crash reporting + stability; it has an Expo plugin/config (`guides/using-bugsnag`).
- **LogRocket** - session replay + logs, strong for reproducing what the user did before the error
  (`guides/using-logrocket`).

For all of them: the step most people forget is the **source map/symbol upload in the build
pipeline**. Check that first when "stack traces arrive without function names".

## EAS Insights

**EAS Insights** gives EAS-side metrics: update adoption (how many devices downloaded which update),
build success/failure, and delivery telemetry. Enable it by installing `expo-insights` (config plugin)
and check the EAS dashboard.

Use Insights to answer delivery questions - "did my OTA reach the users?", "which runtime version is in
the field?" - that Sentry (focused on error/perf) does not cover. They complement each other:
Insights = delivery, Sentry = runtime health.

## Playbook

1. **Install crash reporting before the first release**, not after the first incident.
2. **Guarantee source maps in the build** (config plugin + EAS) - without them everything else is
   blind.
3. **Tie errors to the release**: propagate `runtimeVersion`/version as release/dist in Sentry so you
   know exactly which OTA broke. Cross-reference with [eas-update.md](eas-update.md).
4. **Secrets as EAS Secrets** (the DSN can sometimes be public; auth tokens NEVER).
5. **Validate the capture**: fire a test error in staging and confirm it arrives symbolized before
   trusting production.
