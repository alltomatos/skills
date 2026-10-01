---
name: devsetup
description: Instala, via winget (e npm para o único caso que exige), o conjunto essencial de ferramentas pra deixar uma máquina Windows pronta pra programar com IA (Node LTS, Git, GitHub CLI, Go, uv, Windows Terminal, Chrome, Python, 7-Zip, Notepad++, Sublime Text, OmniRoute) — sem rodar nenhum script de terceiros, tweak de sistema ou instalador externo. Ativada explicitamente via `/devsetup`, e também sempre que o usuário disser que formatou/reinstalou o Windows, está numa VM/máquina nova, pedir pra "preparar o ambiente", "configurar essa máquina do zero", "instalar tudo que preciso pra programar", ou mencionar WinUtil/scripts de bootstrap de ambiente — mesmo sem citar os nomes exatos dos programas.
---

# Provisionar ambiente de desenvolvimento Windows (/devsetup)

## Narre cada passo pro usuário

Essa skill roda vários comandos em sequência, alguns demorados (download + instalação de ~10 programas). **Antes de cada ação (verificação ou instalação), diga em uma frase curta o que você está prestes a fazer** — não só ao final, e não em silêncio até o resumo. Por exemplo: "Verificando se o Git já está instalado...", "Git não encontrado — instalando via winget...", "Node.js LTS já está presente, pulando.". O usuário não tem como saber se o processo travou ou só está demorando sem esse feedback contínuo — o silêncio no meio de um provisionamento de vários minutos é o pior resultado possível aqui, mesmo que tudo dê certo no final.

## Por que isto existe

Scripts de bootstrap de terceiros (WinUtil e afins) instalam os apps certos, mas também trazem tweaks de sistema (bloqueio de telemetria via hosts, mudanças de firewall/DNS, debloat) que já causaram pelo menos um bug real e difícil de rastrear neste fork: chamadas de saída pra provedores de IA sendo silenciosamente bloqueadas depois de rodar um desses scripts, com o app aceitando a mensagem normalmente e nunca entregando a resposta — sem nenhum erro visível na camada do app. Essa skill existe pra cobrir só a parte que realmente importa (instalar os programas) sem carregar esse risco: **apenas `winget install`, nada de tweaks, nada de scripts externos, nada de mudança de sistema além da instalação em si.**

## Quando usar

Sempre que o pedido for preparar uma máquina Windows nova (ou recém-formatada) pra desenvolvimento com agentes de IA — mesmo que o usuário não liste os programas, ou peça pra "usar o WinUtil"/similar. Prefira sempre esta skill a rodar um script de bootstrap externo.

## Lista de instalação

Todos via `winget install --id <ID> -e` (o `-e` garante match exato do ID, evitando resolver pro pacote errado por busca por nome):

| Programa | Winget ID |
| --- | --- |
| Node.js LTS | `OpenJS.NodeJS.LTS` |
| Git | `Git.Git` |
| GitHub CLI | `GitHub.cli` |
| Go | `GoLang.Go` |
| uv (gerenciador Python) | `astral-sh.uv` |
| Windows Terminal | `Microsoft.WindowsTerminal` |
| Google Chrome | `Google.Chrome` |
| Python 3 | `Python.Python.3.14` |
| 7-Zip | `7zip.7zip` |
| Notepad++ | `Notepad++.Notepad++` |
| Sublime Text | `SublimeHQ.SublimeText.4` |

E, via npm (depois do Node LTS acima):

| Programa | Pacote npm |
| --- | --- |
| OmniRoute (gateway de IA local, MIT, unifica provedores por trás de um endpoint só) | `omniroute@latest` |

## Como executar

