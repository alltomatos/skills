# Data fetching e persistência local

Doc-âncora: `versions/latest/sdk/sqlite.md`. A doc do Expo não prescreve uma lib de data-fetching
específica (não há guia oficial de "React Query vs SWR") — este arquivo cobre o padrão idiomático do
ecossistema RN/Expo, mas confirme sempre a versão/API exata das libs de terceiro na doc delas.

## Fetching remoto: TanStack Query é o padrão de fato

Não há solução "oficial" do Expo para data-fetching remoto — a comunidade RN convergiu para
**TanStack Query (React Query)** como padrão para cache, revalidação e estado de loading/erro.
SWR é a alternativa mais leve, com API parecida.

```bash
npx expo install @tanstack/react-query
```

```tsx
import { QueryClient, QueryClientProvider, useQuery } from "@tanstack/react-query";

const queryClient = new QueryClient();

// no layout raiz (app/_layout.tsx no Expo Router):
<QueryClientProvider client={queryClient}>{children}</QueryClientProvider>;

function Profile() {
  const { data, isLoading, error } = useQuery({
    queryKey: ["profile", userId],
    queryFn: () => fetch(`${API_URL}/users/${userId}`).then((r) => r.json()),
  });
}
```

**Por que não `useEffect` + `fetch` cru**: sem cache/dedupe/retry, cada navegação refaz a chamada,
race conditions em unmount não são tratadas, e não há revalidação em foco/reconexão. React Query
resolve isso de fábrica — vale a dependência mesmo em apps pequenos com mais de uma tela que busca
dado.

### API Routes do Expo Router como backend leve

Se o backend é simples, o próprio [Expo Router](expo-router.md) pode servir os endpoints
(`app/**/<nome>+api.ts`), eliminando um serviço separado para CRUD básico — bom para MVPs ou BFF.

## Persistência local — três camadas, escolha pela necessidade

| Necessidade | Ferramenta |
|---|---|
| Chave-valor simples, não sensível (preferências, flags) | `@react-native-async-storage/async-storage` |
| Dado **sensível** (tokens, credenciais) | `expo-secure-store` (usa Keychain/Keystore nativo) |
| Dado relacional/estruturado, queries, offline-first real | `expo-sqlite` |

```bash
npx expo install @react-native-async-storage/async-storage expo-secure-store expo-sqlite
```

```ts
// SecureStore para segredo
import * as SecureStore from "expo-secure-store";
await SecureStore.setItemAsync("authToken", token);
const token = await SecureStore.getItemAsync("authToken");
```

```ts
// SQLite para dado estruturado
import * as SQLite from "expo-sqlite";
const db = await SQLite.openDatabaseAsync("app.db");
await db.execAsync(`CREATE TABLE IF NOT EXISTS todos (id INTEGER PRIMARY KEY, title TEXT);`);
const rows = await db.getAllAsync("SELECT * FROM todos");
```

**Nunca guarde token/segredo em AsyncStorage** — não é criptografado no disco. Use `SecureStore`.

## Offline-first e cache

Combine React Query (`persistQueryClient` + um `AsyncStorage`/`SQLite` persister) para sobreviver a
restart do app com dado em cache, e `NetInfo` (`@react-native-community/netinfo`) para detectar
conectividade e pausar/retomar mutations. Para apps genuinamente offline-first (edição local,
sincronização depois), SQLite + uma fila de mutations pendentes é o padrão mais robusto que cache de
query sozinho.

## Gotchas de sênior

- **Não misture AsyncStorage com dado sensível** — é o erro de segurança mais comum nesse tema.
- **`queryKey` mal desenhada** é a causa nº 1 de bug "dado não atualiza" em React Query — inclua
  todos os parâmetros que afetam o resultado na key.
- **SQLite é assíncrono** na API moderna (`openDatabaseAsync`/`execAsync`/`getAllAsync`) — não
  confunda com versões antigas de callback síncrono de libs mais velhas.
- **Fetch com `EXPO_PUBLIC_*` env vars**: URLs de API que dependem de env pública só resolvem
  corretamente se a env var existir no momento do build (são inlined) — mudar depois exige rebuild,
  não só um OTA.
