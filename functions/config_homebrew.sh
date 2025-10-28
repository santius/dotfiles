function config_homebrew() {
    log_section "HOMEBREW"

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

    # Setup Homebrew completions
    log_info "Setting up Homebrew completions..."
    if type brew &>/dev/null; then
        # Initialize FPATH if not set
        FPATH=${FPATH:-""}

        BREW_SITE_FUNCTIONS="$(brew --prefix)/share/zsh/site-functions"
        mkdir -p "$BREW_SITE_FUNCTIONS"

        # Only add Homebrew completions to FPATH when directory has files
        if [ -d "$BREW_SITE_FUNCTIONS" ] && [ "$(ls -A "$BREW_SITE_FUNCTIONS" 2>/dev/null)" ]; then
            FPATH="$BREW_SITE_FUNCTIONS:${FPATH}"
        fi

        # Link all Homebrew completions if available
        if command -v brew >/dev/null 2>&1; then
            brew completions link || true
        fi

        # Ensure specific brew-services completion exists before linking (optional)
        BREW_SERVICES_OPT="$(brew --prefix)/opt/brew-services/share/zsh/site-functions/_brew_services"
        BREW_SERVICES_TARGET="$BREW_SITE_FUNCTIONS/_brew_services"
        if [ -f "$BREW_SERVICES_OPT" ]; then
            ln -sf "$BREW_SERVICES_OPT" "$BREW_SERVICES_TARGET"
        else
            # Remove stale symlink if target exists but source missing
            if [ -L "$BREW_SERVICES_TARGET" ] && [ ! -e "$BREW_SERVICES_TARGET" ]; then
                rm -f "$BREW_SERVICES_TARGET"
            fi
        fi
    fi

    log_success "Homebrew configuration completed"
}