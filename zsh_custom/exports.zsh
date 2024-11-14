export EDITOR="mvim"
export CLICOLOR=1
# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"

export HOMEBREW_CASK_OPTS="--appdir=/Applications"

export HISTCONTROL=erasedups:ignorespace
export HISTSIZE=10000

# highlighting inside manpages and elsewhere
export LESS_TERMCAP_mb=$(printf '\e[01;31m')													# enter blinking mode – red
export LESS_TERMCAP_md=$(printf '\e[01;35m')													# enter double-bright mode – bold, magenta
export LESS_TERMCAP_me=$(printf '\e[0m')															# turn off all appearance modes (mb, md, so, us)
export LESS_TERMCAP_se=$(printf '\e[0m')															# leave standout mode
export LESS_TERMCAP_so=$(printf '\e[01;33m')													# enter standout mode – yellow
export LESS_TERMCAP_ue=$(printf '\e[0m')															# leave underline mode
export LESS_TERMCAP_us=$(printf '\e[04;36m')