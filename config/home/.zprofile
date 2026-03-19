
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.pre.zsh"

# ~/.zprofile — login/session setup

if [[ -S "$HOME/Library/Containers/com.apple.sshagent/Data/ssh-agent.socket" ]]; then
  export SSH_AUTH_SOCK="$HOME/Library/Containers/com.apple.sshagent/Data/ssh-agent.socket"
fi


# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.post.zsh"
