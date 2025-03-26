# Directory navigation improvements
alias ~="cd ~"
alias ..='cd ..'
alias down='cd ~/Downloads'
alias docs='cd ~/Documents'
alias desk='cd ~/Desktop'
alias blog="cd ~/dev/santius.me"

# File operations
alias mv='mv -v'
alias rm='rm -i -v'
alias cp='cp -v'
alias mkdir='mkdir -v'    # Create parent directories if needed

# System commands
alias c='clear'
alias reload='. ~/.zshrc'
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"
alias top=btop
alias zedit="vim ~/.zshrc"
alias ls='eza -l -X -a --group-directories-first'

# Search and diff
alias grep='egrep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias diff='colordiff'

# Enhanced commands
alias vi=vim
alias wget='wget -c'
alias df='df -H'
alias du='dust'
alias cat="bat"
alias ping='ping -c 5'    # Ping with 5 packets by default
alias ports='ss -tulanp'  # Keep modern version
alias path='echo -e ${PATH//:/\\n}'

# Config editing
alias aliases="vim $ZSH_CUSTOM/aliases.zsh"
alias hosts="sudo $EDITOR /etc/hosts"

# Common typos
alias where=which
alias brwe=brew
alias fuck="sudo !!"

# Network
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
alias speedtest="wget -O /dev/null http://speed.transip.nl/100mb.bin"

# System maintenance
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash/*; sudo rm -rfv /private/var/log/asl/*.asl"

# System info
alias displays="system_profiler SPDisplaysDataType"
alias cpu="sysctl -n machdep.cpu.brand_string"

# Updates
alias brewup='brew update && brew upgrade && brew cleanup'
alias npmup='npm -g update'
alias sysup='sudo softwareupdate -i -a'

# Git (consider removing if using Oh-My-Zsh git plugin)
alias gl='git log --oneline'  # Keep this as it's custom format
alias gcp='git cherry-pick'   # Keep if not in Oh-My-Zsh
alias pull="git pull"
alias push="git push"

# Docker
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dimg='docker images'

# Development
alias py='python3'
alias pip='pip3'
alias npml='npm list -g --depth=0'