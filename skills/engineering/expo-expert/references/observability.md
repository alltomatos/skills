# Observabilidade — crash reporting, telemetria e EAS Insights

Doc-âncora: busque via `llms.txt` — `guides/using-sentry`, `guides/using-bugsnag`,
`guides/using-logrocket`, e as páginas de EAS Insights. As integrações evoluem; confirme a versão do
plugin compatível com seu SDK.

## Princípios

Um app de produção precisa de três sinais: **crashes/erros** (o que quebrou), **performance/traces**
(por que está lento) e **métricas de entrega** (quem recebeu qual build/update). Em Expo isso se
divide entre uma ferramenta de APM/crash (Sentry é o padrão de mercado) e o **EAS Insights** para
métricas do ciclo de build/update.

Ponto crítico de mobile: **simbolização**. O JS de produção roda minificado como bytecode Hermes;
sem subir os **source maps** (JS + Hermes) e os símbolos de debug nativos (dSYM iOS / ProGuard
mapping Android), as stack traces chegam ilegíveis. Toda integração séria automatiza esse upload no
build.

## Sentry (padrão recomendado)

```bash
npx expo install @sentry/react-native
```

Setup idiomático em Expo:
- Adicione o **config plugin** do Sentry ao `app.config` (`plugins: ["@sentry/react-native/expo"]`)
  — ele injeta o necessário no nativo durante o prebuild e configura o **upload automático de source
  maps** no EAS Build.
- Inicialize cedo no app (`Sentry.init({ dsn, tracesSampleRate, ... })`) e envolva o root
  (`Sentry.wrap(App)`), ou o layout raiz no Expo Router.
- Auth token do Sentry vai como **EAS Secret**, nunca commitado.

O que o Sentry entrega: crash/error reporting com breadcrumbs, **performance tracing**, e (com a
config de source maps) stack traces simbolizadas de Hermes. Integra com EAS Update para atrelar um
erro ao **update/runtime version** que o causou.

## BugSnag / LogRocket

Alternativas suportadas quando o time já usa:
- **BugSnag** — crash reporting + estabilidade; tem plugin/config para Expo (`guides/using-bugsnag`).
- **LogRocket** — session replay + logs, forte para reproduzir o que o usuário fez antes do erro
  (`guides/using-logrocket`).

Em todos: o passo que mais gente esquece é o **upload de source maps/símbolos no pipeline de build**.
Verifique isso primeiro quando "as stack traces vêm sem nomes de função".

## EAS Insights

**EAS Insights** dá métricas do lado do EAS: adoção de updates (quantos dispositivos baixaram qual
update), sucesso/falha de builds, e telemetria de entrega. Habilite instalando `expo-insights`
(config plugin) e consulte no dashboard do EAS.

Use Insights para responder perguntas de entrega — "meu OTA chegou nos usuários?", "qual runtime
version está em campo?" — que o Sentry (focado em erro/perf) não cobre. Complementam-se: Insights =
entrega, Sentry = saúde em runtime.

## Playbook

1. **Instale crash reporting antes do primeiro release**, não depois do primeiro incidente.
2. **Garanta source maps no build** (config plugin + EAS) — sem isso, todo o resto é cego.
3. **Atrele erros ao release**: propague `runtimeVersion`/versão como release/dist no Sentry para
   saber exatamente qual OTA quebrou. Cruze com [eas-update.md](eas-update.md).
4. **Segredos como EAS Secrets** (DSN às vezes pode ser público; auth tokens NUNCA).
5. **Valide a captura**: dispare um erro de teste em staging e confirme que chega simbolizado antes
   de confiar em produção.
