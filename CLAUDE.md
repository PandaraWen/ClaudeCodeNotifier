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

**Notification Triggering**: The tool uses two types of hooks for comprehensive notification coverage:
- **Notification hook**: Triggered when Claude needs permission to use a tool or when the prompt input has been idle for 60+ seconds
- **Stop hook**: Triggered when Claude completes a task and stops working, providing timely completion notifications

This dual-hook approach ensures users are notified both when input is needed and when tasks are complete.

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
- `~/.claude/commands/save.md` - Global /save command for saving progress

## Global Commands

**`/save` command**: A custom slash command that automates the workflow of documenting and committing project progress:
1. Updates CLAUDE.md with recent changes and improvements
2. Creates a git commit with an appropriate message
3. Pushes changes to the remote repository

This command helps maintain project documentation and ensures changes are regularly synced to version control.
