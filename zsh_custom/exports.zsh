# ======================
# Language & Locale
# ======================
export LANG='en_US.UTF-8'
export LC_ALL='en_US.UTF-8'
export PYTHONIOENCODING='UTF-8'

# ======================
# Editor & Terminal
# ======================
export EDITOR='nvim'  # Using Neovim as default editor
export VISUAL="$EDITOR"
export CLICOLOR=1
export TERM="xterm-256color"

# Colors for ls and other commands
export LSCOLORS='ExFxBxDxCxegedabagacad'
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'

# ======================
# History Control
# ======================
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=50000
export SAVEHIST=10000
export HISTCONTROL=ignoreboth:erasedups  # ignore duplicates and commands starting with space
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help"  # ignore common commands
export HISTTIMEFORMAT="[%F %T] "  # add timestamps to history

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
export NODE_ENV='development'
export NPM_CONFIG_PREFIX="$HOME/.npm-global"

# Python
export PYTHONDONTWRITEBYTECODE=1  # Prevent Python from writing .pyc files
export PYTHONUNBUFFERED=1         # Force Python output to be unbuffered

# Go
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"

# Ruby
export GEM_HOME="$HOME/.gem"
export BUNDLE_PATH="$GEM_HOME"

# ======================
# Package Managers
# ======================
# Homebrew
export HOMEBREW_NO_ANALYTICS=1          # Disable Homebrew analytics
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export HOMEBREW_NO_AUTO_UPDATE=1        # Prevent auto-update on install
export HOMEBREW_AUTO_UPDATE_SECS=86400  # Update check once per day

# ======================
# Path Modifications
# ======================
# Add local bins to PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"
export PATH="$GOBIN:$PATH"
export PATH="$GEM_HOME/bin:$PATH"

# ======================
# Application Specific
# ======================
# FZF
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Ripgrep
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"

# ======================
# Performance
# ======================
# Compilation flags
export ARCHFLAGS="-arch $(uname -m)"
export MAKEFLAGS="-j$(nproc)"

# ======================
# Security
# ======================
export GPG_TTY=$(tty)  # For GPG signing
export SSH_AUTH_SOCK="$HOME/.ssh/ssh-agent.sock"