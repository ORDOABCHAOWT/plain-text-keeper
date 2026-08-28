#!/usr/bin/env zsh
set -euo pipefail

SOURCE="${1:-Sources/main.swift}"
AGENTS_FILE="${2:-AGENTS.md}"

rg --quiet 'applicationShouldHandleReopen' "$SOURCE"
rg --quiet 'showStatusWindow' "$SOURCE"
rg --quiet 'Plain Text Keeper is running' "$SOURCE"
rg --fixed-strings --quiet 'menu bar utility with no Dock icon' "$AGENTS_FILE"
rg --fixed-strings --quiet 'The default shortcut is Control + Option + Command + V' "$AGENTS_FILE"
rg --fixed-strings --quiet 'If the clipboard has no text representation, leave it unchanged' "$AGENTS_FILE"
