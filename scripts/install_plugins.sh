#!/bin/bash

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

    # Update FPATH
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

    # Regenerate completions
    if [ -n "$ZSH_VERSION" ]; then
        # Only run these in zsh
        zsh -c 'autoload -Uz compinit && compinit'
    else
        log_warn "Not running in zsh, skipping completion initialization"
    fi
fi

# Create plugins directory
mkdir -p ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins

# Define plugins to install
declare -A plugins=(
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
)

# Install Homebrew packages needed for plugins
echo "Installing required Homebrew packages..."
brew install autojump kubectl

# Install external plugins
for plugin in "${!plugins[@]}"; do
    if [ ! -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin" ]; then
        echo "Installing $plugin..."
        git clone "${plugins[$plugin]}" "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/$plugin"
    else
        echo "$plugin already installed"
    fi
done

# Verify built-in plugins
echo "Verifying built-in plugins..."
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

echo "Plugin installation complete!"
echo "Please run 'source ~/.zshrc' to activate the changes"