1. Confirme que `winget` está disponível (`winget --version`); se não estiver, é um sinal de Windows desatualizado — avise o usuário em vez de tentar contornar.
2. **Antes de instalar qualquer coisa, verifique o que já existe na máquina.** Uma VM recém-formatada normalmente está vazia, mas nem sempre — não assuma. Anuncie "Verificando o que já está instalado..." e rode `winget list --id <ID>` pra cada item da tabela (ou o comando de versão do binário direto: `node -v`, `git --version`, `gh --version`, `go version`, `uv --version`, `python --version`, `omniroute --version`) — diga o resultado de cada checagem conforme for rodando (ex: "Git: não encontrado", "Node.js LTS: já instalado"), não só no final. Isso evita reinstalar por cima de uma versão que o usuário já escolheu deliberadamente (ex: uma versão específica do Node ou Python diferente da LTS), o que poderia quebrar algo que já estava funcionando.
3. Instale **só o que faltar**, um `winget install` por comando (não encadeie tudo num comando gigante, pra que uma falha isolada não interrompa o resto silenciosamente e fique fácil ver qual item especificamente falhou). Antes de cada instalação, diga qual programa está instalando agora (ex: "Instalando Git...") — o download+instalação de cada um pode levar bastante tempo, e o usuário precisa saber em qual item o processo está:
   ```powershell
   winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements
   winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements
   winget install --id GitHub.cli -e --accept-package-agreements --accept-source-agreements
   winget install --id GoLang.Go -e --accept-package-agreements --accept-source-agreements
   winget install --id astral-sh.uv -e --accept-package-agreements --accept-source-agreements
   winget install --id Microsoft.WindowsTerminal -e --accept-package-agreements --accept-source-agreements
   winget install --id Google.Chrome -e --accept-package-agreements --accept-source-agreements
   winget install --id Python.Python.3.14 -e --accept-package-agreements --accept-source-agreements
   winget install --id 7zip.7zip -e --accept-package-agreements --accept-source-agreements
   winget install --id Notepad++.Notepad++ -e --accept-package-agreements --accept-source-agreements
   winget install --id SublimeHQ.SublimeText.4 -e --accept-package-agreements --accept-source-agreements
   ```
4. **OmniRoute depende do Node estar instalado e no PATH** — é o único item com pré-requisito real desta lista. Antes de instalar, confirme que `node -v` funciona (se você acabou de instalar o Node LTS no passo anterior, abra um terminal novo antes de checar — o PATH da sessão atual pode não ter sido atualizado). Só então, se `omniroute --version` já não responder, instale.

   **`omniroute` é um pacote npm grande (~1000 dependências transitivas)** — em rede lenta ou instável, um `npm install -g` direto facilmente estoura o tempo limite de uma única chamada de ferramenta (mesmo rodando "em background" com `&`, porque a chamada de shell ainda fica bloqueada esperando o processo terminar antes de devolver o controle). O sintoma é exatamente esse: a instalação trava/reinicia repetidas vezes no mesmo ponto, sem nunca reportar sucesso nem erro real. A causa não é o pacote estar quebrado — é o padrão de execução que está errado pra esse caso.

   Em vez disso, desanexe o processo de verdade (ele sobrevive ao retorno do comando) e faça *polling* do log, ao invés de tentar esperar a instalação inteira dentro de uma chamada só:
   ```powershell
   $log = "$env:TEMP\omniroute-install.log"
   Start-Process -FilePath "npm" -ArgumentList "install -g omniroute@latest --loglevel=error --no-audit --no-fund --fetch-retries=5 --fetch-retry-mintimeout=20000" `
     -WindowStyle Hidden -RedirectStandardOutput $log -RedirectStandardError "$env:TEMP\omniroute-install.err.log"
   ```
   Depois, avise o usuário que a instalação está rodando em segundo plano e vai levar alguns minutos, e **faça checagens curtas e espaçadas** (não continue tentando rodar o install inteiro de novo):
   ```powershell
   omniroute --version 2>$null
   Get-Content "$env:TEMP\omniroute-install.log" -Tail 10 -ErrorAction SilentlyContinue
   ```
   Repita essa checagem a cada checagem espaçada até `omniroute --version` responder (sucesso) ou o log de erro indicar falha real (ex: erro de rede persistente, não apenas lentidão). Cada checagem individual é rápida — é a espera entre elas que cobre o tempo real da instalação, evitando o timeout que ocorre quando se tenta esperar tudo de uma vez numa única chamada.
5. Depois de cada instalação, confira a saída — `winget` retorna código de saída não-zero em falha real, mas também pode reportar "já instalado" como sucesso; trate isso como sucesso, não como erro.
6. No fim, rode `winget list` (ou verifique cada binário individualmente, mesmos comandos do passo 2) e reporte um resumo claro dividido em três grupos: **já estava instalado** (não mexeu), **instalado agora**, e **falhou** — não declare "ambiente pronto" sem essa checagem, e não misture os dois primeiros grupos como se fosse tudo a mesma coisa.
7. **Não rode nenhum outro script, tweak, ou "otimização" do sistema** como parte desta skill — nem WinUtil, nem debloat, nem scripts de terceiros — mesmo que o usuário peça algo genérico como "deixa essa máquina rápida" junto com o pedido de instalação. Se o pedido incluir explicitamente tweaks de sistema, confirme com o usuário antes, deixando claro o risco (rede/telemetria) já documentado acima.

## Se algo falhar

Um `winget install` que falha por causa de política de execução, UAC, ou fonte indisponível é um problema de ambiente, não algo pra contornar silenciosamente (ex: nunca caia para baixar um `.exe` direto do site do fabricante como substituto sem avisar) — reporte o erro exato ao usuário.
