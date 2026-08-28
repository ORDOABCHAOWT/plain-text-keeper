# Plain Text Keeper AI Constraints

This file is the project-level operating guide for AI-assisted changes. Read it before editing this project.

## Product Invariants

- Plain Text Keeper removes formatting from the current clipboard only.
- Never paste automatically after cleaning.
- Never poll or continuously monitor the clipboard.
- Never add timers for clipboard monitoring or background clipboard work.
- If the clipboard has no text representation, leave it unchanged and play the system alert sound.
- Keep the app as a menu bar utility with no Dock icon.
- The default shortcut is Control + Option + Command + V.

## Technical Stack

- Keep the app native Swift/AppKit.
- Use Carbon `RegisterEventHotKey` for global shortcut behavior.
- Use `ServiceManagement` for Launch at Login.
- Keep the project dependency-free unless the user explicitly approves a dependency.
- Build through `INSTALL_APP=0 ./build.sh` when a verified artifact is needed without changing the installed app.
- Install through `./build.sh` only when the user explicitly wants the current app replaced.
- Preserve manual `.app` bundle packaging unless the user explicitly asks to migrate the project structure.

## Architecture

- Keep small, focused changes in `Sources/main.swift`.
- `AppDelegate` owns lifecycle, status menu, global hotkey registration, clipboard cleaning, and Launch at Login state.
- `SettingsWindowController` owns the settings window and settings-only UI interactions.
- `HotKeyConfig` owns shortcut persistence and display data.
- Split files only when a responsibility becomes independently understandable and testable.
- Do not introduce SwiftUI, Electron, SPM, helper daemons, or background agents without explicit user approval.

## Verification

- For settings UI or shortcut changes, run `Tests/verify_settings_ui.sh`.
- For launch hint or reopen behavior changes, run `Tests/verify_launch_feedback.sh`.
- For Swift, packaging, icon, or Info.plist changes, run `INSTALL_APP=0 ./build.sh` first.
- Keep `LSUIElement=true` in the generated app bundle so the app stays out of the Dock.

## Prompting Checklist

When asking an AI agent to change this project, include:

- The user-facing behavior to add or change.
- The invariants above that must stay unchanged.
- The likely files involved.
- The verification command expected before delivery.
