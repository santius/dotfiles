# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM=~/zsh_custom

# Theme setting
ZSH_THEME="robbyrussell"

# Update settings
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13

# History settings
HISTSIZE=50000
SAVEHIST=10000
setopt EXTENDED_HISTORY      # Save timestamps in history
setopt SHARE_HISTORY        # Share history between sessions
setopt INC_APPEND_HISTORY   # Add commands to history as they are typed
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate
setopt HIST_FIND_NO_DUPS         # Don't display duplicates during searches
setopt HIST_IGNORE_SPACE         # Don't record entries starting with a space
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks
setopt HIST_VERIFY              # Show command with history expansion before running it

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
    aliases
    colored-man-pages
    colorize
    command-not-found
    cp
    history
    rsync
    safe-paste
    web-search
    autojump
    docker
    pip
    python
    pyenv
    virtualenv
    forklift
    macos
    battery
    docker-compose
    npm
    brew
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Homebrew completions - guard against missing files to avoid compinit errors
#
# If you see errors like:
#   compinit:527: no such file or directory: /opt/homebrew/share/zsh/site-functions/_brew_services
# it's because a stale symlink points to a completion that isn't installed.
# To restore the completion, install or reinstall the package that provides it, e.g:
#   brew install brew-services
# or remove the stale symlink under $(brew --prefix)/share/zsh/site-functions.
if type brew &>/dev/null; then
    BREW_SITE_FUNCTIONS="$(brew --prefix)/share/zsh/site-functions"

    # Only add Homebrew completions to FPATH when the directory exists and contains files
    if [ -d "$BREW_SITE_FUNCTIONS" ] && [ "$(ls -A "$BREW_SITE_FUNCTIONS" 2>/dev/null)" ]; then
        FPATH="$BREW_SITE_FUNCTIONS:${FPATH}"
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
fi

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Source all custom configurations
for config_file ($ZSH_CUSTOM/*.zsh(N)); do
  source $config_file
done

# Homebrew command not found handler
if [[ "$(uname -s)" != "Linux" ]]; then
    HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
    if [ -f "$HB_CNF_HANDLER" ]; then
        source "$HB_CNF_HANDLER";
    fi
fi

# Better directory navigation
setopt autocd autopushd pushdignoredups

# Command execution time stamp shown in the history
HIST_STAMPS="yyyy-mm-dd"

# FZF configuration if installed
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Local config
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
