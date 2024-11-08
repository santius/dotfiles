export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13

export ZSH_CUSTOM=~/zsh_custom

plugins=(git aliases colored-man-pages colorize command-not-found compleat cp genpass history rsync safe-paste vundle web-search autojump pj docker pip python pyenv virtualenv forklift macos battery rand-quote)

source $ZSH/oh-my-zsh.sh

export HISTCONTROL=erasedups:ignorespace
export HISTSIZE=10000

setopt APPEND_HISTORY

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

if [[ "$(uname -s)" != "Linux" ]]; then
	HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
	if [ -f "$HB_CNF_HANDLER" ]; then
		source "$HB_CNF_HANDLER";
	fi
fi