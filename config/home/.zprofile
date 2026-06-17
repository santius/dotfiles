
# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.pre.zsh"

# ~/.zprofile — login/session setup

export ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/zsh_custom}"

if [[ -z "${DOTFILES_ENV_LOADED:-}" ]]; then
  [[ -r "$ZSH_CUSTOM/path.zsh" ]] && source "$ZSH_CUSTOM/path.zsh"
  [[ -r "$ZSH_CUSTOM/exports.zsh" ]] && source "$ZSH_CUSTOM/exports.zsh"
  export DOTFILES_ENV_LOADED=1
fi

if [[ -S "$HOME/Library/Containers/com.apple.sshagent/Data/ssh-agent.socket" ]]; then
  export SSH_AUTH_SOCK="$HOME/Library/Containers/com.apple.sshagent/Data/ssh-agent.socket"
fi


# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zprofile.post.zsh"
