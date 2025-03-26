#!/bin/bash

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

# Base directory paths
export DOTFILES="$HOME/dev/dotfiles"
export BASE_DIR="$DOTFILES"
export DOTS_DIR="$BASE_DIR/dots"
export ZSH_DIR="$BASE_DIR/zsh_custom"
export GIT_DIR="$DOTFILES/git"
export VIM_DIR="$BASE_DIR/vim"

# Target directories
export BACKUP_DIR="$HOME/.dotfiles_backup"
export ZSH_CUSTOM_DIR="$HOME/zsh_custom"
export GIT_IGNORE_FILE="$GIT_DIR/gitignore"

# Source dependencies
source logger.sh
source "functions/config_dotfiles.sh"
source "functions/config_homebrew.sh"
source "functions/config_mac_defaults.sh"

# Check if running on macOS
if [[ "$(uname)" != "Darwin" ]]; then
    echo "Error: This script is designed for macOS only"
    exit 1
fi

# Check for required dependencies
for cmd in git curl; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "Error: $cmd is required but not installed"
        exit 1
    fi
done

# Files to backup
FILES_TO_BACKUP=(
    "$HOME/.zshrc"
    "$HOME/.vimrc"
    "$HOME/.gitconfig"
    "$HOME/Brewfile"
    "$GIT_IGNORE_FILE"
    "$HOME/.ssh/config"
    "$HOME/.config/git/message"
    "$HOME/.config/starship.toml"
    "$HOME/.config/bat/config"
)

# Helper function for yes/no prompts
confirm() {
    local prompt="$1 (yes/no): "
    local response
    while true; do
        read -p "$prompt" response
        case "$response" in
            [yY]|[yY][eE][sS]) return 0 ;;
            [nN]|[nN][oO]) return 1 ;;
            *) echo "Please answer yes or no" ;;
        esac
    done
}

# Main installation process with progress feedback
main() {
    mkdir -p "$BACKUP_DIR"

    echo "Starting installation process..."

    if confirm "Do you want to install Dotfiles?"; then
        echo "→ Configuring dotfiles..."
        config_dotfiles || echo "Warning: Dotfiles configuration failed"
    fi

    if confirm "Do you want to install Homebrew?"; then
        echo "→ Configuring Homebrew..."
        config_homebrew || echo "Warning: Homebrew configuration failed"
    fi

    if confirm "Do you want to config MacOS defaults?"; then
        read -p "Enter desired hostname: " hostname
        if [[ -n "$hostname" ]]; then
            echo "→ Configuring macOS defaults..."
            config_macos_defaults "$hostname" || echo "Warning: macOS defaults configuration failed"
        else
            echo "Error: Hostname cannot be empty"
            return 1
        fi
    fi

    echo "Installation completed!"
}

# Run the main function
main "$@"