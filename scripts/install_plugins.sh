#!/bin/bash

# Source dependencies
source logger.sh

# Make the script standalone: source the repo logger if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
if [ -f "$SCRIPT_DIR/../logger.sh" ]; then
    # shellcheck source=/dev/null
    source "$SCRIPT_DIR/../logger.sh"
fi

echo "Installing Oh My Zsh plugins..."

# Setup Homebrew completions
echo "Setting up Homebrew completions..."
if type brew &>/dev/null; then

    # Create the completions directory if it doesn't exist
    mkdir -p "$(brew --prefix)/share/zsh/site-functions"

    # Link all Homebrew completions
    brew completions link

    # Specifically link brew-services completion
    ln -sf "$(brew --prefix)/opt/brew-services/share/zsh/site-functions/_brew_services" "$(brew --prefix)/share/zsh/site-functions/_brew_services"

    # Update FPATH (initialize if necessary)
    FPATH=${FPATH:-}
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

    # Regenerate completions only if zsh is available
    if command -v zsh >/dev/null 2>&1; then
        zsh -c 'autoload -Uz compinit && compinit'
    else
        echo "Not running in zsh, skipping completion initialization"
    fi
fi

# Create plugins directory
mkdir -p ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins

# Define plugins to install (avoid associative arrays for macOS bash 3.x)
plugin_names=(
    "zsh-autosuggestions"
    "zsh-syntax-highlighting"
)
plugin_urls=(
    "https://github.com/zsh-users/zsh-autosuggestions"
    "https://github.com/zsh-users/zsh-syntax-highlighting"
)

# Install Homebrew packages needed for plugins (idempotent)
echo "Installing required Homebrew packages..."
packages=(autojump kubectl)
for pkg in "${packages[@]}"; do
    if brew list --formula | grep -q "^${pkg}$"; then
        brew install "$pkg"
    fi
done

# Install external plugins
for plugin_index in "${!plugin_names[@]}"; do
    plugin="${plugin_names[$plugin_index]}"
    url="${plugin_urls[$plugin_index]}"
    target_dir="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin"
    if [ ! -d "$target_dir" ]; then
        log_info "Installing $plugin..."
        git clone "$url" "$target_dir"
    else
        log_warn "$plugin already installed"
    fi
done

# Verify built-in plugins
log_info "Verifying built-in plugins..."
builtin_plugins=(
    "git"
    "aliases"
    "colored-man-pages"
    "colorize"
    "command-not-found"
    "cp"
    "history"
    "rsync"
    "safe-paste"
    "web-search"
    "docker"
    "pip"
    "python"
    "pyenv"
    "virtualenv"
    "macos"
    "battery"
    "docker-compose"
    "npm"
    "brew"
)

for plugin in "${builtin_plugins[@]}"; do
    if [ ! -d "$ZSH/plugins/$plugin" ]; then
        echo "Warning: Built-in plugin $plugin not found!"
    fi
done

log_success "Plugin installation complete!"
log_info "Please run 'source ~/.zshrc' to activate the changes"