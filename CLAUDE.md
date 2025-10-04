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
   - Self-tests by sending a notification

3. **hooks-config-example.json** - Claude Code integration template
   - Demonstrates hook patterns for onAssistantMessage, onToolUse, onError
   - Uses grep with regex to detect when Claude needs user input
   - Final configuration goes in `~/Library/Application Support/Claude/claude_desktop_config.json`

## Key Design Decisions

**Path Detection**: Scripts use `command -v` instead of hardcoded paths to support both Intel (`/usr/local/bin`) and Apple Silicon (`/opt/homebrew/bin`) Homebrew installations.

**Notification Triggering**: The onAssistantMessage hook uses regex pattern matching against `$ASSISTANT_MESSAGE` to detect keywords like "choose", "select", "would you", "do you want" that indicate Claude needs user input.

**Installation Flow**: The install script is idempotent - it checks for existing installations and only installs/configures what's missing.

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

3. **Hook Configuration**: The hooks config uses environment variables like `$ASSISTANT_MESSAGE`, `$TOOL_NAME`, `$TOOL_RESULT` provided by Claude Code. These must be properly quoted in shell commands.

4. **Regex Patterns**: When updating keyword detection, remember to escape special regex characters and test with actual Claude Code output.

## File Locations After Installation

- `~/.claude-code-notifier/notify.sh` - Installed notification script
- `/usr/local/bin/claude-notify` - Optional global command (symlink)
- `~/Library/Application Support/Claude/claude_desktop_config.json` - User's Claude Code config (where hooks are added)
