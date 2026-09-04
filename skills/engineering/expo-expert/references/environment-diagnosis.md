# Diagnóstico de máquina antes de recomendar build

Doc-âncora: `build/introduction.md`, `develop/development-builds/introduction.md`. Este arquivo não
espelha uma página específica da doc — é o método para decidir **qual dos três caminhos de build**
faz sentido *nesta* máquina, algo que a doc trata como dado (você escolhe) mas que na prática é
limitado pelo SO, pelas ferramentas instaladas e pelos recursos disponíveis.

## Quando rodar este diagnóstico

**Sempre que a tarefa envolver decidir *como* buildar, rodar ou testar o app** — não para perguntas
puramente conceituais (explicar o que é um config plugin não precisa disso). Gatilhos típicos: o
usuário pede pra rodar `expo run:ios`/`run:android`, perguntar "como eu testo isso", pedir ajuda
pra configurar o ambiente, ou você está prestes a recomendar um comando de build. Rode o
diagnóstico **antes** de sugerir o comando, não depois — recomendar `expo run:ios` pra alguém no
Windows e só descobrir o problema na execução é o erro que este passo existe para evitar.

## Por que a máquina importa

Os três caminhos de build (ver [cng-config-plugins.md](cng-config-plugins.md) e
[eas-build-submit-workflows.md](eas-build-submit-workflows.md)) têm requisitos de hardware/SO bem
diferentes:

| Caminho | Requisito |
|---|---|
| **Local — iOS** (`expo run:ios`) | **Exclusivamente macOS** com Xcode. Não existe forma de compilar um `.ipa` localmente no Windows ou Linux — isso é limitação da Apple, não do Expo. |
| **Local — Android** (`expo run:android`) | Qualquer SO (Windows/macOS/Linux), mas precisa de JDK + Android SDK/Studio instalados, e de RAM/disco livres — o Gradle é pesado. |
| **EAS Build (cloud)** | Nenhum requisito de toolchain local — roda no servidor da Expo. Só precisa de conta EAS e internet. É o único caminho que sempre funciona, independente da máquina. |
| **EAS local build** (`eas build --local`) | Mesmos requisitos de toolchain do build local da plataforma alvo (Xcode pra iOS, Android SDK pra Android) — só muda a orquestração, não o requisito de SO. |

## Checklist de diagnóstico

Rode isto (adapte ao shell disponível — PowerShell no Windows, bash no macOS/Linux) e reporte o que
encontrar antes de recomendar um caminho:

```bash
# Sistema operacional — decide de cara se build local de iOS é sequer possível
uname -a          # macOS/Linux
# no Windows (PowerShell): $PSVersionTable.OS  ou  systeminfo | findstr /B /C:"OS Name"

# Toolchain base
node -v
npx expo --version
eas --version         # se ausente: npm install -g eas-cli
eas whoami             # logado no EAS? build cloud precisa disso

# Toolchain Android (qualquer SO)
java -version
echo $ANDROID_HOME    # ou: $env:ANDROID_HOME no PowerShell
adb --version

# Toolchain iOS (só relevante se o SO já é macOS)
xcodebuild -version
pod --version

# Recursos livres — Gradle/Xcode consomem bastante
df -h .                # Linux/macOS
# Windows (PowerShell): Get-PSDrive C
```

Não presuma o SO do usuário pela sua própria execução — se você está rodando em uma máquina
diferente da do usuário (ou eles vão executar o comando na máquina deles), pergunte ou confirme
antes de recomendar um caminho que só funciona num SO específico.

## Matriz de decisão

| Situação | Recomendação |
|---|---|
| **Windows ou Linux, precisa de build iOS** | **EAS Build (cloud) é a única opção.** Não existe alternativa local — não tente contornar. |
| **Windows/Linux, build Android, sem Android Studio/JDK instalados** | Recomende **EAS Build (cloud)** primeiro — evita o usuário instalar ~10GB de toolchain só pra um build. Ofereça o caminho local como opção *se* ele já for fazer trabalho nativo recorrente (ver [native-modules.md](native-modules.md)). |
| **Windows/Linux, build Android, com Android Studio/JDK já instalados** | `npx expo run:android` local é viável — mais rápido pra iteração (sem fila de build na nuvem). |
| **macOS, com Xcode e Android Studio instalados** | Build local viável nas duas plataformas — bom para quem itera bastante. |
| **macOS, só com Xcode (sem Android Studio)** | iOS local, Android via EAS Build cloud (ou instale o Android SDK se o trabalho for recorrente). |
| **Máquina com pouca RAM livre (menos de ~8GB) ou pouco disco (menos de ~20GB livre)** | Prefira **EAS Build cloud** mesmo com toolchain instalado — Gradle/Xcode local costuma travar ou degradar o resto da máquina em ambientes apertados. |
| **CI, sandbox, container, ou qualquer ambiente sem GUI persistente** | **EAS Build cloud** sempre — build local nativo pressupõe ambiente interativo/persistente. |
| **Só precisa iterar em JS/lógica, sem lib nativa nova** | Nem build local nem cloud — `npx expo start` com Expo Go (se não há código nativo custom) ou o dev build já instalado resolve, sem gastar fila nem toolchain. |

