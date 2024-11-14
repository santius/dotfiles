export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM=~/zsh_custom

ZSH_THEME="robbyrussell"

zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 13

plugins=(git aliases colored-man-pages colorize command-not-found compleat cp genpass history rsync safe-paste vundle web-search autojump pj docker pip python pyenv virtualenv forklift macos battery rand-quote)

source $ZSH/oh-my-zsh.sh

setopt APPEND_HISTORY

if [[ "$(uname -s)" != "Linux" ]]; then
	HB_CNF_HANDLER="$(brew --repository)/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
	if [ -f "$HB_CNF_HANDLER" ]; then
		source "$HB_CNF_HANDLER";
	fi
fi

source $ZSH/oh-my-zsh.sh