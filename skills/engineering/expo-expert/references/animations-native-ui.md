# Animation, gestures and Native UI

Anchor docs: `versions/latest/sdk/reanimated.md`, `develop/user-interface/animation.md`,
`versions/latest/sdk/skia.md`, `versions/latest/sdk/gesture-handler.md`,
`versions/latest/sdk/ui.md`, `.../ui/swift-ui.md`, `.../ui/jetpack-compose.md`,
`.../ui/drop-in-replacements.md`, `.../ui/universal.md`, `guides/tailwind.md`.

## Animation: React Native Reanimated

**Reanimated** is the standard library for performant animation in Expo - it runs on the *UI thread*
(not the JS thread), so it does not stutter when the JS side is busy. It is the foundation of most
serious production animations.

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

- **`useSharedValue`** holds state that animates without a React re-render; **`useAnimatedStyle`**
  derives the style on the UI thread; **`withSpring`/`withTiming`** are the animation curves.
- It requires the **babel plugin** (`react-native-reanimated/plugin`) in `babel.config.js` - usually
  already configured by `expo install`; confirm it if animations do not fire.
- Compatible with the New Architecture (see [performance.md](performance.md)); old third-party
  libraries that depend on Reanimated may not support Fabric - check compatibility.

## Gestures: React Native Gesture Handler

A native gesture system (pan, pinch, swipe, long-press) that replaces `PanResponder`. It composes well
with Reanimated for gestures that animate in real time (drag-to-dismiss, swipe-to-delete).

```bash
npx expo install react-native-gesture-handler
```

```tsx
import { Gesture, GestureDetector } from "react-native-gesture-handler";

const pan = Gesture.Pan().onChange((e) => { translateX.value += e.changeX; });
<GestureDetector gesture={pan}><Animated.View style={style} /></GestureDetector>;
```

You must wrap the app root with `GestureHandlerRootView` (the Expo Router template already does it).

## Graphics and canvas: Skia

**`@shopify/react-native-skia`** (redistributed as the `expo-skia`/SDK package) brings a
high-performance 2D render engine for custom drawings, charts, effects and complex animations that
`View`/`Animated` do not cover well - paths, shaders, image filters.

```bash
npx expo install @shopify/react-native-skia
```

Use it for: custom data charts, drawing editors, rich visual effects. It is not the default for
ordinary UI - for that, prefer plain RN + Reanimated.

## Native UI: Expo UI (SwiftUI / Jetpack Compose)

**Expo UI** (`expo-ui`) exposes **real native views** - SwiftUI on iOS, Jetpack Compose on Android - as
React components, instead of recreating the native look with `View`/`Text`. Two usage modes:

1. **Drop-in replacements**: ready-made components (`Button`, `Switch`, `Slider`, `ContextMenu`, ...)
   that render the platform's *native* widget. See `sdk/ui/drop-in-replacements.md`.
2. **Universal / custom SwiftUI-Compose**: write the UI directly in SwiftUI (`sdk/ui/swift-ui.md`) or
   Jetpack Compose (`sdk/ui/jetpack-compose.md`) and expose it as a view through the Expo Modules API -
   see also `guides/expo-ui-swift-ui/extending.md` and `guides/expo-ui-jetpack-compose/extending.md` to
   extend it with your own native view. Cross-reference [native-modules.md](native-modules.md).

**When to use Expo UI vs pure RN components**: use Expo UI when 100% native fidelity matters (system
settings, context menus, controls that must look exactly like the OS). For brand/custom cross-platform
UI, pure RN (+ NativeWind/Tailwind) remains the simplest and most shareable path across
iOS/Android/web.

## Styling: Tailwind / NativeWind

Expo itself supports **CSS/Tailwind natively on the web** through Metro (it does not cover iOS/Android
directly):

```json
// app.json - prerequisite
{ "expo": { "web": { "bundler": "metro" } } }
```

```bash
# Tailwind v4 (recommended for new projects)
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
Import `global.css` in the root layout. On RN elements (`View`/`Text`), the class goes through
`style={{ $$css: true, _: "bg-slate-100 rounded-xl" }}` - that is **Expo's native support, web only**.

**For Tailwind to actually work on iOS/Android**, use **NativeWind** (or **Uniwind**) - separate
libraries that compile Tailwind classes to native `StyleSheet`. Do not confuse the two: Expo's native
CSS support is web-scoped; NativeWind is the universal path (web + iOS + Android).

## Senior gotchas

- **Reanimated without the babel plugin** = animations silently do not work (with no obvious error) -
  the first place to check when "the animation does not animate".
- **Wrap the root with `GestureHandlerRootView`** - gestures fail silently without it.
- **Skia is heavy**: do not use it for ordinary UI; reserve it for charts/effects that really need it.
- **Expo UI drop-in changes appearance per platform** by design (it is each OS's native widget) - do not
  expect pixel parity between iOS and Android with those components.
- **NativeWind != Expo's web CSS support** - they are different mechanisms; choose based on whether you
  want mobile parity.