## Conectividade do dispositivo físico (Expo Go / dev build via LAN)

Rodar `npx expo start` e escanear o QR no celular assume que o celular consegue alcançar o Metro na
porta 8081 (ou a que estiver ativa) do computador. Quando o app carrega o bundle uma vez mas depois
falha em reconectar, ou nunca conecta, siga esta ordem de diagnóstico (validada em produção — cada
uma destas foi uma hipótese descartada até achar a real):

1. **O terminal que iniciou `expo start` é não-interativo** (ex.: harness de agente, CI)? Nesse
   caso o Metro não imprime o QR/URL `exp://` completo — só "Waiting on http://localhost:8081". Pra
   descobrir a URL real, pegue o IP da máquina (`ipconfig`/`ifconfig`) e monte `exp://<ip>:8081` na
   mão, ou peça pro usuário rodar o comando ele mesmo num terminal interativo.
2. **Firewall do SO bloqueando a porta?** Confira antes de assumir — no Windows,
   `Get-NetConnectionProfile` mostra se a rede Wi-Fi está classificada como "Public" (regras de
   firewall por app costumam já cobrir isso, mas confira `Get-NetFirewallRule` pelo executável
   exato do Node em uso — gerenciadores de versão como nvm-windows trocam o caminho do `node.exe`,
   e uma regra antiga apontando pro caminho errado não vale). **Mas não presuma que é o firewall** —
   confirme testando (`Get-NetTCPConnection -LocalPort 8081` mostra se algo está de fato escutando;
   se o firewall estiver *desligado* e ainda assim não conectar, o problema é outro).
3. **Isolamento de cliente no roteador/AP.** Se o firewall está confirmadamente desligado, a porta
   está escutando em todas as interfaces, e mesmo assim zero pacote chega no Metro (confirme
   olhando o log do Metro — nenhuma linha de bundle request aparece), suspeite de **AP/client
   isolation** no roteador — comum em CPEs de operadora e redes com "5G"/hotspot no nome. Isso
   bloqueia comunicação direta entre dispositivos na mesma rede Wi-Fi mesmo com firewall de host
   desligado, e não tem workaround do lado do app.
4. **Tunnel (`expo start --tunnel`, via `@expo/ngrok`) costuma estar quebrado hoje** — o ngrok
   mudou a API pra exigir authtoken/conta em versões recentes, e a integração do Expo não foi
   atualizada. Erro típico: `TypeError: Cannot read properties of undefined (reading 'body')`. Não
   perca tempo tentando consertar isso — pule direto pra alternativa 5.
5. **Tailscale (ou outra VPN mesh) é o fallback mais confiável** quando a rede local tem isolamento
   de AP e o tunnel do Expo está quebrado: conecte computador e celular no mesmo tailnet, rode
   `expo start` normalmente (ele escuta em todas as interfaces, incluindo a do Tailscale), e no
   Expo Go use "Enter URL manually" com `exp://<ip-tailscale>:8081` em vez de escanear o QR (que
   mostraria o IP da LAN, não o do Tailscale).

## Como comunicar a recomendação

Não jogue a matriz inteira pro usuário — diga o diagnóstico e a conclusão prática em 2-3 frases:
*"Você está no Windows sem Android Studio instalado. Pra esse caso o caminho mais rápido é EAS
Build na nuvem (`eas build --profile development --platform android`), sem precisar instalar o
SDK Android. Se você for mexer bastante em código nativo, aí vale instalar o Android Studio pra
buildar local e iterar mais rápido — me avisa se quiser esse caminho."* Dê a opção, não imponha —
o usuário pode ter motivo pra preferir o caminho mais pesado (ex.: já tem tudo instalado por outro
projeto).
