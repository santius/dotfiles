# Add directories to the PATH and prevent adding the same directory multiple times
# ======================
# Path Modifications
# ======================

add_to_path() {
    if [[ -d "$1" ]] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="$1:$PATH"
    fi
}

# Homebrew paths (prioritized)
add_to_path "/opt/homebrew/bin"
add_to_path "/opt/homebrew/sbin"
add_to_path "/usr/local/bin"
add_to_path "/usr/local/sbin"

# User specific paths
add_to_path "$HOME/.local/bin"
add_to_path "$HOME/bin"

# Python paths
add_to_path "$HOME/.pyenv/bin"
add_to_path "$HOME/.pyenv/shims"

# Ruby paths
add_to_path "$HOME/.rbenv/bin"
add_to_path "$HOME/.rbenv/shims"

# Custom scripts
add_to_path "$HOME/.scripts"

# Load dotfiles binaries
add_to_path "$HOME/bin"

# Node paths
add_to_path "$HOME/.npm-global/bin"
add_to_path "$HOME/.nvm/versions/node/*/bin"

# Cargo (Rust) path
add_to_path "$HOME/.cargo/bin"

# Remove duplicate entries
typeset -U PATH

# Export the final PATH
export PATH
