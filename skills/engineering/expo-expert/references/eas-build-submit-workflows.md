# EAS Build, Submit e Workflows

Doc-âncora: `build/introduction.md`, `build/setup.md`, `build/eas-json.md`,
`build/internal-distribution.md`, `submit/android.md`, `submit/ios.md`, `submit/testflight.md`,
`submit/eas-json.md`, `eas/workflows/introduction.md`, `.../get-started.md`, `.../syntax.md`,
`.../pre-packaged-jobs.md`.

## EAS Build

Serviço de build na nuvem da Expo. Compila `.apk`/`.aab` (Android) e `.ipa` (iOS) sem você manter
toolchain local, com gerenciamento de credenciais integrado.

```bash
npm i -g eas-cli          # ou: npx eas-cli@latest ...
eas login
eas build:configure       # cria/prepara o eas.json
eas build --profile production --platform all
eas build --profile preview --platform android
eas build:list            # histórico
```

### `eas.json` — build profiles

O `eas.json` define **profiles** de build. Estrutura típica:

```json
{
  "cli": { "version": ">= 12.0.0" },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "channel": "preview"
    },
    "production": {
      "channel": "production",
      "autoIncrement": true
    }
  },
  "submit": {
    "production": {}
  }
}
```

Conceitos-chave:
- **`developmentClient: true`** → build com `expo-dev-client` (dev build). Ver
  [cng-config-plugins.md](cng-config-plugins.md).
- **`distribution: "internal"`** → distribuição interna (link/QR) sem passar pelas lojas; ótimo para
  QA. Ver `build/internal-distribution.md`.
- **`channel`** → conecta o build a um channel do EAS Update. Ver [eas-update.md](eas-update.md).
- Profiles herdam via **`extends`**; use env vars por profile (`"env": { ... }`) e
  **EAS Environment Variables / Secrets** para valores sensíveis (nunca commite chave no `eas.json`).
- `autoIncrement` cuida do bump de `versionCode`/`buildNumber`.

### Credenciais

- **Android**: EAS gera/gerencia o **keystore** por você (recomendado) ou você fornece o seu.
- **iOS**: EAS gerencia certificados de distribuição e **provisioning profiles**; requer conta Apple
  Developer paga. `eas credentials` inspeciona/edita.
- **Regra**: deixe o EAS gerenciar salvo motivo forte. Guarde backup do keystore Android — perdê-lo
  impede atualizar o app publicado.

### Build local com infra EAS

`eas build --local` compila na sua máquina usando a mesma pipeline — útil para debugar o build ou
evitar a fila da nuvem.

## EAS Submit

Automatiza o envio do binário para as lojas.

```bash
eas submit --platform ios --profile production
eas submit --platform android --latest    # envia o build mais recente
eas build --auto-submit --profile production --platform all   # build + submit numa tacada
```

- **iOS**: sobe para App Store Connect / TestFlight. Configure `submit.<profile>` no `eas.json`
  (Apple ID/ASC App ID/API Key). Ver `submit/ios.md`, `submit/testflight.md`.
- **Android**: sobe para o Google Play via **Service Account JSON**. Configure `serviceAccountKeyPath`
  e `track` (`internal`/`alpha`/`beta`/`production`). Ver `submit/android.md`.

## EAS Workflows (CI/CD)

Pipelines de CI/CD nativas do EAS, definidas em YAML em `.eas/workflows/`. Automatizam build, submit,
update, testes e jobs em resposta a eventos de git (push, PR).

```yaml
# .eas/workflows/production-deploy.yml
name: Production deploy
on:
  push:
    branches: ["main"]
jobs:
  build_android:
    type: build
    params:
      platform: android
      profile: production
  submit_android:
    needs: [build_android]
    type: submit
    params:
      platform: android
```

- **Jobs pré-empacotados** (`pre-packaged-jobs.md`): `build`, `submit`, `update`, e outros — você
  referencia por `type` em vez de escrever shell.
- **`needs`** cria o grafo de dependências entre jobs (sequência/paralelo).
- **Sintaxe completa** em `eas/workflows/syntax.md` (triggers, params, matrizes, control flow).
- Rode local/manualmente com `eas workflow:run <arquivo.yml>`.

### Testes E2E com Maestro

Workflows integram **Maestro** para testes de UI end-to-end em builds — o padrão para gate de
qualidade antes de deploy. Fluxos Maestro (`.yaml` com `appId` + comandos `tapOn`, `assertVisible`,
etc.) rodam contra o build num job de teste. Combine com **preview builds em Pull Requests**
(um workflow disparado por PR que builda com `distribution: internal` e comenta o link) para revisão
visual antes do merge.

## Gotchas de sênior

- **`eas.json` não é `app.json`.** `eas.json` = como buildar/submeter; `app.config` = o que o app é.
  Não misture.
- **Channel ≠ profile.** O `channel` liga build ao EAS Update; o profile é o preset de build. Um
  profile pode setar um channel, mas são coisas distintas.
- **Segredos**: use EAS Environment Variables/Secrets, nunca hardcode no `eas.json` (ele é commitado).
- **Versão do CLI**: fixe `cli.version` no `eas.json` para builds reproduzíveis entre a equipe.
- **iOS sem Mac**: EAS Build resolve isso — buildar/enviar iOS não exige macOS local.
