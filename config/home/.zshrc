
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to oh-my-zsh installation
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"
export ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/zsh_custom}"

if [[ -z "${DOTFILES_ENV_LOADED:-}" ]]; then
  [[ -r "$ZSH_CUSTOM/path.zsh" ]] && source "$ZSH_CUSTOM/path.zsh"
  [[ -r "$ZSH_CUSTOM/exports.zsh" ]] && source "$ZSH_CUSTOM/exports.zsh"
  export DOTFILES_ENV_LOADED=1
fi

[[ -r ~/.p10k.zsh ]] && source ~/.p10k.zsh

# Exit early for non-interactive shells to skip heavy setup
[[ $- != *i* ]] && return

# Theme setting
ZSH_THEME="powerlevel10k/powerlevel10k"

# Update settings
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13

# History settings

export HISTFILE="$HOME/.local/state/zsh/history"

# In-memory and on-disk history sizes (match them)
HISTSIZE=50000
SAVEHIST=50000

# Metadata + immediate append
setopt EXTENDED_HISTORY       # timestamps etc.
setopt INC_APPEND_HISTORY     # write each cmd as it runs
setopt SHARE_HISTORY          # merge across sessions

# De-dup & cleanliness (lightweight)
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS   # supersedes HIST_IGNORE_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
# Optional: comment out if you want max speed during search
# setopt HIST_FIND_NO_DUPS

# History expansion safety (harmless)
setopt HIST_VERIFY


# Directory navigation
setopt AUTO_CD              # If command is a directory path, cd into it
setopt AUTO_PUSHD          # Make cd push old directory onto directory stack
setopt PUSHD_IGNORE_DUPS   # Don't push duplicates onto directory stack
setopt PUSHD_MINUS         # Exchange meaning of + and - for current vs last dir

# Completion settings
setopt COMPLETE_IN_WORD    # Complete from both ends of a word
setopt ALWAYS_TO_END       # Move cursor to end of word after completion
setopt PATH_DIRS           # Perform path search even on command names with slashes
setopt AUTO_MENU           # Show completion menu on successive tab press
setopt AUTO_LIST           # Automatically list choices on ambiguous completion
setopt AUTO_PARAM_SLASH    # If completed parameter is a directory, add a trailing slash
setopt NO_BEEP            # Don't beep on ambiguous completions

# Additional plugins to consider
plugins=(
  git
  macos
  brew
  docker
  docker-compose
  npm
#  zsh-autosuggestions
#  zsh-syntax-highlighting
)

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh

export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "$PYENV_ROOT/bin" ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
fi

if command -v pyenv >/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Optional: lazy virtualenvwrapper only when used
workon() { command -v virtualenvwrapper.sh >/dev/null || return; . "$(command -v virtualenvwrapper.sh)"; workon "$@"; }

# Cache Homebrew paths once to avoid spawning the Ruby CLI during shell startup
if (( $+commands[brew] )); then
    if [[ -n "${HOMEBREW_PREFIX:-}" ]]; then
        __DOTFILES_BREW_PREFIX="$HOMEBREW_PREFIX"
    elif [[ -x /opt/homebrew/bin/brew ]]; then
        __DOTFILES_BREW_PREFIX="/opt/homebrew"
    elif [[ -x /usr/local/bin/brew ]]; then
        __DOTFILES_BREW_PREFIX="/usr/local"
    else
        __DOTFILES_BREW_PREFIX="$(command brew --prefix 2>/dev/null)"
    fi

    if [[ -n "${HOMEBREW_REPOSITORY:-}" ]]; then
        __DOTFILES_BREW_REPO="$HOMEBREW_REPOSITORY"
    elif [[ -n "$__DOTFILES_BREW_PREFIX" && -d "$__DOTFILES_BREW_PREFIX/Homebrew" ]]; then
        __DOTFILES_BREW_REPO="$__DOTFILES_BREW_PREFIX/Homebrew"
    else
        __DOTFILES_BREW_REPO="$__DOTFILES_BREW_PREFIX"
    fi
fi

