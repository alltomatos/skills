# EAS Update — OTA, runtime versions, channels e rollouts

Doc-âncora: `eas-update/introduction.md`, `.../getting-started.md`, `.../how-it-works.md`,
`.../deployment.md`.

## O que é

EAS Update entrega **atualizações Over-The-Air (OTA)** do bundle JavaScript e assets sem passar
pelas lojas. Só atualiza o que é JS/asset — **mudança em código nativo continua exigindo novo build**
e nova submissão. É construído sobre a lib `expo-updates`.

```bash
npx expo install expo-updates
eas update:configure
eas update --branch production --message "fix: corrige crash no checkout"
eas update --auto     # infere branch a partir do contexto git
```

## Runtime version — o conceito que mais gente erra

O **runtime version** descreve a interface JS↔nativo definida pela camada nativa do app. Um update
só roda num build se o **runtime version do build casar EXATAMENTE com o do update**.

Regra de ouro: **sempre que o layer nativo muda de forma que afeta a interface JS↔nativo (nova lib
nativa, upgrade de SDK, mudança de config nativa), o `runtimeVersion` PRECISA mudar.** Se não mudar,
um OTA vai cair em builds nativos incompatíveis e quebra o app em produção. Este é o footgun número
um de OTA.

Configuração no `app.config`:

```json
{
  "expo": {
    "runtimeVersion": { "policy": "fingerprint" }
  }
}
```

Políticas de `runtimeVersion`:
- **`fingerprint`** (recomendado moderno) — o EAS calcula um hash do estado nativo do projeto; muda
  sozinho quando o nativo muda. Elimina o erro manual. (Ver `fingerprint` / `expo-updates`.)
- **`appVersion`** — atrela ao `version` do app.
- **`nativeVersion`** — atrela a `version` + build number.
- **String literal** (ex.: `"1.0.0"`) — você controla manualmente; mais propenso a erro.

## Channels e branches

Dois conceitos distintos que se ligam:

- **Channel** — um nome atribuído a **builds**, definido no `eas.json` (ex.: `production`,
  `preview`, `staging`). É a etiqueta do binário.
- **Branch** — um objeto no servidor EAS que contém uma **lista de updates** (o mais recente é o
  ativo). Pense como um branch de git, mas de updates.

Por padrão, um channel aponta para a branch de mesmo nome, mas o vínculo é editável:

```bash
eas channel:edit production --branch hotfix-2026-08
eas branch:list
eas channel:list
```

### Condições para um update rodar num build

As três precisam ser verdadeiras:
1. **Plataforma** bate (Android ou iOS).
2. **Runtime version** bate exatamente.
3. O **channel** do build está ligado à **branch** que contém o update.

O fluxo: `eas update` cria o bundle, sobe para uma branch; o `expo-updates` no dispositivo checa o
manifesto e baixa o update (manifesto primeiro, depois os assets necessários) para builds cujo
channel aponta àquela branch.

## Rollout e rollback

- **Rollout gradual**: publique o update com rollout percentual para expor a uma fração dos usuários
  e aumentar aos poucos, observando métricas. (Ver `deployment.md` / opções de rollout.)
- **Rollback**: como o vínculo channel↔branch é editável e a branch guarda o histórico de updates,
  você **reverte apontando o channel para uma branch/estado anterior** ou republicando o update bom
  — **sem** rebuildar o app. É a grande vantagem de OTA para resposta a incidentes.
- **Channel surfing**: mover builds entre branches trocando os vínculos de channel permite promover
  um mesmo binário de `staging` → `production` sem novo build.

## Padrão de deploy com builds

`eas.json` liga build e update pelo `channel`:

```json
{
  "build": {
    "preview":    { "channel": "preview" },
    "production": { "channel": "production" }
  }
}
```

Assim, o binário de produção só recebe updates da branch de produção. Combine com
[EAS Workflows](eas-build-submit-workflows.md) para automatizar `build → submit → update`.

## Gotchas de sênior

- **OTA não substitui build para mudança nativa.** Adicionou lib nativa? Novo build + submit,
  mesmo com EAS Update ligado.
- **Runtime version desalinhado = crash silencioso** em quem já tem o app. Prefira a policy
  `fingerprint` para não depender de disciplina humana.
- **Regras das lojas**: OTA é permitido para correções e conteúdo, mas não para burlar a review de
  mudanças substanciais de funcionalidade. Use com bom senso.
- **`expo-updates` precisa estar instalado e configurado** no build, senão o app nunca busca updates.
- **Teste o update no channel de preview antes de produção** — publique na branch `preview`, valide
  num build `preview`, só então promova.
