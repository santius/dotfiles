function config_macos_defaults() {
    local hostname="${1:-}"
    log_section "MACOS DEFAULTS"

    local defaults_script="$BASE_DIR/set-defaults.sh"

    if [[ ! -f "$defaults_script" ]]; then
        log_error "macOS defaults script not found at $defaults_script"
        return 1
    fi

    if [[ -z "$hostname" ]]; then
        log_error "Hostname is required to configure macOS defaults"
        return 1
    fi

    if ! bash "$defaults_script" "$hostname"; then
        log_warn "macOS defaults script reported an error"
        return 1
    fi

    log_success "macOS defaults applied"
}
