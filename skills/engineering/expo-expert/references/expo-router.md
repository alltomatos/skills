# Expo Router — file-based routing universal

Doc-âncora: `router/introduction.md`, `router/basics/core-concepts.md`,
`router/basics/navigation.md`, `router/advanced/stack.md`, `router/advanced/authentication.md`.
Para recursos web (API Routes, SSR, RSC), baixe as páginas específicas via `llms.txt` — evoluem
rápido e algumas são experimentais.

## Modelo

Expo Router é roteamento **baseado em arquivos** sobre React Navigation: cada arquivo em `app/`
vira uma rota. Funciona igual em iOS, Android e web (universal). O bundler é o Metro.

```
app/
  _layout.tsx        # layout raiz (providers, Stack/Tabs)
  index.tsx          # rota "/"
  about.tsx          # rota "/about"
  (tabs)/            # grupo (não aparece na URL) — normalmente abas nativas
    _layout.tsx      # define <Tabs>
    home.tsx         # "/home"
    profile.tsx      # "/profile"
  blog/
    [slug].tsx       # rota dinâmica "/blog/:slug"
    [...rest].tsx    # catch-all
  +not-found.tsx     # 404
  +html.tsx          # (web) shell HTML do SSR
```

Convenções essenciais:
- **`_layout.tsx`** — define o navigator daquele nível (`Stack`, `Tabs`, `Drawer`) e envolve as
  rotas filhas. O layout raiz é onde vão providers globais.
- **`(grupo)`** — parênteses agrupam rotas **sem** virar segmento de URL. Use para organizar e para
  ter navigators distintos (ex.: `(auth)` vs `(app)`).
- **`[param]`** dinâmico, **`[...catchAll]`** catch-all.
- **`+`-prefixados** são rotas especiais (`+not-found`, `+html`, `+native-intent`).

## Navegação

```tsx
import { Link, router, useRouter, useLocalSearchParams } from "expo-router";

<Link href="/blog/hello">Ler post</Link>
<Link href={{ pathname: "/blog/[slug]", params: { slug: "hello" } }}>Ler</Link>;

// imperativo:
router.push("/profile");
router.replace("/login");
router.back();

// ler params:
const { slug } = useLocalSearchParams<{ slug: string }>();
```

- `push`/`replace`/`back`/`navigate` cobrem os casos; `replace` para fluxos onde não quer voltar
  (ex.: pós-login). Ver `router/basics/navigation.md`.
- **Typed routes**: habilite `experiments.typedRoutes` no `app.config` para autocompletar e checar
  `href` em tempo de tipo.

## Layouts: Stack, Tabs, Drawer

```tsx
// app/(tabs)/_layout.tsx
import { Tabs } from "expo-router";
export default function TabsLayout() {
  return (
    <Tabs screenOptions={{ headerShown: false }}>
      <Tabs.Screen name="home" options={{ title: "Início" }} />
      <Tabs.Screen name="profile" options={{ title: "Perfil" }} />
    </Tabs>
  );
}
```

Para abas verdadeiramente **nativas**, o Expo Router oferece componentes de native tabs
(mais próximos do comportamento de plataforma) — confira a doc de tabs, pois a API tem evoluído.
`Stack` (`router/advanced/stack.md`) cobre header nativo, `presentation: "modal"`, gestos, etc.

## Rotas protegidas (autenticação)

Padrão idiomático: um provider de auth no layout raiz + **redirecionamento por grupo**. A doc
(`router/advanced/authentication.md`) descreve o uso de **Protected routes** (`<Stack.Protected>`
/ guards) e/ou redirect declarativo:

```tsx
// app/_layout.tsx (esboço)
import { Redirect, Stack } from "expo-router";
import { useAuth } from "../lib/auth";

export default function RootLayout() {
  const { user, loading } = useAuth();
  if (loading) return null;         // splash
  return (
    <Stack>
      {/* grupo (app) só acessível logado; senão redireciona */}
      <Stack.Screen name="(app)" />
      <Stack.Screen name="(auth)" />
    </Stack>
  );
}
```

Na prática, faça o gate com `<Redirect href="/(auth)/login" />` quando `!user`, ou use os guards de
Protected routes conforme a versão do router instalada. **Confirme a API na doc** — este é um ponto
que mudou entre versões.

## Recursos web (universal)

O mesmo `app/` gera site. Recursos avançados (todos com páginas próprias na doc — busque via
`llms.txt`, e note quais são experimentais):

- **API Routes**: arquivos `app/**/<nome>+api.ts` exportam handlers (`GET`, `POST`, …) e viram
  endpoints server-side no mesmo projeto. Requer output server.
- **Rendering modes**: `web.output` no `app.config` — `"single"` (SPA), `"static"` (SSG) ou
  `"server"` (SSR + API Routes).
- **Data loaders** e **React Server Components (RSC)**: recursos mais novos/experimentais para
  carregar dados no servidor e enviar componentes renderizados. Estado e disponibilidade variam por
  versão — **sempre verifique a doc** antes de recomendar em produção.

## Gotchas de sênior

- **Estrutura de pastas É a navegação.** Refatorar rotas = mover arquivos; não há tabela central.
- **`_layout` esquecido**: sem `_layout.tsx` num nível com múltiplas telas, você perde o navigator.
- **Grupos para separar áreas**: `(auth)`/`(app)` é o padrão para apps com login.
- **Web + nativo divergem**: teste ambos; nem toda lib nativa tem shim web (ver
  [universal-web-tv.md](universal-web-tv.md)).
- **RSC/SSR ainda amadurecendo**: excelente para web/marketing, mas cheque status na doc antes de
  apostar num app crítico.
