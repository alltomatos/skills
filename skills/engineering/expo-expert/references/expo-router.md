# Expo Router - universal file-based routing

Anchor docs: `router/introduction.md`, `router/basics/core-concepts.md`,
`router/basics/navigation.md`, `router/advanced/stack.md`, `router/advanced/authentication.md`.
For web features (API Routes, SSR, RSC), download the specific pages through `llms.txt` - they evolve
fast and some are experimental.

## Model

Expo Router is **file-based** routing on top of React Navigation: every file in `app/` becomes a
route. It works the same on iOS, Android and web (universal). The bundler is Metro.

```
app/
  _layout.tsx        # root layout (providers, Stack/Tabs)
  index.tsx          # route "/"
  about.tsx          # route "/about"
  (tabs)/            # group (not in the URL) - usually native tabs
    _layout.tsx      # defines <Tabs>
    home.tsx         # "/home"
    profile.tsx      # "/profile"
  blog/
    [slug].tsx       # dynamic route "/blog/:slug"
    [...rest].tsx    # catch-all
  +not-found.tsx     # 404
  +html.tsx          # (web) SSR HTML shell
```

Essential conventions:

- **`_layout.tsx`** - defines that level's navigator (`Stack`, `Tabs`, `Drawer`) and wraps the child
  routes. The root layout is where global providers go.
- **`(group)`** - parentheses group routes **without** becoming a URL segment. Use them to organize
  and to have distinct navigators (e.g. `(auth)` vs `(app)`).
- **`[param]`** dynamic, **`[...catchAll]`** catch-all.
- **`+`-prefixed** files are special routes (`+not-found`, `+html`, `+native-intent`).

## Navigation

```tsx
import { Link, router, useRouter, useLocalSearchParams } from "expo-router";

<Link href="/blog/hello">Read post</Link>
<Link href={{ pathname: "/blog/[slug]", params: { slug: "hello" } }}>Read</Link>;

// imperative:
router.push("/profile");
router.replace("/login");
router.back();

// read params:
const { slug } = useLocalSearchParams<{ slug: string }>();
```

- `push`/`replace`/`back`/`navigate` cover the cases; `replace` for flows where you do not want to go
  back (e.g. after login). See `router/basics/navigation.md`.
- **Typed routes**: enable `experiments.typedRoutes` in `app.config` for autocomplete and type-time
  checking of `href`.

## Layouts: Stack, Tabs, Drawer

```tsx
// app/(tabs)/_layout.tsx
import { Tabs } from "expo-router";
export default function TabsLayout() {
  return (
    <Tabs screenOptions={{ headerShown: false }}>
      <Tabs.Screen name="home" options={{ title: "Home" }} />
      <Tabs.Screen name="profile" options={{ title: "Profile" }} />
    </Tabs>
  );
}
```

For truly **native** tabs, Expo Router offers native tabs components (closer to platform behavior) -
check the tabs documentation, since the API has been evolving. `Stack` (`router/advanced/stack.md`)
covers the native header, `presentation: "modal"`, gestures, etc.

## Protected routes (authentication)

Idiomatic pattern: an auth provider in the root layout + **redirect by group**. The docs
(`router/advanced/authentication.md`) describe the use of **Protected routes** (`<Stack.Protected>` /
guards) and/or a declarative redirect:

```tsx
// app/_layout.tsx (sketch)
import { Redirect, Stack } from "expo-router";
import { useAuth } from "../lib/auth";

export default function RootLayout() {
  const { user, loading } = useAuth();
  if (loading) return null;         // splash
  return (
    <Stack>
      {/* group (app) only reachable when logged in; otherwise redirect */}
      <Stack.Screen name="(app)" />
      <Stack.Screen name="(auth)" />
    </Stack>
  );
}
```

In practice, gate with `<Redirect href="/(auth)/login" />` when `!user`, or use the Protected route
guards according to the installed router version. **Confirm the API in the docs** - this is a point
that changed between versions.

## Web features (universal)

The same `app/` produces a website. Advanced features (all with their own doc pages - search through
`llms.txt`, and note which are experimental):

- **API Routes**: files `app/**/<name>+api.ts` export handlers (`GET`, `POST`, ...) and become
  server-side endpoints in the same project. Requires server output.
- **Rendering modes**: `web.output` in `app.config` - `"single"` (SPA), `"static"` (SSG) or
  `"server"` (SSR + API Routes).
- **Data loaders** and **React Server Components (RSC)**: newer/experimental features to load data on
  the server and send rendered components. Status and availability vary by version - **always check
  the docs** before recommending them for production.

## Senior gotchas

- **The folder structure IS the navigation.** Refactoring routes = moving files; there is no central
  table.
- **Forgotten `_layout`**: without a `_layout.tsx` at a level with multiple screens, you lose the
  navigator.
- **Groups to separate areas**: `(auth)`/`(app)` is the standard for apps with login.
- **Web + native diverge**: test both; not every native library has a web shim (see
  [universal-web-tv.md](universal-web-tv.md)).
- **RSC/SSR still maturing**: excellent for web/marketing, but check the doc status before betting a
  critical app on it.
- **`KeyboardAvoidingView` may simply not work on Android inside a `Stack`.** Confirmed in
  production: neither `behavior="height"` nor `behavior={undefined}` fixed a chat composer hiding
  behind the keyboard - the cause is that Expo Router runs each screen in a native Fragment through
  `react-native-screens` (native-stack), and that Fragment does not take part in Android's window
  resize (`windowSoftInputMode=resize`) the way a "pure" Activity would. The officially supported fix
  is the `react-native-keyboard-controller` library (`docs.expo.dev/guides/keyboard-handling.md`) -
  but it **does not work in Expo Go**, it needs a development build, so it is not a swap to make in
  the middle of a testing session through Expo Go. An alternative that works in Expo Go and depends
  on no OS/Fragment resize: **measure the keyboard height manually** with
  `Keyboard.addListener('keyboardDidShow', e => e.endCoordinates.height)` (`keyboardWillShow` on iOS)
  and apply that value as `paddingBottom` on the screen's root container - no `KeyboardAvoidingView`
  at all. It works the same in Expo Go and in a dev build, so you do not need to switch again when
  the app later migrates to a development build.
