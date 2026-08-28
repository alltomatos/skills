# Brownfield e migrações para Expo

Doc-âncora: busque via `llms.txt` — `guides/adopting-prebuild`, `bare/*` (integração brownfield),
e `guides/monorepo`. Estes guias mudam; confirme os passos exatos na doc antes de executar.

## Dois cenários distintos

1. **Migração de React Native CLI → Expo** (o projeto já é RN, quer adotar o ecossistema Expo).
2. **Brownfield** (integrar React Native/Expo dentro de um app **nativo existente** iOS/Android).

São problemas diferentes; não os confunda.

## Migração de RN CLI para Expo

O ponto que surpreende quem vem do RN antigo: **você não precisa "recomeçar" nem escolher managed vs
bare** — esses conceitos não existem mais (ver [cng-config-plugins.md](cng-config-plugins.md)).
Adotar Expo num projeto RN é incremental.

Passos típicos (confirme na doc `guides/adopting-prebuild` e no guia de instalação do Expo em projeto
existente):

1. **Instale o pacote `expo`** e rode o instalador/`expo install expo`, que integra os módulos base.
2. **Alinhe dependências** com `npx expo install --fix` e diagnostique com `npx expo-doctor`.
3. **Adote Prebuild (CNG)**: mova as customizações nativas das pastas `android/`/`ios/` para
   `app.json` + **config plugins**, depois passe a gerar o nativo com `npx expo prebuild`. O objetivo
   final é poder deletar as pastas nativas do git e tratá-las como artefato.
4. **Migre libs** para equivalentes `expo-*` quando existirem (melhor suporte a CNG/EAS).
5. **Adote EAS Build/Update** para builds na nuvem e OTA (ver
   [eas-build-submit-workflows.md](eas-build-submit-workflows.md), [eas-update.md](eas-update.md)).
6. **Opcional**: adotar Expo Router se quiser file-based routing.

Estratégia de sênior: **migre por etapas e mantenha o app buildável a cada passo**. Comece
instalando `expo` e rodando os apps como estão; só então adote prebuild; só então migre libs. Não
tente o big-bang.

### Customizações nativas existentes → config plugins

O trabalho central da migração é traduzir cada edição manual no nativo (uma permissão no manifest,
uma key no `Info.plist`, um trecho no Gradle, um arquivo copiado) para um **config plugin** ou um
mod. Onde um plugin for inviável no curto prazo, `patch-project` versiona o patch. A meta é chegar a
um estado onde `npx expo prebuild --clean` reproduz 100% do nativo a partir da config.

## Brownfield — Expo dentro de app nativo existente

Aqui o app **host** é nativo (Swift/Kotlin) e você embute telas React Native/Expo. Pontos-chave
(ver os guias `bare`/brownfield na doc):

- É mais avançado e menos "caminho feliz" que um app Expo puro — algumas features do ecossistema
  (ex.: partes do fluxo CNG/EAS) assumem que o Expo controla o projeto nativo. Verifique o suporte
  atual na doc para o seu SDK antes de prometer.
- O host nativo inicializa o runtime RN e monta as views RN em pontos específicos; você gerencia o
  ciclo de vida a partir do lado nativo.
- Autolinking e Expo Modules podem exigir setup manual adicional no projeto host.
- Ferramentas como EAS Build podem precisar de configuração custom quando o build não é 100%
  gerenciado pelo Expo.

## Diagnóstico e ferramentas

- **`npx expo-doctor`** — primeiro comando em qualquer migração: aponta versões incompatíveis e
  config quebrada.
- **`npx expo install --check` / `--fix`** — alinha versões de libs ao SDK.
- **Upgrade de SDK**: `npx expo install expo@latest` + `npx expo install --fix`, depois
  `npx expo prebuild --clean`. Leia sempre o **changelog/guia de upgrade do SDK** na doc antes.
- Cheque a **compatibilidade com a Nova Arquitetura** das libs ao migrar/subir de SDK — no SDK 55+
  não há opt-out (ver [performance.md](performance.md)).

## Gotchas de sênior

- **Não versione `android/`/`ios/` "por segurança" durante a migração** e depois esqueça — isso
  reintroduz o problema que o CNG resolve. Decida: ou CNG puro (gitignore + plugins), ou pastas
  versionadas conscientemente (fluxo "prebuild adotado parcialmente").
- **Migre libs uma a uma**, testando build a cada troca — libs nativas são a maior fonte de quebra.
- **Guie-se pela doc de upgrade**, não pela memória: cada SDK tem breaking changes documentadas.
