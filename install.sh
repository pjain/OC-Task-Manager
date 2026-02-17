#!/bin/bash
#
# OC Task Manager Installation Script
# Version: 1.0.0
# Author: Clawd Architecture Team
# Date: February 17, 2026
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLI_NAME="clawd-task"
USER_BIN_DIR="$HOME/.local/bin"
SYSTEM_BIN_DIR="/usr/local/bin"
CONFIG_DIR="$HOME/.config/clawd"
CONFIG_FILE="$CONFIG_DIR/task-manager.json"
DATA_DIR="$SCRIPT_DIR/data"

# Functions
print_header() {
    echo ""
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}  OC Task Manager - Installation Script${NC}"
    echo -e "${BLUE}  Version: 1.0.0${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

check_prerequisites() {
    echo "Checking prerequisites..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed. Please install Node.js >= 18.0.0"
        echo "Visit: https://nodejs.org/"
        exit 1
    fi
    
    NODE_VERSION=$(node -v | cut -d'v' -f2)
    REQUIRED_VERSION="18.0.0"
    
    if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
        print_error "Node.js version $NODE_VERSION is too old. Required: >= $REQUIRED_VERSION"
        exit 1
    fi
    
    print_success "Node.js $NODE_VERSION installed"
    
    # Check Git (optional but recommended)
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version | cut -d' ' -f3)
        print_success "Git $GIT_VERSION installed"
    else
        print_warning "Git not found (optional but recommended)"
    fi
    
    echo ""
}

setup_directories() {
    echo "Setting up directories..."
    
    # Create data directory
    if [ ! -d "$DATA_DIR" ]; then
        mkdir -p "$DATA_DIR"
        print_success "Created data directory: $DATA_DIR"
    else
        print_info "Data directory already exists: $DATA_DIR"
    fi
    
    # Create config directory
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
        print_success "Created config directory: $CONFIG_DIR"
    fi
    
    echo ""
}

create_config() {
    echo "Creating configuration file..."
    
    if [ -f "$CONFIG_FILE" ]; then
        print_info "Config file already exists: $CONFIG_FILE"
        return
    fi
    
    cat > "$CONFIG_FILE" << EOF
{
  "dataDir": "$DATA_DIR",
  "enableSQLite": false,
  "autoSnapshot": true,
  "snapshotInterval": "1h",
  "defaultOwner": "clawd",
  "defaultProject": "main"
}
EOF
    
    print_success "Created config file: $CONFIG_FILE"
    echo ""
}

install_cli() {
    echo "Installing CLI..."
    
    # Determine installation target
    INSTALL_DIR=""
    
    # Check if we can use system-wide
    if [ -w "$SYSTEM_BIN_DIR" ] || [ "$EUID" -eq 0 ]; then
        INSTALL_DIR="$SYSTEM_BIN_DIR"
    else
        # Fall back to user-local
        INSTALL_DIR="$USER_BIN_DIR"
        mkdir -p "$USER_BIN_DIR"
    fi
    
    CLI_PATH="$INSTALL_DIR/$CLI_NAME"
    
    # Remove existing symlink if present
    if [ -L "$CLI_PATH" ]; then
        rm "$CLI_PATH"
    fi
    
    # Create symlink
    ln -s "$SCRIPT_DIR/bin/task" "$CLI_PATH"
    chmod +x "$SCRIPT_DIR/bin/task"
    
    print_success "Linked CLI to: $CLI_PATH"
    
    # Check if PATH includes the bin directory
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        print_warning "$INSTALL_DIR is not in your PATH"
        echo "Add this to your ~/.bashrc or ~/.zshrc:"
        echo "    export PATH=\"$INSTALL_DIR:\$PATH\""
        echo ""
        echo "Or run:"
        echo "    echo 'export PATH=\"$INSTALL_DIR:\$PATH\"' >> ~/.bashrc"
        echo "    source ~/.bashrc"
    fi
    
    echo ""
}

initialize_database() {
    echo "Initializing task database..."
    
    # Create initial tasks.json if it doesn't exist
    TASKS_FILE="$DATA_DIR/tasks.json"
    
    if [ ! -f "$TASKS_FILE" ]; then
        cat > "$TASKS_FILE" << EOF
{
  "version": "1.0.0",
  "lastUpdated": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "tasks": []
}
EOF
        print_success "Created initial task database: $TASKS_FILE"
    else
        print_info "Task database already exists"
    fi
    
    # Create history.jsonl if it doesn't exist
    HISTORY_FILE="$DATA_DIR/history.jsonl"
    
    if [ ! -f "$HISTORY_FILE" ]; then
        touch "$HISTORY_FILE"
        print_success "Created audit log: $HISTORY_FILE"
    fi
    
    echo ""
}

verify_installation() {
    echo "Verifying installation..."
    
    # Try to run the CLI
    if "$CLI_NAME" init &> /dev/null; then
        print_success "CLI is working correctly"
    else
        print_error "CLI test failed"
        exit 1
    fi
    
    echo ""
}

print_summary() {
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}  Installation Complete!${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo "OC Task Manager has been installed successfully."
    echo ""
    echo "Quick Start:"
    echo "  1. Create a task:    $CLI_NAME create \"My first task\" --due tomorrow"
    echo "  2. List tasks:      $CLI_NAME list"
    echo "  3. Show help:       $CLI_NAME --help"
    echo ""
    echo "Configuration:"
    echo "  Data directory:     $DATA_DIR"
    echo "  Config file:        $CONFIG_FILE"
    echo "  CLI location:       $(which $CLI_NAME)"
    echo ""
    echo "Dashboard:"
    echo "  1. Export tasks:    $CLI_NAME export > ~/Sites/tasks/data.json"
    echo "  2. Copy dashboard:  cp $SCRIPT_DIR/ui/dashboard.html ~/Sites/tasks/index.html"
    echo "  3. Open browser:    open ~/Sites/tasks/index.html"
    echo ""
    echo "Documentation:"
    echo "  README:             $SCRIPT_DIR/README.md"
    echo "  Skill Guide:        $SCRIPT_DIR/SKILL.md"
    echo ""
    echo -e "${BLUE}Happy task managing!${NC}"
    echo ""
}

# Trap to cleanup on error
trap 'print_error "Installation failed. Please check the error messages above."' ERR

# Main installation flow
print_header
check_prerequisites
setup_directories
create_config
install_cli
initialize_database
verify_installation
print_summary

exit 0
