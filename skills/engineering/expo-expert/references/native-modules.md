# Expo Modules API — módulos e views nativos custom

Doc-âncora: `modules/overview.md`, `modules/get-started.md`, `modules/native-module-tutorial.md`,
`modules/native-view-tutorial.md`, `modules/module-api.md`,
`modules/config-plugin-and-native-module-tutorial.md`.

## Quando usar

Use a Expo Modules API quando precisar de código nativo próprio: integrar um SDK de terceiro sem
wrapper React Native oficial, expor uma API nativa da plataforma, ou entregar uma view nativa
performática. É a forma moderna e idiomática — escreve-se **Swift** (iOS) e **Kotlin** (Android)
com uma DSL declarativa, em vez de bridges Objective-C/Java manuais da arquitetura antiga.

Antes de escrever um módulo: confirme que não existe já um pacote `expo-*` ou uma lib da comunidade
que resolva. Escrever nativo é o último recurso, não o primeiro.

## Scaffolding

```bash
# Módulo local dentro de um app existente (mais comum p/ integrar um SDK):
npx create-expo-module@latest --local

# Biblioteca standalone publicável (npm), com exemplo:
npx create-expo-module@latest
```

`--local` cria a pasta `modules/<nome>/` no seu app, já plugada ao autolinking — sem publicar no
npm. Ideal para "só preciso de um pedaço de Swift/Kotlin neste app".

## A DSL do módulo (Definition Components)

A classe do módulo estende `Module` e descreve a interface JS↔nativo declarativamente. Componentes
principais (ver `module-api.md`):

- `Name("...")` — nome pelo qual o JS acessa o módulo.
- `Constants([...])` — valores constantes expostos.
- `Function("nome") { ... }` / `AsyncFunction("nome") { ... }` — métodos síncronos/assíncronos.
- `Events("onX")` + `sendEvent(...)` — eventos nativo → JS.
- `Property("nome")` — propriedades.
- `View { ... }` com `Prop("nome") { ... }` — define uma **native view** e suas props.
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

Lado JS/TS: `requireNativeModule("MyModule")` (ou o wrapper gerado). Argumentos são convertidos por
tipo automaticamente; use `Records` para structs e `Enumerable` para enums tipados.

## Native views

Para expor um componente nativo (mapa, player, câmera custom), defina um `View` no módulo e exponha
`Prop(...)` para cada propriedade. No JS, use `requireNativeViewManager` / o wrapper gerado como um
componente React. Tutorial: `modules/native-view-tutorial.md`.

## Módulo + config plugin

SDKs nativos costumam exigir setup no `Info.plist`/`AndroidManifest`/Gradle (chaves de API,
permissões, repositórios Maven). O padrão idiomático é **empacotar um config plugin junto do
módulo** para automatizar esse setup no prebuild — assim quem instala não edita nativo à mão.
Tutorial dedicado: `modules/config-plugin-and-native-module-tutorial.md`. Cruze com
[cng-config-plugins.md](cng-config-plugins.md).

## Gotchas de sênior

- **Nova Arquitetura**: a Expo Modules API já é compatível com a New Arch (Fabric/TurboModules).
  Ao integrar libs RN de terceiros antigas, verifique se elas suportam New Arch — no SDK 55+ não há
  como desligar. Ver [performance.md](performance.md).
- **Autolinking**: módulos criados pelo `create-expo-module` são autolinkados; não precisa mexer em
  `settings.gradle`/`Podfile` à mão.
- **Rebuild obrigatório**: mudou código nativo do módulo? Precisa de novo dev build (`expo run:*`
  ou EAS) — não basta recarregar o JS.
- **TS interface**: dá pra gerar a interface TypeScript a partir do nativo
  (`modules/type-generation-tutorial.md`) para manter tipos em sincronia.
- **Teste em dev build, nunca no Expo Go** — Expo Go não carrega código nativo custom.
