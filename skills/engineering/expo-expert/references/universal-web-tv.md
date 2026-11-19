# Universal development - Web, PWA and TV

Anchor docs: search through `llms.txt` - `guides/publishing-websites`, `guides/progressive-web-apps`,
`guides/building-for-tv`, and the Expo Router docs for web rendering
([expo-router.md](expo-router.md)).

## The universal promise

Expo lets you publish from the same codebase to **iOS, Android and web** (and Smart TV), maximizing
sharing through **Universal UIs**. The web renderer is **React Native for Web**; the bundler is Metro;
the routing is the same Expo Router. The more you use RN primitives (`View`, `Text`, `Pressable`) and
universal libraries, the more code you share.

## Web and PWA

```bash
npx expo start --web
npx expo export --platform web     # generates the static/SSR site in dist/
```

- **Rendering modes** (`web.output` in `app.config`): `"single"` (SPA), `"static"` (SSG) or
  `"server"` (SSR + API Routes). Choose according to SEO/data - see [expo-router.md](expo-router.md).
- **PWA**: configure `manifest`, icons and service worker per the PWA docs. Good for installable +
  offline on the web without a store.
- **Deploy**: EAS Hosting serves the web output (or any static/Node host depending on the mode).
  Search `eas/hosting` in `llms.txt`.
- **Platform-specific code**: `*.web.tsx` / `*.native.tsx` / `*.ios.tsx` / `*.android.tsx` extensions
  and `Platform.select({ web, native, default })` to diverge where needed.

## Differences that bite (web vs native)

- Not every native library has a web shim - check before assuming parity. Use `Platform.OS === "web"`
  to guard native-only paths.
- Gestures, navigation and storage can diverge (e.g. `AsyncStorage` vs `localStorage` underneath).
- Actually test both platforms; "it compiles on native" does not guarantee web, and vice versa.
- SEO/meta tags and URLs matter on the web and are irrelevant in the app - Expo Router exposes
  `<Head>` and static routes for that.

## TV (Android TV / Apple TV)

Expo supports **Smart TVs** through the TV variant of React Native. Key points:

- It requires specific TV configuration (see `guides/building-for-tv.md`) and usually its own
  **build/dev client** - Expo Go does not cover TV.
- **Remote-control focus and navigation** is the big UX differentiator: think `TVFocusGuideView`,
  focus order and focus states, not touch.
- A lot of logic/state code is shareable; the UI/navigation layer is what diverges the most.

## Code sharing strategy (senior heuristic)

1. **Business logic, state, data fetching**: 100% shareable - keep it out of the UI layer.
2. **Components**: prefer universal RN primitives; isolate the platform-specific bits behind
   `*.web/*.native` files or `Platform.select`.
3. **Navigation**: Expo Router unifies it, but adjust patterns per platform (native tabs on mobile,
   header/links on web, focus on TV).
4. **Do not force 100% sharing.** The goal is to maximize reuse, not to eliminate platform-specific
   code - forcing full parity usually degrades the UX of each platform.
