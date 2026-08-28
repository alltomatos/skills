# DOM Components — `'use dom'`

Doc-âncora: `guides/dom-components.md`.

## O que são

DOM components deixam você renderizar um componente que usa **APIs web** (`<div>`, `<img>`, CSS)
dentro de um app nativo Expo. O componente marcado roda **dentro de uma WebView** (via
`@expo/dom-webview`, default a partir do SDK 56); o restante do app continua 100% nativo. É a ponte
oficial para reaproveitar uma lib/component web (ex.: um editor rich-text, um player de terceiro só
disponível em JS web) sem portar tudo pra RN.

## A diretiva

```tsx
'use dom';

export default function DOMComponent({ name }: { name: string }) {
  return (
    <div>
      <h1>Hello, {name}</h1>
    </div>
  );
}
```

No lado nativo, você importa e usa como um componente React normal — o runtime embrulha
transparentemente numa `WebView`:

```tsx
import DOMComponent from "./my-component"; // arquivo com 'use dom'

export default function App() {
  return <DOMComponent name="Europa" />;
}
```

## Como dados cruzam a fronteira nativo↔WebView

- **Props**: só dados **serializáveis em JSON** (`string`, `number`, `boolean`, array, objeto,
  `null`/`undefined`) cruzam. As atualizações de prop são **assíncronas** — não espere sincronia
  quadro-a-quadro como em Reanimated.
- **Callbacks nativos**: props de função no nível raiz (não aninhadas) permitem que o DOM component
  chame código nativo — mas **sempre assíncrono**:

```tsx
// lado nativo
<DomComponent hello={(data: string) => console.log("Hello", data)} />

// dentro do DOM component
'use dom';
export default function MyComponent({ hello }: { hello: (data: string) => Promise<void> }) {
  return <p onClick={() => hello("world")}>Click me</p>;
}
```

- **Refs**: use `useDOMImperativeHandle` (SDK 53+) para expor métodos imperativos do DOM component
  ao lado nativo:

```tsx
// lado nativo
const ref = useRef<DOMRef>(null);
<MyComponent ref={ref} />
<Button title="focus" onPress={() => ref.current?.focus()} />

// DOM component
'use dom';
import { useDOMImperativeHandle, type DOMImperativeFactory } from "expo/dom";
export interface DOMRef extends DOMImperativeFactory { focus: () => void }
export default function MyComponent(props: { ref: Ref<DOMRef> }) {
  const inputRef = useRef<HTMLInputElement>(null);
  useDOMImperativeHandle(props.ref, () => ({ focus: () => inputRef.current?.focus() }), []);
  return <input ref={inputRef} />;
}
```

- **Config da WebView**: prop especial `dom` repassa props nativas de `WebView` (ex.:
  `<DOMComponent dom={{ scrollEnabled: false }} />`), tipada dentro do componente via
  `dom?: import("expo/dom").DOMProps`.
- **Feature detection**: `import { IS_DOM } from "expo/dom"` e
  `process.env.EXPO_DOM_HOST_OS` (`"ios" | "android" | undefined`) para saber se o código roda
  dentro de um DOM component e em qual host.

## Limitações — leia antes de recomendar

- **Sem `children`**: não dá pra passar children React para um DOM component.
- **Sem views nativas dentro do DOM component**: você não embute `View`/componentes RN dentro dele —
  é um mundo web isolado.
- **Estado isolado por instância**: cada DOM component tem seu próprio engine JS; estado global não
  atravessa a fronteira (não compartilha store com o app nativo automaticamente).
- **Sem SSR/SSG**: renderiza só como SPA dentro da WebView.
- **Sem OTA hoje**: o conteúdo do DOM component vem embutido no build; não é atualizado por EAS
  Update na forma atual (RSC pode mudar isso no futuro — confirme status na doc).
- **APIs síncronas de roteamento** (ex.: `useLocalSearchParams()` do Expo Router) não funcionam
  direto dentro de um DOM component — exigem repassar os valores via prop manualmente.

## Quando usar (e quando não)

Use DOM components para: reaproveitar uma lib/UI **essencialmente web** que não tem equivalente RN
maduro (editores WYSIWYG, certas libs de canvas/chart web-only, embeds de terceiros). **Não** use
como atalho geral para "escrever a UI em HTML/CSS" — isso joga fora performance nativa, gestos
nativos e a integração com o resto do app; para UI comum, RN + [animations-native-ui.md](animations-native-ui.md)
continua sendo o caminho certo.
