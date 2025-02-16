# CD
alias cd="z"
alias ..="cd .."
alias cd..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias -- -="cd -"

# mv, rm, cp
alias mv='mv -v'
alias rm='rm -i -v'
alias cp='cp -v'

# GIT
alias ga="git add"
alias gc="git commit"
alias pull="git pull"
alias push="git push"


alias cls='clear'
alias c='clear'
alias reload='. ~/.zshrc'
alias pubkey="more ~/.ssh/id_rsa.pub | pbcopy | echo '=> Public key copied to pasteboard.'"
alias top=btop
alias zedit="vim ~/.zshrc"

alias ..='cd ..'
alias ls='ls -la'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias diff='colordiff'
alias vi=vim
alias ports='netstat -tulanp'
alias meminfo='free -m -l -t'
alias wget='wget -c'
alias df='df -H'
alias du='dust'
alias cat="bat"
alias aliases="vim $ZSH_CUSTOM/aliases.zsh"
alias fuck="sudo !!"
alias test="ls"
alias puto="ls"

# TYPOS
alias where=which
alias brwe=brew

# IP addresses
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Show active network interfaces
alias ifactive="ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Show/hide hidden files in Finder
alias show="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
alias hide="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"


# Miscellaneous

alias hosts="sudo $EDITOR /etc/hosts"
alias quit="exit"
alias week="date +%V"
alias speedtest="wget -O /dev/null http://speed.transip.nl/100mb.bin"
alias grip="grip --browser --pass=$GITHUB_TOKEN"
alias zip="zip -x *.DS_Store -x *__MACOSX* -x *.AppleDouble*"
alias afk="open /System/Library/CoreServices/ScreenSaverEngine.app"
alias logoff="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash/*; sudo rm -rfv /private/var/log/asl/*.asl"

# Show system information

alias displays="system_profiler SPDisplaysDataType"
alias cpu="sysctl -n machdep.cpu.brand_string"
alias ram="top -l 1 -s 0 | grep PhysMem"

# all in one homebrew, gem update commands
alias brewup='brew update && brew upgrade && brew cleanup'
alias gemup='gem update --system && gem update && gem cleanup'
alias npmup='npm -g cache clean && npm -g update && npm-check-updates -u && npm install'
alias sysup='sudo softwareupdate -i -a'
alias upall='sysup && brewup && gemup && npmup'

# Directory navigation improvements
alias cd..='cd ..'
alias -- -='cd -'
alias cdd='cd ~/Downloads'
alias cddoc='cd ~/Documents'
alias cddes='cd ~/Desktop'

# Git improvements - add these
alias gs='git status'
alias gd='git diff'
alias gl='git log --oneline'
alias gco='git checkout'
alias gb='git branch'
alias gst='git stash'
alias grb='git rebase'
alias gcp='git cherry-pick'

# Docker aliases - consider adding
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dimg='docker images'

# Kubernetes aliases - if you use k8s
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgn='kubectl get nodes'

# Improved system commands
alias mkdir='mkdir -p'    # Create parent directories if needed
alias ping='ping -c 5'    # Ping with 5 packets by default
alias path='echo -e ${PATH//:/\\n}'  # Pretty print PATH
alias ports='ss -tulanp'  # Modern alternative to netstat

# Development
alias py='python3'
alias pip='pip3'
alias npml='npm list -g --depth=0'  # List global npm packages