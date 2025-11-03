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

# forward the flag only if present
ARGS=()
$FONTS && ARGS+=(--fonts)
# Base directory paths

export BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
export DOTS_DIR="$BASE_DIR/config/home"
export ZSH_DIR="$BASE_DIR/config/shell/zsh_custom"
export GIT_DIR="$BASE_DIR/config/git"
export BREW_DIR="$BASE_DIR/config/brew"

# Target directories
export BACKUP_DIR="$HOME/.dotfiles_backup"
export ZSH_CUSTOM_DIR="$HOME/zsh_custom"

# Source dependencies
source logger.sh
source "scripts/installers/config_dotfiles.sh"
source "scripts/installers/config_homebrew.sh"
source "scripts/installers/config_mac_defaults.sh"

# Check for required dependencies
for cmd in git curl; do
    if ! command -v "$cmd" &> /dev/null; then
        log_error "Error: $cmd is required but not installed"
        exit 1
    fi
done

# Files to backup
FILES_TO_BACKUP=(
    "$HOME/.zshrc"
    "$HOME/.zprofile"
    "$HOME/.vimrc"
    "$HOME/.gitconfig"
    "$HOME/Brewfile"
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

    log_info "Starting installation process..."

    if confirm "Do you want to install Dotfiles?"; then
        log_info "→ Configuring dotfiles..."
        config_dotfiles "${ARGS[@]}" || log_warn "Warning: Dotfiles configuration failed"
    fi

    # Configure GPG program for Git (helps avoid 'cannot run gpg' errors)
    if [ -f "$BASE_DIR/scripts/configure_gpg_program.sh" ]; then
                log_info "→ Setting git gpg.program..."
                "$BASE_DIR/scripts/configure_gpg_program.sh" --apply || echo "Warning: failed to set gpg.program"
    fi

    if [ "$OS" = "Darwin" ]; then
        if confirm "Do you want to install Homebrew?"; then
            log_info "→ Configuring Homebrew..."
            config_homebrew || log_warn "Warning: Homebrew configuration failed"
        fi

        if confirm "Do you want to config MacOS defaults?"; then
            if confirm "Do you want to change hostname?"; then
                read -p "Enter desired hostname: " hostname
                if [[ -n "$hostname" ]]; then
                    log_info "→ Configuring macOS defaults..."
                    config_macos_defaults "$hostname" || log_warn "Warning: macOS defaults configuration failed"
                else
                    log_error "Error: Hostname cannot be empty"
                    return 1
                fi
            fi
        fi
    fi

    log_success "Installation completed!"
}

# Run the main function
main "$@"