# Homebrew completions - guard against missing files to avoid compinit errors
#
# If you see errors like:
#   compinit:527: no such file or directory: /opt/homebrew/share/zsh/site-functions/_brew_services
# it's because a stale symlink points to a completion that isn't installed.
# To restore the completion, install or reinstall the package that provides it, e.g:
#   brew install brew-services
# or remove the stale symlink under $(brew --prefix)/share/zsh/site-functions.
if [[ -n "$__DOTFILES_BREW_PREFIX" ]]; then
    BREW_SITE_FUNCTIONS="${__DOTFILES_BREW_PREFIX}/share/zsh/site-functions"

    # Only add Homebrew completions to FPATH when the directory exists and contains files
    if [ -d "$BREW_SITE_FUNCTIONS" ] && [ "$(command ls -A "$BREW_SITE_FUNCTIONS" 2>/dev/null)" ]; then
        FPATH="$BREW_SITE_FUNCTIONS:${FPATH}"
    fi
fi

# Initialize compinit safely (Linux-friendly, no stat)
autoload -Uz compinit
ZCOMP_DUMP="${ZDOTDIR:-$HOME}/.zcompdump"

# If dump exists and was modified today -> fast path (-C). Otherwise rebuild.
# Initialize compinit safely (Linux Mint)

# Fast path if dump exists, otherwise build it
if [[ -f "$ZCOMP_DUMP" ]]; then
  compinit -C -d "$ZCOMP_DUMP"
else
  compinit -d "$ZCOMP_DUMP"
fi

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Source all custom configurations
for config_file ($ZSH_CUSTOM/*.zsh(N)); do
  case "${config_file:t}" in
    exports.zsh|path.zsh) continue ;;
  esac
  source $config_file
done

# Homebrew command-not-found handlers (newer location first, fall back to the tap)
if [[ -n "$__DOTFILES_BREW_REPO" ]]; then
    typeset -a __dotfiles_brew_cnf_handlers
    __dotfiles_brew_cnf_handlers=(
        "$__DOTFILES_BREW_REPO/Library/Homebrew/command-not-found/handler.sh"
        "$__DOTFILES_BREW_REPO/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
    )

    for __dotfiles_brew_handler in "${__dotfiles_brew_cnf_handlers[@]}"; do
        if [ -f "$__dotfiles_brew_handler" ]; then
            source "$__dotfiles_brew_handler"
            break
        fi
    done
    unset __dotfiles_brew_cnf_handlers __dotfiles_brew_handler
fi

# Better directory navigation
setopt autocd autopushd pushdignoredups

# Command execution time stamp shown in the history
HIST_STAMPS="yyyy-mm-dd"

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# Use fd to generate the list for path completion
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# fzf key bindings + fuzzy completion
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
elif [[ -f ~/.fzf.zsh ]]; then
  source ~/.fzf.zsh
fi

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# SDKMAN lazy init keeps startup fast; it loads on first use or when entering a folder with .sdkmanrc.
export SDKMAN_DIR="$HOME/.sdkman"
if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
    autoload -Uz add-zsh-hook

    _sdkman_lazy_init() {
        unset -f sdk _sdkman_lazy_init
        add-zsh-hook -d chpwd _sdkman_auto_env_lazy 2>/dev/null
        source "$SDKMAN_DIR/bin/sdkman-init.sh"
        unset -f _sdkman_auto_env_lazy
    }

    sdk() {
        _sdkman_lazy_init
        sdk "$@"
    }

    _sdkman_auto_env_lazy() {
        [[ -f .sdkmanrc ]] || return
        _sdkman_lazy_init
        (( $+functions[sdkman_auto_env] )) && sdkman_auto_env
    }

    add-zsh-hook chpwd _sdkman_auto_env_lazy
    _sdkman_auto_env_lazy
fi

if [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]]; then
  builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
fi

FZF_GIT_SH="${DEV:-$HOME/dev}/fzf-git.sh/fzf-git.sh"
[[ -f "$FZF_GIT_SH" ]] && source "$FZF_GIT_SH"
unset FZF_GIT_SH
export PATH=/Users/santiago.hernandez/Library/Globant/CodingAgent/bin:$PATH  ## AUTOGENERATED BY CODING AGENT INSTALLER
# Added by coda install
export PATH="/Users/santiago.hernandez/.coda/bin:$PATH"
