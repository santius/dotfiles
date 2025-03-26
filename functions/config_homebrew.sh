function config_homebrew() {
    log_section "Configuring Homebrew"

    # Install Homebrew if not installed
    if ! command -v brew >/dev/null 2>&1; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Update Homebrew
    log_info "Updating Homebrew..."
    brew update

    # Update Brewfile location check
    if [ -f "$DOTFILES/brew/Brewfile" ]; then
        log_info "Using Brewfile from $DOTFILES/brew/Brewfile"
        BREWFILE="$DOTFILES/brew/Brewfile"
    else
        log_warn "Brewfile not found in $DOTFILES/brew/Brewfile"
        return 1
    fi

    # Install Brewfile packages
    if [ -f "$BREWFILE" ]; then
        log_info "Checking Brewfile packages..."

        # Read Brewfile and install missing packages
        while IFS= read -r line; do
            # Skip comments and empty lines
            [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue

            # Parse the line to get package type and name
            if echo "$line" | grep -q '^brew "'; then
                # Handle brew packages
                package=$(echo "$line" | sed 's/^brew "\([^"]*\)".*/\1/')
                if ! brew list "$package" &>/dev/null; then
                    log_info "Installing brew package: $package"
                    brew install "$package"
                else
                    log_info "Package already installed: $package"
                fi
            elif echo "$line" | grep -q '^cask "'; then
                # Handle cask packages
                package=$(echo "$line" | sed 's/^cask "\([^"]*\)".*/\1/')
                if ! brew list --cask "$package" &>/dev/null; then
                    log_info "Installing cask: $package"
                    brew install --cask "$package"
                else
                    log_info "Cask already installed: $package"
                fi
            elif echo "$line" | grep -q '^tap "'; then
                # Handle taps
                tap=$(echo "$line" | sed 's/^tap "\([^"]*\)".*/\1/')
                if ! brew tap | grep -q "^$tap$"; then
                    log_info "Adding tap: $tap"
                    brew tap "$tap"
                else
                    log_info "Tap already added: $tap"
                fi
            fi
        done < "$BREWFILE"
    else
        log_warn "Brewfile not found at $BREWFILE"
    fi

    # Configure PATH
    log_info "Configuring PATH..."
    local path_entries=(
        "$HOME/bin"                      # User binaries
        "/opt/homebrew/bin"             # Homebrew binaries (Apple Silicon)
        "/opt/homebrew/sbin"            # Homebrew system binaries
        "/usr/local/bin"                # Local binaries
        "/usr/local/sbin"               # Local system binaries
        "$HOME/.local/bin"              # Local user binaries
    )

    # Add paths to exports.zsh
    local exports_file="$ZSH_CUSTOM/exports.zsh"
    touch "$exports_file"

    log_info "Updating PATH in exports.zsh..."
    echo "# PATH Configuration" >> "$exports_file"
    for entry in "${path_entries[@]}"; do
        if [[ ":$PATH:" != *":$entry:"* ]]; then
            echo "export PATH=\"$entry:\$PATH\"" >> "$exports_file"
            log_success "Added $entry to PATH"
        fi
    done

    # Setup Homebrew completions
    log_info "Setting up Homebrew completions..."
    if type brew &>/dev/null; then
        # Initialize FPATH if not set
        FPATH=${FPATH:-""}

        # Add Homebrew completions to FPATH
        FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

        # Create the completions directory if it doesn't exist
        mkdir -p "$(brew --prefix)/share/zsh/site-functions"

        # Link all Homebrew completions
        brew completions link
    fi

    log_success "Homebrew configuration completed"
}