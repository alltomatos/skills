# Upgrade de SDK

Doc-âncora: `workflow/upgrading-expo-sdk-walkthrough.md`.

## Princípio central

**Suba um SDK de cada vez, nunca pule versões.** Cada salto isola melhor qual mudança causou qual
quebra — pular de SDK 51 direto pro 55 mistura quatro conjuntos de breaking changes num só diff
gigante e difícil de depurar.

## Fluxo manual (passo a passo oficial)

```bash
# 1. Sobe o pacote expo para a versão alvo
npm install expo@^57.0.0        # troque pelo número do SDK alvo

# 2. Alinha o resto das dependências à nova versão do SDK
npx expo install --fix

# 3. Diagnóstico
npx expo-doctor
```

**Projetos em CNG** (a esmagadora maioria — ver [cng-config-plugins.md](cng-config-plugins.md)):
```bash
rm -rf android ios     # ou apague manualmente
npx expo prebuild --clean
```
As pastas são artefato; deletar e regenerar é mais seguro que tentar migrar o conteúdo nativo à mão.

**Projetos sem CNG** (nativo versionado manualmente — raro/legado): rode `npx pod-install` e aplique
as mudanças indicadas pelo *Native project upgrade helper* da doc, ou aproveite o upgrade para migrar
para CNG.

**4. Leia o changelog da versão alvo.** Todo SDK tem notas de release com as breaking changes — não
pule esta etapa mesmo com `expo-doctor` verde; o doctor pega desalinhamento de dependência, não
mudança de comportamento em runtime.

## Upgrade assistido por agente

A própria Expo mantém uma skill oficial de IA para isso — **`expo-upgrade`**, parte do pacote
`github.com/expo/skills` — que guia o upgrade com recomendações de fix de dependência. Se disponível
no ambiente, é um bom complemento a este fluxo manual (ela tem acesso a MCP com dados ao vivo de
compatibilidade); esta referência cobre o modelo mental e os comandos para quando ela não estiver
instalada ou você preferir controle manual.

## Checklist de sênior antes de subir SDK em produção

1. **Branch dedicada**, nunca direto na branch de release.
2. `npx expo install --fix` + `npx expo-doctor` **limpos** antes de prosseguir.
3. `npx expo prebuild --clean` e um **build local** (`expo run:android`/`run:ios`) antes de gastar
   fila de EAS Build.
4. Rode o app inteiro manualmente (ou os testes E2E, se houver — ver Maestro em
   [eas-build-submit-workflows.md](eas-build-submit-workflows.md)), não só a tela principal.
5. **Verifique compatibilidade com Nova Arquitetura** de toda lib nativa de terceiro — no SDK 55+
   não há mais opt-out (ver [performance.md](performance.md)). É a causa mais comum de "upgrade
   quebrou uma lib" nas versões recentes.
6. **Cheque o `runtimeVersion`** — subir de SDK quase sempre muda a interface nativa; se você usa a
   policy `fingerprint` isso é automático, senão bump manual é obrigatório (ver
   [eas-update.md](eas-update.md)) para não distribuir OTA incompatível.
7. Suba um **build de preview/internal** primeiro, valide com o time, só então production.

## Gotchas de sênior

- **`expo-doctor` limpo não é garantia de app funcional** — ele checa alinhamento de dependências,
  não comportamento. Teste manual continua obrigatório.
- **Não pule o changelog** achando que "deu certo, então tá tudo bem" — algumas breaking changes só
  aparecem em caminhos de código não testados no smoke test inicial.
- **Deletar `android`/`ios` é seguro** em projetos CNG — resistir a isso (achando que vai perder
  customização) geralmente significa que a customização não estava num config plugin, o que já era
  um problema antes do upgrade.
