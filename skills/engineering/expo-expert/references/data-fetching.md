# Data fetching and local persistence

Anchor docs: `versions/latest/sdk/sqlite.md`. The Expo docs do not prescribe a specific data-fetching
library (there is no official "React Query vs SWR" guide) - this file covers the idiomatic RN/Expo
pattern, but always confirm the exact version/API of third-party libraries in their own docs.

## Remote fetching: TanStack Query is the de facto standard

There is no "official" Expo solution for remote data fetching - the RN community converged on
**TanStack Query (React Query)** as the standard for caching, revalidation and loading/error state.
SWR is the lighter alternative, with a similar API.

```bash
npx expo install @tanstack/react-query
```

```tsx
import { QueryClient, QueryClientProvider, useQuery } from "@tanstack/react-query";

const queryClient = new QueryClient();

// in the root layout (app/_layout.tsx in Expo Router):
<QueryClientProvider client={queryClient}>{children}</QueryClientProvider>;

function Profile() {
  const { data, isLoading, error } = useQuery({
    queryKey: ["profile", userId],
    queryFn: () => fetch(`${API_URL}/users/${userId}`).then((r) => r.json()),
  });
}
```

**Why not `useEffect` + raw `fetch`**: no cache/dedupe/retry, every navigation repeats the call, race
conditions on unmount are not handled, and there is no revalidation on focus/reconnect. React Query
solves this out of the box - the dependency is worth it even in small apps with more than one screen
that loads data.

### Expo Router API Routes as a lightweight backend

If the backend is simple, [Expo Router](expo-router.md) itself can serve the endpoints
(`app/**/<name>+api.ts`), removing a separate service for basic CRUD - good for MVPs or a BFF.

## Streaming and Server-Sent Events with no extra library

To consume an SSE endpoint (`Content-Type: text/event-stream`) in RN, the commonly recommended route
is `react-native-sse` or an `EventSource` polyfill - but `expo/fetch` (a WinterCG-compliant
implementation that Expo itself exposes, supported on Android/iOS/tvOS/web/Expo Go) already gives you
a native streaming reader, which removes that dependency for anyone who just needs to parse SSE
manually:

```ts
import { fetch } from "expo/fetch";

const res = await fetch(url, { headers: { Accept: "text/event-stream" }, signal });
const reader = res.body!.getReader();
const decoder = new TextDecoder();
let buffer = "";

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  buffer += decoder.decode(value, { stream: true });
  // split on "\n\n", extract the "data:" lines, JSON.parse - a few
  // parser lines cover the common case without needing EventSource.
}
```

Validated in production as a client for a backend with real SSE (`GET /event`) - the only gotcha is
that `expo/fetch` automatically becomes the global `fetch` on native; to keep RN's builtin `fetch`
side by side, use `EXPO_PUBLIC_USE_RN_FETCH=1` (named imports from `expo/fetch` keep working either
way).

## Local persistence - three layers, choose by need

| Need | Tool |
|---|---|
| Simple, non-sensitive key-value (preferences, flags) | `@react-native-async-storage/async-storage` |
| **Sensitive** data (tokens, credentials) | `expo-secure-store` (uses the native Keychain/Keystore) |
| Relational/structured data, queries, real offline-first | `expo-sqlite` |

```bash
npx expo install @react-native-async-storage/async-storage expo-secure-store expo-sqlite
```

```ts
// SecureStore for a secret
import * as SecureStore from "expo-secure-store";
await SecureStore.setItemAsync("authToken", token);
const token = await SecureStore.getItemAsync("authToken");
```

```ts
// SQLite for structured data
import * as SQLite from "expo-sqlite";
const db = await SQLite.openDatabaseAsync("app.db");
await db.execAsync(`CREATE TABLE IF NOT EXISTS todos (id INTEGER PRIMARY KEY, title TEXT);`);
const rows = await db.getAllAsync("SELECT * FROM todos");
```

**Never store a token/secret in AsyncStorage** - it is not encrypted on disk. Use `SecureStore`.

## Offline-first and caching

Combine React Query (`persistQueryClient` + an `AsyncStorage`/`SQLite` persister) to survive an app
restart with cached data, and `NetInfo` (`@react-native-community/netinfo`) to detect connectivity
and pause/resume mutations. For genuinely offline-first apps (local editing, syncing later), SQLite
plus a queue of pending mutations is the most robust pattern - more than a query cache alone.

## Senior gotchas

- **Do not mix AsyncStorage with sensitive data** - it is the most common security mistake on this
  topic.
- **A badly designed `queryKey`** is the number one cause of the "data does not update" bug in React
  Query - include every parameter that affects the result in the key.
- **SQLite is async** in the modern API (`openDatabaseAsync`/`execAsync`/`getAllAsync`) - do not
  confuse it with older libraries' synchronous callback versions.
- **Fetch with `EXPO_PUBLIC_*` env vars**: API URLs that depend on a public env var only resolve
  correctly if the env var exists at build time (they are inlined) - changing it later requires a
  rebuild, not just an OTA.
