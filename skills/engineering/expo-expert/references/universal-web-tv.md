# Desenvolvimento universal — Web, PWA e TV

Doc-âncora: busque via `llms.txt` — `guides/publishing-websites`, `guides/progressive-web-apps`,
`guides/building-for-tv`, e a doc do Expo Router para rendering web
([expo-router.md](expo-router.md)).

## A promessa universal

Expo permite publicar do mesmo código-base para **iOS, Android e web** (e Smart TV), maximizando o
compartilhamento via **Universal UIs**. O renderer web é o **React Native for Web**; o bundler é o
Metro; o roteamento é o mesmo Expo Router. Quanto mais você usa primitivos RN (`View`, `Text`,
`Pressable`) e libs universais, mais código compartilha.

## Web e PWA

```bash
npx expo start --web
npx expo export --platform web     # gera o site estático/SSR em dist/
```

- **Rendering modes** (`web.output` no `app.config`): `"single"` (SPA), `"static"` (SSG) ou
  `"server"` (SSR + API Routes). Escolha conforme SEO/dados — ver [expo-router.md](expo-router.md).
- **PWA**: configure `manifest`, ícones e service worker conforme a doc de PWA. Bom para instalável
  + offline em web sem loja.
- **Deploy**: EAS Hosting hospeda o output web (ou qualquer host estático/Node conforme o mode).
  Busque `eas/hosting` no `llms.txt`.
- **Platform-specific code**: extensões `*.web.tsx` / `*.native.tsx` / `*.ios.tsx` / `*.android.tsx`
  e `Platform.select({ web, native, default })` para divergir onde necessário.

## Diferenças que mordem (web vs nativo)

- Nem toda lib nativa tem shim web — cheque antes de assumir paridade. `Platform.OS === "web"` para
  guardar caminhos só-nativos.
- Gestos, navegação e storage podem divergir (ex.: `AsyncStorage` vs `localStorage` por baixo).
- Teste as duas plataformas de fato; "compila no nativo" não garante web e vice-versa.
- SEO/meta tags e URLs importam na web e são irrelevantes no app — Expo Router expõe `<Head>` e
  rotas estáticas para isso.

## TV (Android TV / Apple TV)

Expo suporta **Smart TVs** via a variante TV do React Native. Pontos-chave:
- Requer configuração específica de TV (ver `guides/building-for-tv.md`) e normalmente um
  **build/dev client próprio** — Expo Go não cobre TV.
- **Foco e navegação por controle remoto** é o grande diferencial de UX: pense em `TVFocusGuideView`,
  ordem de foco e estados de foco, não em toque.
- Muito código de lógica/estado é compartilhável; a camada de UI/navegação é o que mais diverge.

## Estratégia de code sharing (heurística de sênior)

1. **Lógica de negócio, estado, data-fetching**: 100% compartilhável — mantenha fora da camada de UI.
2. **Componentes**: prefira primitivos RN universais; isole o específico de plataforma atrás de
   arquivos `*.web/*.native` ou `Platform.select`.
3. **Navegação**: Expo Router unifica, mas ajuste padrões por plataforma (abas nativas no mobile,
   header/links na web, foco no TV).
4. **Não force 100% de share.** O objetivo é maximizar reuso, não eliminar o código específico —
   forçar paridade total costuma piorar a UX de cada plataforma.
