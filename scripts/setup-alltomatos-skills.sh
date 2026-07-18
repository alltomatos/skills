#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "$0")/.." && pwd)"

if [[ ! -f "$REPO/.claude-plugin/plugin.json" ]]; then
  echo "Erro: execute este script a partir de um clone valido do framework." >&2
  exit 1
fi

declare -a DESTS=()
REDEPLOY=false

if [[ "${1:-}" == "--redeploy" ]]; then
  REDEPLOY=true
  shift
  if [[ $# -gt 0 ]]; then
    DESTS=("$@")
  else
    for candidate in "${CODEX_SKILLS_DIR:-$HOME/.codex/skills}" "${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}" "${HERMES_SKILLS_DIR:-$HOME/.hermes/skills}"; do
      [[ -d "$candidate" ]] && DESTS+=("$candidate")
    done
  fi
fi

if [[ "$REDEPLOY" == true ]]; then
  [[ ${#DESTS[@]} -gt 0 ]] || { echo "Nenhum ambiente instalado foi encontrado." >&2; exit 1; }
else
echo "Instalacao das skills do framework"
echo "Selecione um ou mais ambientes separados por espaco:"
echo "  1) Codex     (~/.codex/skills)"
echo "  2) Claude    (~/.claude/skills)"
echo "  3) Hermes    (~/.hermes/skills)"
echo "  4) Outro     (informar caminho)"
read -r -p "Ambientes [1 2 3]: " choices

for choice in $choices; do
  case "$choice" in
    1) DESTS+=("${CODEX_SKILLS_DIR:-$HOME/.codex/skills}") ;;
    2) DESTS+=("${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}") ;;
    3) DESTS+=("${HERMES_SKILLS_DIR:-$HOME/.hermes/skills}") ;;
    4)
      read -r -p "Caminho da pasta de skills: " custom
      [[ -n "$custom" ]] || { echo "Caminho vazio." >&2; exit 1; }
      DESTS+=("${custom/#\~/$HOME}")
      ;;
    *) echo "Opcao invalida: $choice" >&2; exit 1 ;;
  esac
done

[[ ${#DESTS[@]} -gt 0 ]] || { echo "Nenhum ambiente selecionado." >&2; exit 1; }
fi

mapfile -t SKILL_DIRS < <(find "$REPO/skills" -mindepth 2 -maxdepth 2 -name SKILL.md \
  -not -path '*/deprecated/*' -not -path '*/personal/*' -not -path '*/in-progress/*' \
  -print | while IFS= read -r file; do dirname "$file"; done | sort)

for dest in "${DESTS[@]}"; do
  mkdir -p "$dest"
  echo "Instalando em: $dest"
  for src in "${SKILL_DIRS[@]}"; do
    name="$(basename "$src")"
    target="$dest/$name"
    if [[ -e "$target" && ! -L "$target" ]]; then
      backup="$target.backup.$(date +%Y%m%d%H%M%S)"
      mv "$target" "$backup"
      echo "  backup: $backup"
    fi
    ln -sfn "$src" "$target"
    echo "  ok: $name"
  done
done

if [[ "$REDEPLOY" == true ]]; then
  echo "Re-deploy concluido nos ambientes detectados."
else
  echo "Instalacao concluida. As skills permanecem no ambiente selecionado; o clone e apenas a fonte de distribuicao."
fi
