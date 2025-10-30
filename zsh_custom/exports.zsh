# Load secrets file if it exists
[ -f "$HOME/.secrets" ] && source "$HOME/.secrets"

export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM=~/zsh_custom
export DOWNLOADS="$HOME/Downloads"
export DESKTOP="$HOME/Desktop"
export DOCUMENTS="$HOME/Documents"
export PICTURES="$HOME/Pictures"
export MOVIES="$HOME/Movies"
export MUSIC="$HOME/Music"
export PUBLIC="$HOME/Public"
export DEV="$HOME/dev"



# ======================
# Security & Signing
# ======================
# GPG configuration
export GPG_TTY=$(tty)                           # For GPG signing
export GNUPGHOME="$HOME/.gnupg"                 # GPG home directory

# ======================
# Language & Locale
# ======================
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export PYTHONIOENCODING='UTF-8'

# Colors for ls and other commands
export LSCOLORS='ExFxBxDxCxegedabagacad'
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# ======================
# Man Pages & Less
# ======================
# Colored man pages
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# Less options
export LESS='-F -g -i -M -R -S -w -X -z-4'
export MANPAGER='less -X'  # Don't clear the screen after quitting a manual page

# ======================
# Development
# ======================
# Node.js
export NODE_ENV="developnoment"
export NVM_DIR="$HOME/.nvm"

# Python
export PYENV_ROOT="$HOME/.pyenv"
export PYTHONDONTWRITEBYTECODE=1  # Prevent creation of .pyc files

# Java
if [[ -z "${JAVA_HOME:-}" && -x /usr/libexec/java_home ]]; then
    _dotfiles_java_cache="${XDG_CACHE_HOME:-$HOME/.cache}/java_home"
    if [[ -f "$_dotfiles_java_cache" ]]; then
        export JAVA_HOME="$(<"$_dotfiles_java_cache")"
    else
        _dotfiles_java_home="$(/usr/libexec/java_home 2>/dev/null)"
        if [[ -n "$_dotfiles_java_home" ]]; then
            export JAVA_HOME="$_dotfiles_java_home"
            mkdir -p "${_dotfiles_java_cache:h}"
            printf '%s\n' "$JAVA_HOME" >"$_dotfiles_java_cache"
        fi
    fi
    unset _dotfiles_java_cache _dotfiles_java_home
else
    export JAVA_HOME
fi

# Docker
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

# ======================
# Editor & Terminal
# ======================
export EDITOR="nvim"
export VISUAL="code -w"
export CLICOLOR=1
export TERM="xterm-256color"

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# ======================
# Package Managers
# ======================
# Homebrew
export HOMEBREW_NO_ANALYTICS=1          # Disable Homebrew analytics
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export HOMEBREW_NO_AUTO_UPDATE=1        # Prevent auto-update on install
export HOMEBREW_AUTO_UPDATE_SECS=86400  # Update check every 24 hours
export HOMEBREW_NO_ENV_HINTS=1          # Disable hints about shell environment
export HOMEBREW_NO_INSECURE_REDIRECT=1  # Prevent insecure redirects
export HOMEBREW_NO_INSTALL_CLEANUP=1    # Prevent auto cleanup of old versions
export HOMEBREW_BAT=1                   # Use bat for brew cat if available
export HOMEBREW_EDITOR="cursor"           # Use VS Code as editor
export HOMEBREW_FORCE_BREWED_CURL=1     # Use Homebrew's curl instead of system
export HOMEBREW_DISPLAY_INSTALL_TIMES=1 # Show install times for packages
export HOMEBREW_NO_EMOJI=1              # Disable emoji in output
export HOMEBREW_GITHUB_API_TOKEN=$GITHUB_TOKEN  # Use GitHub token for API requests
export HOMEBREW_CASK_OPTS="--appdir=/Applications --fontdir=/Library/Fonts"
export HOMEBREW_COLOR=1                 # Force color output even in pipes

# ======================
# Application Specific
# ======================
# FZF
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Ripgrep
if [ -f "$HOME/.ripgreprc" ]; then
    export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
else
    unset RIPGREP_CONFIG_PATH
fi

# ======================
# Performance
# ======================
# Compilation flags
export ARCHFLAGS="-arch $(uname -m)"
if command -v nproc >/dev/null 2>&1; then
    _dotfiles_make_jobs="$(nproc)"
else
    _dotfiles_make_jobs="$(sysctl -n hw.ncpu 2>/dev/null || echo 1)"
fi
export MAKEFLAGS="-j${_dotfiles_make_jobs}"
unset _dotfiles_make_jobs

# SSH configuration
export SSH_AUTH_SOCK="$HOME/.ssh/ssh-agent.sock"

# Security preferences
export CURL_SSL_VERIFY=true                     # Always verify SSL certificates
export NODE_TLS_REJECT_UNAUTHORIZED=1           # Enforce TLS certificate validation
export SSL_CERT_DIR="/etc/ssl/certs"           # SSL certificates directory
