#!/bin/bash

# Claude Code Notification Tool Installation Script

set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.claude-code-notifier"

print_info "Starting Claude Code Notification Tool installation..."

# 1. Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This tool only supports macOS"
    exit 1
fi

# 2. Check and install Homebrew
if ! command -v brew &> /dev/null; then
    print_warn "Homebrew not detected, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    print_info "Homebrew already installed"
fi

# 3. Install terminal-notifier
if ! command -v terminal-notifier &> /dev/null; then
    print_info "Installing terminal-notifier..."
    brew install terminal-notifier
else
    print_info "terminal-notifier already installed"
fi

# 4. Create configuration directory
if [ ! -d "$CONFIG_DIR" ]; then
    print_info "Creating configuration directory: $CONFIG_DIR"
    mkdir -p "$CONFIG_DIR"
fi

# 5. Copy and set script permissions
print_info "Copying notification script to config directory..."
cp "$SCRIPT_DIR/notify.sh" "$CONFIG_DIR/notify.sh"
chmod +x "$CONFIG_DIR/notify.sh"

# 6. Create symlink to /usr/local/bin (optional)
if [ -w "/usr/local/bin" ]; then
    print_info "Creating symlink to /usr/local/bin..."
    ln -sf "$CONFIG_DIR/notify.sh" "/usr/local/bin/claude-notify"
    print_info "You can now use 'claude-notify' command globally"
else
    print_warn "Cannot create symlink, run manually: sudo ln -sf $CONFIG_DIR/notify.sh /usr/local/bin/claude-notify"
fi

# 7. Configure Claude Code hooks
CLAUDE_CONFIG="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
print_info "Configuring Claude Code hooks..."

if [ -f "$CLAUDE_CONFIG" ]; then
    # Backup existing config
    BACKUP_CONFIG="${CLAUDE_CONFIG}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$CLAUDE_CONFIG" "$BACKUP_CONFIG"
    print_info "Backed up existing config to: $BACKUP_CONFIG"

    # Check if hooks already exist
    if grep -q '"hooks"' "$CLAUDE_CONFIG"; then
        print_warn "Hooks configuration already exists in Claude Code config"
        echo "Your existing hooks have been preserved."
        echo "To manually add notifications, see: $SCRIPT_DIR/hooks-config-example.json"
    else
        # Add hooks using python3 (available on all macOS)
        python3 -c "
import json
import sys

config_file = '$CLAUDE_CONFIG'
notify_script = '$CONFIG_DIR/notify.sh'

# Read existing config
with open(config_file, 'r') as f:
    config = json.load(f)

# Add hooks configuration
config['hooks'] = {
    'onAssistantMessage': {
        'command': 'bash',
        'args': [
            '-c',
            f'if echo \"\$ASSISTANT_MESSAGE\" | grep -iE \"(decide|choose|select|which|would you|do you want|prefer|please.*you)\" > /dev/null; then {notify_script} input; fi'
        ],
        'description': 'Detect if Claude needs user input or choice and send notification'
    },
    'onToolUse': {
        'command': 'bash',
        'args': [
            '-c',
            f'case \"\$TOOL_NAME\" in TodoWrite) if echo \"\$TOOL_RESULT\" | grep -qE \"completed.*100%|all.*completed\"; then {notify_script} complete; fi ;; *) ;; esac'
        ],
        'description': 'Detect when all tasks are completed and send notification'
    },
    'onError': {
        'command': notify_script,
        'args': ['error'],
        'description': 'Send notification when error occurs'
    }
}

# Write updated config
with open(config_file, 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')
"
        print_info "Hooks configuration added to Claude Code config"
        print_warn "Please restart Claude Code for the hooks to take effect"
    fi
else
    print_warn "Claude Code config file not found at: $CLAUDE_CONFIG"
    echo "Please create the config file and add hooks manually."
    echo "See example at: $SCRIPT_DIR/hooks-config-example.json"
fi

# 8. Test notification
print_info "Sending test notification..."
"$CONFIG_DIR/notify.sh" custom "Installation Success" "Claude Code Notification Tool has been installed!" "Glass"

echo ""
print_info "========================================"
print_info "Installation Complete!"
print_info "========================================"
echo ""
print_info "Next steps:"
echo "1. Restart Claude Code to activate the notification hooks"
echo "2. Test by asking Claude a question that requires your input"
echo ""
print_info "You can test notifications manually with these commands:"
echo "  $CONFIG_DIR/notify.sh input"
echo "  $CONFIG_DIR/notify.sh choice"
echo "  $CONFIG_DIR/notify.sh complete"
echo "  claude-notify custom \"Title\" \"Message\""
echo ""
