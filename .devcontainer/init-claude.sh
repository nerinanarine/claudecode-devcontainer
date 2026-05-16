#!/bin/bash
set -e

DEFAULTS="/opt/claude-defaults"
CLAUDE="$HOME/.claude"

mkdir -p "$CLAUDE/skills" "$CLAUDE/plugins"

# settings.json が存在しない場合のみコピー（初回起動時）
if [ ! -f "$CLAUDE/settings.json" ]; then
    cp "$DEFAULTS/settings.json" "$CLAUDE/settings.json"
fi

# デフォルト Skills を追加（既存スキルは上書きしない）
for skill_dir in "$DEFAULTS/skills"/*/; do
    skill_name=$(basename "$skill_dir")
    if [ ! -d "$CLAUDE/skills/$skill_name" ]; then
        cp -r "$skill_dir" "$CLAUDE/skills/$skill_name"
    fi
done

# plugins（初回のみ）
if [ ! -f "$CLAUDE/plugins/known_marketplaces.json" ]; then
    cp -r "$DEFAULTS/plugins/." "$CLAUDE/plugins/"
fi

echo "✅ Claude Code DevContainer ready! Run: claude"
claude --version
