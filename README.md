# Claude Code Notifier

A macOS notification tool that sends system push notifications when Claude Code needs user input, choices, or when tasks are completed.

## Purpose

When using Claude Code for development, if Claude needs you to provide further information, make a choice, or a task is completed, this tool will automatically send a system push notification to alert you, preventing you from missing important interaction moments.

## Features

- **Automatic Notifications**: Integrates with Claude Code hooks to trigger automatically when needed
- **Multiple Scenarios**: Supports various scenarios including input requests, choice requests, task completion, error alerts, etc.
- **Native System Integration**: Uses macOS native Notification Center for a seamless experience
- **Customizable**: Supports custom notification titles, messages, and sounds

## How It Works

This tool operates through the following mechanisms:

1. **terminal-notifier**: Uses `terminal-notifier` to invoke macOS Notification Center
2. **Shell Script**: `notify.sh` provides a simple interface, encapsulating notifications for different scenarios
3. **Claude Code Hooks**: By configuring Claude Code hooks, the notification script is automatically called when specific events occur
4. **Event Listening**: Monitors Claude's output and triggers notifications when keywords requiring user input are detected

## Installation

### Quick Install

Run the installation script:

```bash
cd ClaudeCodeNotifier
./install.sh
```

The installation script will automatically complete the following steps:
1. Check and install Homebrew (if not installed)
2. Install terminal-notifier
3. Copy scripts to the configuration directory `~/.claude-code-notifier/`
4. Set execution permissions
5. Create global command `claude-notify` (requires permissions)
6. **Automatically configure Claude Code hooks** (backs up existing config)
7. Send a test notification to confirm successful installation

**Important**: After installation, **restart Claude Code** for the hooks to take effect.

### Manual Installation

If you prefer to install manually:

```bash
# 1. Install terminal-notifier
brew install terminal-notifier

# 2. Create configuration directory
mkdir -p ~/.claude-code-notifier

# 3. Copy script
cp notify.sh ~/.claude-code-notifier/
chmod +x ~/.claude-code-notifier/notify.sh

# 4. Create global command (optional)
sudo ln -s ~/.claude-code-notifier/notify.sh /usr/local/bin/claude-notify
```

## Configuring Claude Code Hooks

**The installation script automatically configures the hooks for you!** You only need to restart Claude Code.

If you have existing hooks or want to manually configure, see below.

### Config File Location

Claude Code configuration file location:
- macOS: `~/.claude/settings.json`

**Note**: The installer backs up your config before making changes to:
`~/.claude/settings.json.backup.YYYYMMDD_HHMMSS`

### Hook Configuration Example

If you need to manually add hooks, use the following configuration:

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude-code-notifier/notify.sh input"
          }
        ],
        "description": "Send notification when Claude needs tool permission or input is idle for 60+ seconds"
      }
    ]
  }
}
```

**How it works**: The Notification hook is triggered automatically by Claude Code when:
1. Claude needs permission to use a tool
2. The prompt input has been idle for 60+ seconds

This provides timely notifications without being too intrusive.

### Advanced Configuration Options

You can also customize hooks according to your needs. notify.sh supports the following parameters:

- `input` - Notification when input is needed
- `choice` - Notification when a choice is needed
- `complete` - Notification when task is completed
- `error` - Notification when an error occurs
- `question` - Notification when there's a question
- `custom "title" "message" "sound"` - Custom notification

## Usage

### Automatic Trigger (via Hooks)

After configuring the hooks, notifications will be automatically sent when Claude Code needs your input, without any manual operation.

### Manual Testing

You can manually run the script to test notifications:

```bash
# Test different types of notifications
~/.claude-code-notifier/notify.sh input
~/.claude-code-notifier/notify.sh choice
~/.claude-code-notifier/notify.sh complete
~/.claude-code-notifier/notify.sh error

# If global command is installed
claude-notify input
claude-notify custom "Custom Title" "Custom Message" "Glass"
```

### Available Sound Effects

macOS supports the following notification sounds:
- `Ping` - Default alert sound
- `Glass` - Glass sound
- `Basso` - Bass sound
- `Blow` - Blow sound
- `Bottle` - Bottle sound
- `Frog` - Frog sound
- `Funk` - Funk sound
- `Hero` - Hero sound
- `Morse` - Morse sound
- `Pop` - Pop sound
- `Purr` - Purr sound
- `Sosumi` - Sosumi sound
- `Submarine` - Submarine sound
- `Tink` - Tink sound

## Troubleshooting

### Notifications Not Showing

1. Check macOS Notification Center settings:
   - Open "System Settings" > "Notifications"
   - Ensure notifications for "Terminal" or "terminal-notifier" are enabled

2. Check if terminal-notifier is correctly installed:
   ```bash
   which terminal-notifier
   terminal-notifier -message "Test" -title "Test"
   ```

3. Check script permissions:
   ```bash
   ls -l ~/.claude-code-notifier/notify.sh
   # Should show -rwxr-xr-x
   ```

### Hooks Not Working

1. Check if the configuration file format is correct (JSON format)
2. Check if the configuration file path is correct
3. Restart Claude Code
4. Check Claude Code's log output

### Notifications Too Frequent

If notifications are too frequent, you can:
1. Modify the matching conditions in hooks to be more precise
2. Use stricter keyword matching
3. Add a cooldown mechanism (requires modifying notify.sh)

## File Structure

```
ClaudeCodeTools/
├── README.md          # This document
├── install.sh         # Automatic installation script
└── notify.sh          # Core notification script
```

Installed file locations:
```
~/.claude-code-notifier/
└── notify.sh          # Notification script

/usr/local/bin/
└── claude-notify      # Global command (symlink)
```

## Dependencies

- macOS 10.8 or higher
- Homebrew
- terminal-notifier
- Bash

## License

MIT License

## Contributing

Issues and pull requests are welcome!

## Changelog

### v1.0.0 (2025-10-04)
- Initial release
- Support for basic notification functionality
- Integration with Claude Code hooks
- Automated installation script
