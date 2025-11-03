# ~/.zprofile — login/session setup

# Build flags (env, not interactive)
export ARCHFLAGS="-arch $(uname -m)"

if [[ -S "$HOME/Library/Containers/com.apple.sshagent/Data/ssh-agent.socket" ]]; then
  export SSH_AUTH_SOCK="$HOME/Library/Containers/com.apple.sshagent/Data/ssh-agent.socket"
fi
