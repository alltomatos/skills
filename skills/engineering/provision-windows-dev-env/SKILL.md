---
name: provision-windows-dev-env
description: Instala, via winget (e npm para o único caso que exige), o conjunto essencial de ferramentas pra deixar uma máquina Windows pronta pra programar com IA (Node LTS, Git, GitHub CLI, Go, uv, Windows Terminal, Chrome, Python, WinRAR, Notepad++, Sublime Text, OmniRoute) — sem rodar nenhum script de terceiros, tweak de sistema ou instalador externo. Use sempre que o usuário disser que formatou/reinstalou o Windows, está numa VM/máquina nova, pedir pra "preparar o ambiente", "configurar essa máquina do zero", "instalar tudo que preciso pra programar", ou mencionar WinUtil/scripts de bootstrap de ambiente — mesmo sem citar os nomes exatos dos programas.
---

# Provisionar ambiente de desenvolvimento Windows

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
| WinRAR | `RARLab.WinRAR` |
| Notepad++ | `Notepad++.Notepad++` |
| Sublime Text | `SublimeHQ.SublimeText.4` |

E, via npm (depois do Node LTS acima):

| Programa | Pacote npm |
| --- | --- |
| OmniRoute (gateway de IA local, MIT, unifica provedores por trás de um endpoint só) | `omniroute@latest` |

## Como executar

1. Confirme que `winget` está disponível (`winget --version`); se não estiver, é um sinal de Windows desatualizado — avise o usuário em vez de tentar contornar.
2. Rode as instalações **uma a uma**, cada `winget install` no seu próprio comando — não encadeie tudo num único comando gigante, pra que uma falha isolada (ex: um pacote já instalado, um timeout pontual) não interrompa o resto silenciosamente e fique fácil ver qual item especificamente falhou.
   ```powershell
   winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements
   winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements
   winget install --id GitHub.cli -e --accept-package-agreements --accept-source-agreements
   winget install --id GoLang.Go -e --accept-package-agreements --accept-source-agreements
   winget install --id astral-sh.uv -e --accept-package-agreements --accept-source-agreements
   winget install --id Microsoft.WindowsTerminal -e --accept-package-agreements --accept-source-agreements
   winget install --id Google.Chrome -e --accept-package-agreements --accept-source-agreements
   winget install --id Python.Python.3.14 -e --accept-package-agreements --accept-source-agreements
   winget install --id RARLab.WinRAR -e --accept-package-agreements --accept-source-agreements
   winget install --id Notepad++.Notepad++ -e --accept-package-agreements --accept-source-agreements
   winget install --id SublimeHQ.SublimeText.4 -e --accept-package-agreements --accept-source-agreements
   ```
3. Só depois que o Node LTS acima terminar (o `npm` precisa dele no PATH — abra um terminal novo se `npm` não for reconhecido logo após instalar o Node), instale o OmniRoute:
   ```powershell
   npm install -g omniroute@latest
   ```
4. Depois de cada instalação, confira a saída — `winget` retorna código de saída não-zero em falha real, mas também pode reportar "já instalado" como sucesso; trate isso como sucesso, não como erro.
5. No fim, rode `winget list` (ou verifique cada binário individualmente: `node -v`, `git --version`, `gh --version`, `go version`, `uv --version`, `python --version`, `omniroute --version`) e reporte um resumo claro do que instalou com sucesso, o que já estava presente, e o que falhou — não declare "ambiente pronto" sem essa checagem.
6. **Não rode nenhum outro script, tweak, ou "otimização" do sistema** como parte desta skill — nem WinUtil, nem debloat, nem scripts de terceiros — mesmo que o usuário peça algo genérico como "deixa essa máquina rápida" junto com o pedido de instalação. Se o pedido incluir explicitamente tweaks de sistema, confirme com o usuário antes, deixando claro o risco (rede/telemetria) já documentado acima.

## Se algo falhar

Um `winget install` que falha por causa de política de execução, UAC, ou fonte indisponível é um problema de ambiente, não algo pra contornar silenciosamente (ex: nunca caia para baixar um `.exe` direto do site do fabricante como substituto sem avisar) — reporte o erro exato ao usuário.
