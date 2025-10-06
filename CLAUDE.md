# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Claude Code Notifier is a macOS notification tool that sends system push notifications when Claude Code needs user input, choices, or when tasks are completed. It integrates with Claude Code via hooks to automatically trigger notifications.

## Core Architecture

The tool consists of three main components working together:

1. **notify.sh** - Core notification script
   - Wraps `terminal-notifier` to send macOS notifications
   - Supports multiple notification types: input, choice, complete, error, question, custom
   - Auto-detects `terminal-notifier` from PATH (supports both Intel and Apple Silicon Homebrew paths)
   - Uses bash arrays for safe argument passing (not eval for command construction)

2. **install.sh** - Installation automation
   - Detects and installs dependencies (Homebrew, terminal-notifier)
   - Copies notify.sh to `~/.claude-code-notifier/`
   - Creates optional global symlink at `/usr/local/bin/claude-notify`
   - **Automatically configures Claude Code hooks** (backs up existing config first)
   - Detects existing hooks and preserves them
   - Self-tests by sending a notification

3. **hooks-config-example.json** - Claude Code integration template
   - Demonstrates the Notification hook configuration format
   - Shows how to integrate with Claude Code's hook system
   - Final configuration goes in `~/.claude/settings.json`

## Key Design Decisions

**Path Detection**: Scripts use `command -v` instead of hardcoded paths to support both Intel (`/usr/local/bin`) and Apple Silicon (`/opt/homebrew/bin`) Homebrew installations.

**Notification Triggering**: The Notification hook is triggered automatically by Claude Code in two scenarios: (1) when Claude needs permission to use a tool, (2) when the prompt input has been idle for 60+ seconds. This provides timely notifications when user attention is needed.

**Installation Flow**: The install script is idempotent - it checks for existing installations and only installs/configures what's missing. It uses Python 3 (pre-installed on macOS) to safely merge hooks configuration into the existing Claude Code config JSON, preserving any existing settings.

**Automatic Hook Configuration**: The installer detects if hooks already exist in the Claude Code config. If they do, it preserves them and notifies the user. If not, it adds the notification hooks automatically. All config changes are backed up with timestamps before modification.

## Testing

Test the notification script:
```bash
# Test different notification types
./notify.sh input
./notify.sh choice
./notify.sh complete
./notify.sh error
./notify.sh custom "Title" "Message" "Glass"

# Validate syntax before committing
bash -n notify.sh
bash -n install.sh
```

Test the installation:
```bash
./install.sh
# Should complete without errors and send a test notification
```

## Common Pitfalls

1. **Shell Syntax**: Avoid using `eval` for command construction - use bash arrays instead. Avoid parentheses in comments as they can cause parsing issues in some contexts.

2. **Path Assumptions**: Never hardcode `/usr/local/bin/terminal-notifier` - always use `command -v terminal-notifier` or call `terminal-notifier` directly to let PATH resolution work.

3. **Hook Configuration**: Claude Code hooks use a specific format with "type": "command" and receive JSON input via stdin. The hook receives data including session_id, transcript_path, cwd, hook_event_name, and message fields.

4. **Hook Types**: Available hooks include Notification, Stop, PreToolUse, PostToolUse, UserPromptSubmit, SubagentStop, PreCompact, SessionStart, and SessionEnd. The Notification hook is ideal for detecting when user input is needed.

## File Locations After Installation

- `~/.claude-code-notifier/notify.sh` - Installed notification script
- `/usr/local/bin/claude-notify` - Optional global command (symlink)
- `~/.claude/settings.json` - Claude Code CLI settings file (where hooks are added)
