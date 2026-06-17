#!/usr/bin/env bash

config_os_defaults() {
    local hostname="${1:-}"
    local os_name
    os_name="$(uname -s)"

    case "$os_name" in
        Darwin)
            config_macos_defaults "$hostname"
            ;;
        Linux)
            config_linux_defaults "$hostname"
            ;;
        *)
            log_warn "OS defaults are not supported on $os_name"
            return 0
            ;;
    esac
}

config_macos_defaults() {
    local hostname="${1:-}"
    local defaults_script="$BASE_DIR/scripts/defaults/macos.sh"

    log_section "MACOS DEFAULTS"

    if [[ ! -f "$defaults_script" ]]; then
        log_error "macOS defaults script not found at $defaults_script"
        return 1
    fi

    if ! bash "$defaults_script" "$hostname"; then
        log_warn "macOS defaults script reported an error"
        return 1
    fi

    log_success "macOS defaults applied"
}

config_linux_defaults() {
    local hostname="${1:-}"
    local defaults_script="$BASE_DIR/scripts/defaults/linux-mint.sh"
    local os_id="" os_pretty=""

    log_section "LINUX DEFAULTS"

    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        source /etc/os-release
        os_id="${ID:-}"
        os_pretty="${PRETTY_NAME:-Linux}"
    fi

    if [[ "$os_id" != "linuxmint" ]]; then
        log_warn "Linux defaults are currently tuned for Linux Mint; detected ${os_pretty:-unknown}. Skipping."
        return 0
    fi

    if [[ ! -f "$defaults_script" ]]; then
        log_error "Linux Mint defaults script not found at $defaults_script"
        return 1
    fi

    if ! bash "$defaults_script" "$hostname"; then
        log_warn "Linux Mint defaults script reported an error"
        return 1
    fi

    log_success "Linux Mint defaults applied"
}
