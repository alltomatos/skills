# CNG, Prebuild, Config Plugins e Dev Builds

Doc-âncora: `continuous-native-generation.md`, `config-plugins/introduction.md`, `.../mods.md`,
`.../dangerous-mods.md`, `develop/development-builds/introduction.md`.

## Continuous Native Generation (CNG)

CNG é o modelo em que as pastas nativas `android/` e `ios/` são **artefatos gerados sob demanda**,
não código-fonte. Elas nascem de três entradas:

1. Um **template** padrão, atrelado à versão do SDK.
2. Sua **config** em `app.json` / `app.config.js` / `app.config.ts` (a fonte da verdade).
3. **Config plugins** que modificam o template durante a geração.

Consequência: você mantém só a *definição* das customizações, não o código nativo inteiro. Isso é
o que mata os conceitos de "eject" e "managed vs bare" — não existem mais. Todo projeto é CNG.

### `npx expo prebuild`

Gera/atualiza `android/` e `ios/` a partir das três entradas acima. Também tem efeitos colaterais:
ajusta scripts do `package.json` (troca `expo start --android` por `expo run:android`) e pode mexer
em dependências.

```bash
npx expo prebuild                      # gera as duas plataformas (incremental)
npx expo prebuild --clean              # apaga android/ios antes de regenerar — DEFAULT SEGURO
npx expo prebuild --platform ios       # só uma plataforma
npx expo prebuild --template /caminho/template.tgz   # raro; não recomendado
```

- **Use `--clean` por padrão.** Config plugins nem sempre são idempotentes; aplicar sobre pastas já
  modificadas gera estado inconsistente. `--clean` regenera do zero.
- Rodar `npx expo run:android` / `run:ios` faz um prebuild implícito quando necessário.

### Gitignore das pastas nativas

Num fluxo CNG puro, `android/` e `ios/` ficam no `.gitignore` (projetos novos já fazem isso). Se um
projeto tiver pastas nativas versionadas e você quiser que o EAS Build as ignore, adicione ao
`.gitignore` ou `.easignore` para o EAS não tratá-las como fonte. Editar as pastas geradas à mão é
antipadrão — a próxima prebuild sobrescreve.

### `npx expo prebuild --clean` vs editar nativo à mão

Precisa de algo que o `app.json` não expõe (um valor no `AndroidManifest.xml`, uma key no
`Info.plist`, um arquivo Gradle)? A resposta idiomática é **escrever um config plugin**, não editar
a pasta gerada. Para casos extremos onde um plugin é inviável, existe `patch-project`
(`config-plugins/patch-project.md`), que versiona um patch aplicado sobre o nativo gerado — mas
trate como último recurso.

## Config Plugins

Config plugins são **funções que rodam durante o prebuild** e transformam os arquivos nativos.
Substituem edições manuais, eliminando código órfão e permitindo que autores de libs automatizem o
setup nativo de forma versionada e testável.

### Anatomia

Um plugin é uma função `(config, props) => config`. Você a registra em `app.config.js`:

```js
// app.config.js
export default {
  expo: {
    plugins: [
      "expo-camera",                          // plugin de uma lib
      ["./plugins/withCustomManifest", { foo: "bar" }],  // seu plugin + props
    ],
  },
};
```

### Mods

Um **mod** é um plugin assíncrono especial que dá acesso a um arquivo nativo específico para
modificá-lo. Os principais (de `@expo/config-plugins`):

- `withAndroidManifest` — modifica o `AndroidManifest.xml` (recebe o XML parseado).
- `withInfoPlist` — modifica o `Info.plist` do iOS.
- `withAppBuildGradle` / `withProjectBuildGradle` — arquivos Gradle.
- `withEntitlementsPlist`, `withXcodeProject`, `withStringsXml`, `withColorsXml`, `withGradleProperties`, etc.

Exemplo — adicionar uma permissão e uma `<meta-data>` ao manifest:

```js
const { withAndroidManifest, AndroidConfig } = require("@expo/config-plugins");

module.exports = function withCustomManifest(config, { apiKey }) {
  return withAndroidManifest(config, (config) => {
    const app = AndroidConfig.Manifest.getMainApplicationOrThrow(config.modResults);
    AndroidConfig.Manifest.addMetaDataItemToMainApplication(app, "com.example.API_KEY", apiKey);
    return config;
  });
};
```

Use os helpers de `AndroidConfig` / `IOSConfig` (`AndroidConfig.Manifest`, `IOSConfig.Permissions`,
etc.) — eles fazem a manipulação de XML/plist de forma segura em vez de string-replace.

### Dangerous mods

`withDangerousMod` dá acesso *bruto* ao sistema de arquivos do projeto nativo durante o prebuild,
**sem** um parser estruturado. Use apenas quando não há mod dedicado — ex.: criar/copiar um arquivo,
mexer num arquivo que nenhum mod cobre.

```js
const { withDangerousMod } = require("@expo/config-plugins");
const fs = require("fs");
const path = require("path");

module.exports = function withCopyAsset(config) {
  return withDangerousMod(config, [
    "ios",
    async (config) => {
      const root = config.modRequest.platformProjectRoot; // ex.: <proj>/ios
      fs.copyFileSync(path.join(__dirname, "GoogleService-Info.plist"),
                      path.join(root, "GoogleService-Info.plist"));
      return config;
    },
  ]);
};
```

Por que "dangerous": rodam sem garantia de ordem em relação a outros mods e sem idempotência
automática — você é responsável por não quebrar o que outro plugin fez. Torne-os idempotentes
(cheque antes de escrever) e mantenha-os pequenos.

### Debugar config plugins

- **`npx expo prebuild --clean` e inspecione o resultado** em `android/`/`ios/` para ver o efeito
  real do plugin.
- `EXPO_DEBUG=1 npx expo prebuild` dá stack traces melhores quando um plugin lança erro.
- `npx expo config --type prebuild` mostra a config resolvida após aplicar os plugins.
- Doc: `config-plugins/development-and-debugging.md`. Plugins escritos em TS podem precisar de build
  para JS antes de serem consumidos.

## Development builds (dev client)

Um *development build* é a sua versão do app com a lib `expo-dev-client` — "o seu próprio Expo Go".
Diferente do Expo Go, ele roda **qualquer** lib nativa e config nativa custom, e traz um launcher
para alternar entre servidores de dev e deployments.

```bash
npx expo install expo-dev-client
npx expo run:android        # build local + instala (precisa do toolchain Android)
npx expo run:ios            # idem iOS (macOS/Xcode)
# ou build na nuvem:
eas build --profile development --platform android
```

- **Regra mental**: adicionou uma lib com código nativo? O Expo Go não roda mais — você precisa de
  um dev build. Só rebuilde quando: instalar lib nativa nova, mudar config nativa (`app.json`), ou
  subir de SDK. No dia a dia, `npx expo start` basta.
- Três formas de buildar: **local** (`expo run:*`, toolchain próprio), **EAS cloud build** (sem
  toolchain local, precisa de conta EAS) e **EAS local build** (infra EAS, compila na sua máquina).
