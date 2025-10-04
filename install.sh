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

# 7. Download or create a simple icon (optional)
print_info "Setting up notification icon..."
# Can download an icon here, or use system default icon
# Skipping for now, using terminal-notifier's default icon

# 8. Test notification
print_info "Sending test notification..."
"$CONFIG_DIR/notify.sh" custom "Installation Success" "Claude Code Notification Tool has been installed!" "Glass"

echo ""
print_info "========================================"
print_info "Installation Complete!"
print_info "========================================"
echo ""
echo "Next steps:"
echo "1. Configure Claude Code hooks by adding the following to your Claude Code config file"
echo ""
echo "Config file location:"
echo "  macOS: ~/Library/Application Support/Claude/claude_desktop_config.json"
echo ""
echo "Or run the following command to see hooks configuration example:"
echo "  cat $SCRIPT_DIR/README.md"
echo ""
print_info "You can test notifications with these commands:"
echo "  $CONFIG_DIR/notify.sh input"
echo "  $CONFIG_DIR/notify.sh choice"
echo "  $CONFIG_DIR/notify.sh complete"
echo "  claude-notify custom \"Title\" \"Message\""
echo ""
