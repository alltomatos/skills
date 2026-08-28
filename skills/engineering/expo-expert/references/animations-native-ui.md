# Animação, gestos e Native UI

Doc-âncora: `versions/latest/sdk/reanimated.md`, `develop/user-interface/animation.md`,
`versions/latest/sdk/skia.md`, `versions/latest/sdk/gesture-handler.md`,
`versions/latest/sdk/ui.md`, `.../ui/swift-ui.md`, `.../ui/jetpack-compose.md`,
`.../ui/drop-in-replacements.md`, `.../ui/universal.md`, `guides/tailwind.md`.

## Animação: React Native Reanimated

**Reanimated** é a lib padrão para animação performática em Expo — roda no *UI thread* (não no JS
thread), então não trava com o JS ocupado. É o alicerce da maioria das animações sérias em produção.

```bash
npx expo install react-native-reanimated
```

```tsx
import Animated, { useSharedValue, useAnimatedStyle, withSpring } from "react-native-reanimated";

function Box() {
  const scale = useSharedValue(1);
  const style = useAnimatedStyle(() => ({ transform: [{ scale: scale.value }] }));
  return (
    <Animated.View style={style} onTouchEnd={() => (scale.value = withSpring(scale.value === 1 ? 1.2 : 1))} />
  );
}
```

- **`useSharedValue`** guarda estado que anima sem re-render React; **`useAnimatedStyle`** deriva o
  style no UI thread; **`withSpring`/`withTiming`** são as curvas de animação.
- Requer o **babel plugin** (`react-native-reanimated/plugin`) no `babel.config.js` — já vem
  configurado pelo `expo install` na maioria dos casos; confirme se animações não disparam.
- Compatível com Nova Arquitetura (ver [performance.md](performance.md)); versões antigas de libs
  de terceiro que dependem de Reanimated podem não suportar Fabric — cheque compatibilidade.

## Gestos: React Native Gesture Handler

Sistema de gestos nativo (pan, pinch, swipe, long-press) que substitui `PanResponder`. Compõe bem
com Reanimated para gestos que animam em tempo real (drag-to-dismiss, swipe-to-delete).

```bash
npx expo install react-native-gesture-handler
```

```tsx
import { Gesture, GestureDetector } from "react-native-gesture-handler";

const pan = Gesture.Pan().onChange((e) => { translateX.value += e.changeX; });
<GestureDetector gesture={pan}><Animated.View style={style} /></GestureDetector>;
```

Precisa envolver a raiz do app com `GestureHandlerRootView` (o template do Expo Router já faz isso).

## Gráficos e canvas: Skia

**`@shopify/react-native-skia`** (redistribuído como `expo-skia`/SDK package) traz um motor de
render 2D de alta performance para desenhos custom, gráficos, efeitos e animações complexas que
`View`/`Animated` não cobrem bem — paths, shaders, filtros de imagem.

```bash
npx expo install @shopify/react-native-skia
```

Use quando: gráficos de dados custom, editores de desenho, efeitos visuais ricos. Não é o default
para UI comum — para isso, prefira RN puro + Reanimated.

## Native UI: Expo UI (SwiftUI / Jetpack Compose)

**Expo UI** (`expo-ui`) expõe **views nativas reais** — SwiftUI no iOS, Jetpack Compose no Android —
como componentes React, em vez de recriar o look nativo com `View`/`Text`. Dois modos de uso:

1. **Drop-in replacements**: componentes prontos (`Button`, `Switch`, `Slider`, `ContextMenu`, …)
   que renderizam o widget *nativo* da plataforma. Ver `sdk/ui/drop-in-replacements.md`.
2. **Universal / custom SwiftUI-Compose**: escrever a UI diretamente em SwiftUI (`sdk/ui/swift-ui.md`)
   ou Jetpack Compose (`sdk/ui/jetpack-compose.md`) e expor como view via a Expo Modules API — ver
   também `guides/expo-ui-swift-ui/extending.md` e `guides/expo-ui-jetpack-compose/extending.md`
   para estender com view nativa própria. Cruze com [native-modules.md](native-modules.md).

**Quando usar Expo UI vs componentes RN puros**: use Expo UI quando a fidelidade 100% nativa importa
(configurações do sistema, menus de contexto, controles que devem parecer exatamente com o SO). Para
UI de marca/custom cross-platform, RN puro (+ NativeWind/Tailwind) continua sendo o caminho mais
simples e mais compartilhável entre iOS/Android/web.

## Styling: Tailwind / NativeWind

O próprio Expo tem suporte **nativo a CSS/Tailwind na web** via Metro (não cobre iOS/Android
diretamente):

```json
// app.json — pré-requisito
{ "expo": { "web": { "bundler": "metro" } } }
```

```bash
# Tailwind v4 (recomendado em projetos novos)
npx expo install tailwindcss @tailwindcss/postcss postcss --dev
```
```js
// postcss.config.js
export default { plugins: { "@tailwindcss/postcss": {} } };
```
```css
/* global.css */
@import "tailwindcss";
```
Importe `global.css` no layout raiz. Em elementos RN (`View`/`Text`), a classe passa via
`style={{ $$css: true, _: "bg-slate-100 rounded-xl" }}` — isso é o suporte **nativo do Expo, só web**.

**Para Tailwind funcionar de fato em iOS/Android**, use **NativeWind** (ou **Uniwind**) — libs
separadas que compilam classes Tailwind para `StyleSheet` nativo. Não confunda os dois: o suporte
CSS nativo do Expo é escopo web; NativeWind é o caminho universal (web + iOS + Android).

## Gotchas de sênior

- **Reanimated sem o babel plugin** = animações silenciosamente não funcionam (sem erro óbvio) —
  primeiro lugar a checar quando "a animação não anima".
- **Envolva a raiz com `GestureHandlerRootView`** — gestos falham silenciosamente sem isso.
- **Skia é pesado**: não use pra UI comum; reserve para gráficos/efeitos que realmente precisam.
- **Expo UI drop-in muda a aparência por plataforma** por design (é o nativo de cada SO) — não
  espere pixel-parity entre iOS e Android com esses componentes.
- **NativeWind ≠ suporte CSS web do Expo** — são mecanismos diferentes; escolha com base em querer
  ou não paridade mobile.
