# Machine diagnosis before recommending a build

Anchor docs: `build/introduction.md`, `develop/development-builds/introduction.md`. This file does
not mirror a specific doc page - it is the method for deciding **which of the three build paths**
makes sense *on this machine*, something the docs treat as a given (you choose) but that in practice
is limited by the OS, the installed tools and the available resources.

## When to run this diagnosis

**Whenever the task involves deciding *how* to build, run or test the app** - not for purely
conceptual questions (explaining what a config plugin is does not need it). Typical triggers: the
user asks to run `expo run:ios`/`run:android`, asks "how do I test this", asks for help setting up
the environment, or you are about to recommend a build command. Run the diagnosis **before**
suggesting the command, not after - recommending `expo run:ios` to someone on Windows and only
discovering the problem at execution time is the mistake this step exists to prevent.

## Why the machine matters

The three build paths (see [cng-config-plugins.md](cng-config-plugins.md) and
[eas-build-submit-workflows.md](eas-build-submit-workflows.md)) have very different hardware/OS
requirements:

| Path | Requirement |
|---|---|
| **Local - iOS** (`expo run:ios`) | **macOS only**, with Xcode. There is no way to compile an `.ipa` locally on Windows or Linux - that is an Apple limitation, not an Expo one. |
| **Local - Android** (`expo run:android`) | Any OS (Windows/macOS/Linux), but it needs JDK + Android SDK/Studio installed, plus free RAM/disk - Gradle is heavy. |
| **EAS Build (cloud)** | No local toolchain requirement - it runs on Expo's servers. Only needs an EAS account and internet. It is the only path that always works, regardless of the machine. |
| **EAS local build** (`eas build --local`) | Same toolchain requirements as the local build of the target platform (Xcode for iOS, Android SDK for Android) - only the orchestration changes, not the OS requirement. |

## Diagnosis checklist

Run this (adapt to the available shell - PowerShell on Windows, bash on macOS/Linux) and report what
you find before recommending a path:

```bash
# Operating system - decides up front whether a local iOS build is even possible
uname -a          # macOS/Linux
# on Windows (PowerShell): $PSVersionTable.OS  or  systeminfo | findstr /B /C:"OS Name"

# Base toolchain
node -v
npx expo --version
eas --version         # if missing: npm install -g eas-cli
eas whoami             # logged into EAS? cloud builds need this

# Android toolchain (any OS)
java -version
echo $ANDROID_HOME    # or: $env:ANDROID_HOME on PowerShell
adb --version

# iOS toolchain (only relevant if the OS is already macOS)
xcodebuild -version
pod --version

# Free resources - Gradle/Xcode are heavy consumers
df -h .                # Linux/macOS
# Windows (PowerShell): Get-PSDrive C
```

Do not assume the user's OS from where you happen to be running - if you are running on a different
machine from the user's (or they will run the command on theirs), ask or confirm before recommending
a path that only works on a specific OS.

## Decision matrix

| Situation | Recommendation |
|---|---|
| **Windows or Linux, needs an iOS build** | **EAS Build (cloud) is the only option.** There is no local alternative - do not try to work around it. |
| **Windows/Linux, Android build, with no Android Studio/JDK installed** | Recommend **EAS Build (cloud)** first - it saves the user from installing ~10GB of toolchain just for one build. Offer the local path as an option *if* they will be doing recurring native work (see [native-modules.md](native-modules.md)). |
| **Windows/Linux, Android build, with Android Studio/JDK already installed** | Local `npx expo run:android` is viable - faster to iterate (no cloud build queue). |
| **macOS, with Xcode and Android Studio installed** | Local builds are viable on both platforms - good for people who iterate a lot. |
| **macOS, with only Xcode (no Android Studio)** | Local iOS, Android through EAS Build cloud (or install the Android SDK if the work is recurring). |
| **Machine with little free RAM (under ~8GB) or little disk (under ~20GB free)** | Prefer **EAS Build cloud** even with the toolchain installed - local Gradle/Xcode tends to stall or degrade the rest of the machine in tight environments. |
| **CI, sandbox, container, or any environment without a persistent GUI** | **EAS Build cloud** always - a local native build assumes an interactive/persistent environment. |
| **Only needs to iterate on JS/logic, no new native library** | Neither local nor cloud - `npx expo start` with Expo Go (when there is no custom native code) or the already-installed dev build is enough, without spending build queue or toolchain. |

## Physical device connectivity (Expo Go / dev build over LAN)

Running `npx expo start` and scanning the QR on the phone assumes the phone can reach Metro on port
8081 (or whichever is active) on the computer. When the app loads the bundle once but then fails to
reconnect, or never connects, follow this diagnosis order (validated in production - each one of
these was a hypothesis ruled out until the real one was found):

1. **Is the terminal that started `expo start` non-interactive** (e.g. an agent harness, CI)? In
   that case Metro does not print the full QR/`exp://` URL - only "Waiting on http://localhost:8081".
   To find the real URL, get the machine's IP (`ipconfig`/`ifconfig`) and build `exp://<ip>:8081` by
   hand, or ask the user to run the command themselves in an interactive terminal.
2. **Is the OS firewall blocking the port?** Check before assuming - on Windows,
   `Get-NetConnectionProfile` shows whether the Wi-Fi network is classified as "Public" (per-app
   firewall rules usually cover this already, but check `Get-NetFirewallRule` for the exact Node
   executable in use - version managers such as nvm-windows change the `node.exe` path, and an old
   rule pointing to the wrong path does not apply). **But do not assume it is the firewall** -
   confirm by testing (`Get-NetTCPConnection -LocalPort 8081` shows whether something is actually
   listening; if the firewall is *off* and it still does not connect, the problem is elsewhere).
3. **Client isolation on the router/AP.** If the firewall is confirmed off, the port is listening on
   all interfaces, and still zero packets reach Metro (confirm by looking at the Metro log - no
   bundle request line appears), suspect **AP/client isolation** on the router - common on carrier
   CPEs and networks with "5G"/hotspot in the name. It blocks direct communication between devices
   on the same Wi-Fi even with the host firewall off, and there is no app-side workaround.
4. **Tunnel (`expo start --tunnel`, via `@expo/ngrok`) is usually broken today** - ngrok changed its
   API to require an authtoken/account in recent versions, and Expo's integration was not updated.
   Typical error: `TypeError: Cannot read properties of undefined (reading 'body')`. Do not waste
   time trying to fix it - go straight to alternative 5.
5. **Tailscale (or another mesh VPN) is the most reliable fallback** when the local network has AP
   isolation and Expo's tunnel is broken: connect the computer and the phone to the same tailnet,
   run `expo start` normally (it listens on all interfaces, including Tailscale's), and in Expo Go
   use "Enter URL manually" with `exp://<tailscale-ip>:8081` instead of scanning the QR (which would
   show the LAN IP, not the Tailscale one).

## How to communicate the recommendation

Do not dump the whole matrix on the user - state the diagnosis and the practical conclusion in 2-3
sentences: *"You are on Windows without Android Studio installed. For this case the fastest path is
EAS Build in the cloud (`eas build --profile development --platform android`), with no need to
install the Android SDK. If you will be working a lot on native code, then it is worth installing
Android Studio to build locally and iterate faster - tell me if you want that path."* Offer the
option, do not impose it - the user may have a reason to prefer the heavier path (e.g. it is already
installed for another project).
