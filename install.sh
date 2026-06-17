#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"

FONTS=false
while [ $# -gt 0 ]; do
  case "$1" in
    --fonts) FONTS=true ;;
    *) echo "Unknown flag: $1"; exit 1 ;;
  esac; shift
done

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
export BASE_DIR
export DOTS_DIR="$BASE_DIR/config/home"
export ZSH_DIR="$BASE_DIR/config/shell/zsh_custom"
export GIT_DIR="$BASE_DIR/config/git"
export BREW_DIR="$BASE_DIR/config/brew"

# Target directories
export BACKUP_DIR="$HOME/.dotfiles_backup"
export ZSH_CUSTOM_DIR="$HOME/zsh_custom"

# Source dependencies
# shellcheck disable=SC1091
source "$BASE_DIR/scripts/shared/logger.sh"
# shellcheck disable=SC1091
source "$BASE_DIR/scripts/installers/config_dotfiles.sh"
# shellcheck disable=SC1091
source "$BASE_DIR/scripts/installers/config_homebrew.sh"
# shellcheck disable=SC1091
source "$BASE_DIR/scripts/installers/config_os_defaults.sh"

# Check for required dependencies
for cmd in git curl; do
    if ! command -v "$cmd" &> /dev/null; then
        log_error "Error: $cmd is required but not installed"
        exit 1
    fi
done

# Files to backup
# shellcheck disable=SC2034 # consumed by config_dotfiles.sh after sourcing
FILES_TO_BACKUP=(
    "$HOME/.zshrc"
    "$HOME/.zprofile"
    "$HOME/.vimrc"
    "$HOME/.gitconfig"
    "$HOME/Brewfile"
    "$HOME/.ssh/config"
    "$HOME/.config/git/message"
    "$HOME/.config/bat/config"
)

# Helper function for yes/no prompts
confirm() {
    local prompt="$1 (yes/no): "
    local response
    while true; do
        read -r -p "$prompt" response
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

    log_info "Starting installation process..."

    if confirm "Do you want to install Dotfiles?"; then
        log_info "→ Configuring dotfiles..."
        if $FONTS; then
            config_dotfiles --fonts || log_warn "Warning: Dotfiles configuration failed"
        else
            config_dotfiles || log_warn "Warning: Dotfiles configuration failed"
        fi
    fi

    if [ "$OS" = "Darwin" ]; then
        if confirm "Do you want to install Homebrew?"; then
            log_info "→ Configuring Homebrew..."
            config_homebrew || log_warn "Warning: Homebrew configuration failed"
        fi
    fi

    if [[ "$OS" = "Darwin" || "$OS" = "Linux" ]]; then
        if confirm "Do you want to configure OS defaults?"; then
            local hostname=""
            if confirm "Do you want to set or change hostname?"; then
                read -r -p "Enter desired hostname: " hostname
                if [[ -z "$hostname" ]]; then
                    log_error "Error: Hostname cannot be empty when hostname change is selected"
                    return 1
                fi
            fi

            log_info "→ Configuring OS defaults..."
            config_os_defaults "$hostname" || log_warn "Warning: OS defaults configuration failed"
        fi
    fi

    log_success "Installation completed!"
}

# Run the main function
main "$@"
