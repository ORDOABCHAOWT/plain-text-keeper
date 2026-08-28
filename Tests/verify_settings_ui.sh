#!/usr/bin/env zsh
set -euo pipefail

SOURCE="${1:-Sources/main.swift}"
BUILD_SCRIPT="${2:-build.sh}"
AGENTS_FILE="${3:-AGENTS.md}"

rg --quiet 'struct HotKeyConfig' "$SOURCE"
rg --quiet 'SettingsWindowController' "$SOURCE"
rg --quiet 'recordShortcut' "$SOURCE"
rg --quiet 'hotKeyConfigDefaultsKey' "$SOURCE"
rg --quiet 'Settings...' "$SOURCE"
rg --quiet 'Quit App' "$SOURCE"
rg --quiet 'showSettings' "$SOURCE"
rg --quiet 'resetShortcut' "$SOURCE"
rg --quiet 'showLaunchHint' "$SOURCE"
rg --quiet 'applyHotKeyConfig' "$SOURCE"
rg --quiet 'makeSection' "$SOURCE"
rg --quiet 'makePrimaryButton' "$SOURCE"
rg --quiet 'makeSquareButton' "$SOURCE"
rg --quiet 'makeDangerButton' "$SOURCE"
rg --quiet 'Shortcut' "$SOURCE"
rg --quiet 'Behavior' "$SOURCE"
rg --quiet 'width: 350, height: 318' "$SOURCE"
rg --quiet 'let cards = NSStackView' "$SOURCE"
rg --quiet 'cards.orientation = .vertical' "$SOURCE"
rg --fixed-strings --quiet 'shortcutSection.widthAnchor.constraint(equalTo: cards.widthAnchor)' "$SOURCE"
rg --fixed-strings --quiet 'behaviorSection.widthAnchor.constraint(equalTo: cards.widthAnchor)' "$SOURCE"

# Project invariants: keep the utility event-driven, menu-bar-only, and dependency-free.
rg --fixed-strings --quiet 'RegisterEventHotKey' "$SOURCE"
rg --fixed-strings --quiet 'SMAppService.mainApp' "$SOURCE"
rg --fixed-strings --quiet 'guard let text = pasteboard.string(forType: .string)' "$SOURCE"
rg --fixed-strings --quiet 'pasteboard.clearContents()' "$SOURCE"
rg --fixed-strings --quiet 'pasteboard.setString(text, forType: .string)' "$SOURCE"
rg --fixed-strings --quiet '<key>LSUIElement</key>' "$BUILD_SCRIPT"
rg --fixed-strings --quiet '<true/>' "$BUILD_SCRIPT"
rg --fixed-strings --quiet 'no Dock icon' "$AGENTS_FILE"
rg --fixed-strings --quiet 'Never paste automatically' "$AGENTS_FILE"
rg --fixed-strings --quiet 'Never poll or continuously monitor the clipboard' "$AGENTS_FILE"
rg --fixed-strings --quiet 'Keep the project dependency-free' "$AGENTS_FILE"

if rg --quiet 'Timer|scheduledTimer|TimerPublisher' "$SOURCE"; then
  echo "Unexpected timer usage in $SOURCE" >&2
  exit 1
fi

if rg --quiet 'CGEvent|CGEventPost|kCGEventKeyDown|kCGEventKeyUp' "$SOURCE"; then
  echo "Unexpected synthetic key event or auto-paste behavior in $SOURCE" >&2
  exit 1
fi
