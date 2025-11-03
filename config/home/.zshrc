# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM=~/zsh_custom

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
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Completions: cached & no audits
autoload -Uz compinit
compinit -C -d ~/.cache/zsh/zcompdump
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.cache/zsh

# Lazy pyenv
lazy-pyenv() { command -v pyenv >/dev/null || return; eval "$(pyenv init -)"; }
pyenv() { lazy-pyenv; command pyenv "$@"; }

# Optional: lazy virtualenvwrapper only when used
workon() { command -v virtualenvwrapper.sh >/dev/null || return; . "$(command -v virtualenvwrapper.sh)"; workon "$@"; }

# Optional: zoxide instead of autojump (comment out autojump plugin if using this)
if command -v zoxide >/dev/null; then
  eval "$(zoxide init zsh)"
fi


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

# Initialize compinit safely. Use a consistent zcompdump path and avoid stat errors
autoload -Uz compinit
ZCOMP_DUMP="${ZDOTDIR:-$HOME}/.zcompdump"
if [ -f "$ZCOMP_DUMP" ]; then
    if [ "$(date +'%j')" != "$(stat -f '%Sm' -t '%j' "$ZCOMP_DUMP")" ]; then
        compinit
    else
        compinit -C
    fi
else
    compinit
fi

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Source all custom configurations
for config_file ($ZSH_CUSTOM/*.zsh(N)); do
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

# FZF configuration if installed
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

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
