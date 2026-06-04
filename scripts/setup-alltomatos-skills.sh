#!/usr/bin/env bash
# Setup script for alltomatos/skills fork
# Based on the original architecture by Matt Pocock (mattpocock/skills)

set -euo pipefail

echo "🔧 Configurando skills do fork alltomatos/skills"
echo "📝 Baseado no trabalho original de Matt Pocock (mattpocock/skills)"
echo ""

REPO="$(cd "$(dirname "$0")/.." && pwd)"

if [[ ! -f "$REPO/CLAUDE.md" || ! -d "$REPO/.claude-plugin" ]]; then
    echo "❌ Erro: execute este script do diretório raiz do repositório alltomatos/skills" >&2
    exit 1
fi

echo "✅ Repositório verificado: $REPO"
echo ""

DEST="$HOME/.claude/skills"

# Guard against infinite loop
if [ -L "$DEST" ]; then
    resolved="$(readlink -f "$DEST")"
    case "$resolved" in
        "$REPO"|"$REPO"/*)
            echo "❌ Erro: $DEST é um symlink para dentro deste repo ($resolved)." >&2
            echo "   Remova-o (rm \"$DEST\") e re-execute." >&2
            exit 1
            ;;
    esac
fi

mkdir -p "$DEST"

echo "🔗 Linkando skills para $DEST"
echo ""

COUNT=0

# Same exclusion policy as plugin.json: skip deprecated, personal, in-progress
find "$REPO/skills" -name SKILL.md \
    -not -path '*/node_modules/*' \
    -not -path '*/deprecated/*' \
    -not -path '*/personal/*' \
    -not -path '*/in-progress/*' \
    -print0 | \
while IFS= read -r -d '' skill_md; do
    src="$(dirname "$skill_md")"
    name="$(basename "$src")"
    target="$DEST/$name"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
        rm -rf "$target"
    fi

    ln -sfn "$src" "$target"
    echo "  ✅ $name"
    ((COUNT++))
done

echo ""
echo "🎯 Skills linkadas. Próximo passo:"
echo "   Execute '/setup-matt-pocock-skills' no seu Claude Code agent"
echo "   para configurar issue tracker, labels e docs de domínio."
echo ""
echo "🔗 Créditos: mattpocock/skills — a arquitetura original"
echo "🇧🇷 Fork: alltomatos/skills — customizações e suporte pt-BR"
