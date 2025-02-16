#!/bin/bash

set -euo pipefail  # Exit on error, undefined vars, and pipe failures

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
    # Constants
    BASE_DIR="$HOME/dev/dotfiles"
    DOTS_DIR="$BASE_DIR/dots"
    ZSH_DIR="$BASE_DIR/zsh_custom"
    BACKUP_DIR="$HOME/.dotfiles_backup"
    ZSH_CUSTOM_DIR="$HOME/zsh_custom"
    GIT_IGNORE_FILE="$BASE_DIR/git/gitignore"
    VIM_DIR="$BASE_DIR/vim"

    FILES_TO_BACKUP=(
        "$HOME/.zshrc"
        "$HOME/.vimrc"
        "$HOME/.gitconfig"
        "$HOME/Brewfile"
        "$GIT_IGNORE_FILE"
    )

    mkdir -p "$BACKUP_DIR"

    echo "Starting installation process..."

    if confirm "Do you want to install Dotfiles?"; then

        echo "→ Configuring Neovim..."
        config_nvim || echo "Warning: Neovim configuration failed"

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

# Create backup directory if it doesn't exist


# Run the main function
main "$@"