# DOM Components - `'use dom'`

Anchor docs: `guides/dom-components.md`.

## What they are

DOM components let you render a component that uses **web APIs** (`<div>`, `<img>`, CSS) inside a
native Expo app. The marked component runs **inside a WebView** (through `@expo/dom-webview`, the
default since SDK 56); the rest of the app stays 100% native. It is the official bridge to reuse a
**web** library/component (e.g. a rich-text editor, a third-party player only available as web JS)
without porting everything to RN.

## The directive

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

On the native side, you import it and use it like a normal React component - the runtime wraps it
transparently in a `WebView`:

```tsx
import DOMComponent from "./my-component"; // the file with 'use dom'

export default function App() {
  return <DOMComponent name="Europe" />;
}
```

## How data crosses the native<->WebView boundary

- **Props**: only **JSON-serializable** data (`string`, `number`, `boolean`, array, object,
  `null`/`undefined`) crosses. Prop updates are **asynchronous** - do not expect frame-by-frame
  synchrony like Reanimated.
- **Native callbacks**: function props at the root level (not nested) let the DOM component call
  native code - but **always asynchronous**:

```tsx
// native side
<DomComponent hello={(data: string) => console.log("Hello", data)} />

// inside the DOM component
'use dom';
export default function MyComponent({ hello }: { hello: (data: string) => Promise<void> }) {
  return <p onClick={() => hello("world")}>Click me</p>;
}
```

- **Refs**: use `useDOMImperativeHandle` (SDK 53+) to expose imperative methods from the DOM
  component to the native side:

```tsx
// native side
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

- **WebView config**: the special `dom` prop forwards native `WebView` props (e.g.
  `<DOMComponent dom={{ scrollEnabled: false }} />`), typed inside the component through
  `dom?: import("expo/dom").DOMProps`.
- **Feature detection**: `import { IS_DOM } from "expo/dom"` and `process.env.EXPO_DOM_HOST_OS`
  (`"ios" | "android" | undefined`) to know whether the code runs inside a DOM component and on which
  host.

## Limitations - read before recommending

- **No `children`**: you cannot pass React children into a DOM component.
- **No native views inside the DOM component**: you do not embed `View`/RN components in it - it is
  an isolated web world.
- **State isolated per instance**: each DOM component has its own JS engine; global state does not
  cross the boundary (it does not automatically share a store with the native app).
- **No SSR/SSG**: it renders only as an SPA inside the WebView.
- **No OTA today**: the DOM component's content is embedded in the build; it is not updated by EAS
  Update in the current form (RSC may change that in the future - confirm status in the docs).
- **Synchronous routing APIs** (e.g. Expo Router's `useLocalSearchParams()`) do not work directly
  inside a DOM component - you must pass the values in manually through props.

## When to use it (and when not to)

Use DOM components to: reuse an **essentially web** library/UI that has no mature RN equivalent
(WYSIWYG editors, certain web-only canvas/chart libraries, third-party embeds). Do **not** use it as a
general shortcut to "write the UI in HTML/CSS" - that throws away native performance, native gestures
and integration with the rest of the app; for ordinary UI, RN plus
[animations-native-ui.md](animations-native-ui.md) remains the right path.
