#!/usr/bin/env bash

function config_homebrew() {
    log_section "HOMEBREW"

    if ! command -v brew >/dev/null 2>&1; then
        if ! command -v curl >/dev/null 2>&1; then
            log_error "curl is required to install Homebrew"
            return 1
        fi

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

    log_info "Updating Homebrew..."
    if ! brew update; then
        log_warn "brew update encountered an error"
    fi

    local brew_root="${BREW_DIR:-$BASE_DIR/config/brew}"
    local brewfile="$brew_root/Brewfile"
    if [[ -f "$brewfile" ]]; then
        log_info "Applying Brewfile: $brewfile"
        if ! brew bundle --file "$brewfile" --no-lock; then
            log_error "brew bundle reported errors; check the output above"
            return 1
        fi
    else
        log_warn "Brewfile not found at $brewfile"
    fi

    log_success "Homebrew configuration completed"
}
