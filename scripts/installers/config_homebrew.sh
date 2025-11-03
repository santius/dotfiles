function config_homebrew() {
    log_section "HOMEBREW"

    if ! command -v brew >/dev/null 2>&1; then
        log_info "Installing Homebrew..."
        if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
            log_error "Failed to install Homebrew"
            return 1
        fi

        if [[ -x /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -x /usr/local/bin/brew ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi

    local brew_prefix
    if ! brew_prefix="$(brew --prefix 2>/dev/null)"; then
        log_error "Unable to determine Homebrew prefix"
        return 1
    fi

    log_info "Updating Homebrew..."
    if ! brew update; then
        log_warn "brew update encountered an error"
    fi

    local brew_root="${BREW_DIR:-$BASE_DIR/config/brew}"
    local brewfile="$brew_root/Brewfile"
    if [[ -f "$brewfile" ]]; then
        log_info "Applying Brewfile: $brewfile"
        if ! brew bundle --file "$brewfile" --no-lock; then
            log_warn "brew bundle reported errors; check the output above"
        fi
    else
        log_warn "Brewfile not found at $brewfile"
    fi

    log_info "Configuring Homebrew completions"
    local brew_site_functions="$brew_prefix/share/zsh/site-functions"
    mkdir -p "$brew_site_functions"

    if [[ -d "$brew_site_functions" && $(command ls -A "$brew_site_functions" 2>/dev/null) ]]; then
        FPATH="$brew_site_functions:${FPATH:-}"
    fi

    if brew help completions >/dev/null 2>&1; then
        brew completions link >/dev/null 2>&1 || log_warn "brew completions link failed"
    fi

    local brew_services_opt="$brew_prefix/opt/brew-services/share/zsh/site-functions/_brew_services"
    local brew_services_target="$brew_site_functions/_brew_services"
    if [[ -f "$brew_services_opt" ]]; then
        ln -sf "$brew_services_opt" "$brew_services_target"
    elif [[ -L "$brew_services_target" && ! -e "$brew_services_target" ]]; then
        rm -f "$brew_services_target"
    fi

    log_success "Homebrew configuration completed"
}
