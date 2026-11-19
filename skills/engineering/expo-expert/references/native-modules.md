# Expo Modules API - custom native modules and views

Anchor docs: `modules/overview.md`, `modules/get-started.md`, `modules/native-module-tutorial.md`,
`modules/native-view-tutorial.md`, `modules/module-api.md`,
`modules/config-plugin-and-native-module-tutorial.md`.

## When to use it

Use the Expo Modules API when you need your own native code: integrating a third-party SDK with no
official React Native wrapper, exposing a platform native API, or shipping a performant native view.
It is the modern, idiomatic way - you write **Swift** (iOS) and **Kotlin** (Android) with a declarative
DSL, instead of the manual Objective-C/Java bridges of the old architecture.

Before writing a module: confirm there is no `expo-*` package or community library that already solves
it. Writing native is the last resort, not the first.

## Scaffolding

```bash
# Local module inside an existing app (most common for integrating an SDK):
npx create-expo-module@latest --local

# Standalone publishable library (npm), with an example:
npx create-expo-module@latest
```

`--local` creates the `modules/<name>/` folder in your app, already wired for autolinking - no npm
publishing. Ideal for "I just need a bit of Swift/Kotlin in this app".

## The module DSL (Definition Components)

The module class extends `Module` and describes the JS<->native interface declaratively. Main
components (see `module-api.md`):

- `Name("...")` - the name the JS side uses to access the module.
- `Constants([...])` - exposed constant values.
- `Function("name") { ... }` / `AsyncFunction("name") { ... }` - synchronous/asynchronous methods.
- `Events("onX")` + `sendEvent(...)` - native -> JS events.
- `Property("name")` - properties.
- `View { ... }` with `Prop("name") { ... }` - defines a **native view** and its props.
- `OnCreate`, `OnDestroy`, lifecycle hooks.

Swift (iOS):

```swift
import ExpoModulesCore

public class MyModule: Module {
  public func definition() -> ModuleDefinition {
    Name("MyModule")
    Function("hello") { (name: String) -> String in
      return "Hello, \(name)!"
    }
    AsyncFunction("compute") { (a: Int, b: Int) in
      return a + b
    }
    Events("onChange")
  }
}
```

Kotlin (Android):

```kotlin
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class MyModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("MyModule")
    Function("hello") { name: String -> "Hello, $name!" }
    AsyncFunction("compute") { a: Int, b: Int -> a + b }
    Events("onChange")
  }
}
```

JS/TS side: `requireNativeModule("MyModule")` (or the generated wrapper). Arguments are converted by
type automatically; use `Records` for structs and `Enumerable` for typed enums.

## Native views

To expose a native component (map, player, custom camera), define a `View` in the module and expose a
`Prop(...)` for each property. On the JS side, use `requireNativeViewManager` / the generated wrapper
as a React component. Tutorial: `modules/native-view-tutorial.md`.

## Module + config plugin

Native SDKs usually require setup in `Info.plist`/`AndroidManifest`/Gradle (API keys, permissions,
Maven repositories). The idiomatic pattern is to **ship a config plugin together with the module** so
that setup is automated at prebuild - that way whoever installs it does not edit native by hand.
Dedicated tutorial: `modules/config-plugin-and-native-module-tutorial.md`. Cross-reference with
[cng-config-plugins.md](cng-config-plugins.md).

## Senior gotchas

- **New Architecture**: the Expo Modules API is already compatible with New Arch
  (Fabric/TurboModules). When integrating old third-party RN libraries, check whether they support New
  Arch - on SDK 55+ there is no way to turn it off. See [performance.md](performance.md).
- **Autolinking**: modules created by `create-expo-module` are autolinked; you do not need to touch
  `settings.gradle`/`Podfile` by hand.
- **Rebuild required**: changed the module's native code? You need a new dev build (`expo run:*` or
  EAS) - reloading the JS is not enough.
- **TS interface**: you can generate the TypeScript interface from the native side
  (`modules/type-generation-tutorial.md`) to keep types in sync.
- **Test in a dev build, never in Expo Go** - Expo Go does not load custom native code.
