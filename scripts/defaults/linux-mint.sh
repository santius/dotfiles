#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "This script is intended for Linux Mint/Linux only" >&2
  exit 1
fi

COMPUTER_NAME="${1:-}"
readonly COMPUTER_NAME
LOCAL_HOST_NAME="$(printf '%s' "$COMPUTER_NAME" | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]-' | cut -c 1-63)"
readonly LOCAL_HOST_NAME

if [[ -n "$COMPUTER_NAME" && -z "$LOCAL_HOST_NAME" ]]; then
  echo "Computer name must contain at least one letter, number, or hyphen" >&2
  exit 1
fi

log_info()  { printf '\033[0;32m[INFO]\033[0m %s\n' "$*"; }
log_warn()  { printf '\033[0;33m[WARN]\033[0m %s\n' "$*" >&2; }

run_or_warn() {
  if ! "$@"; then
    log_warn "Command failed (ignored): $*"
  fi
}

gsettings_has_key() {
  local schema="$1" key="$2"
  command -v gsettings >/dev/null 2>&1 || return 1
  gsettings list-keys "$schema" 2>/dev/null | grep -qx "$key"
}

set_gsetting() {
  local schema="$1" key="$2" value="$3"

  if ! gsettings_has_key "$schema" "$key"; then
    log_warn "gsettings key not available: $schema $key"
    return 0
  fi

  local current
  current="$(gsettings get "$schema" "$key" 2>/dev/null || true)"
  if [[ "$current" == "$value" ]]; then
    return 0
  fi

  run_or_warn gsettings set "$schema" "$key" "$value"
}

configure_hostname() {
  if [[ -z "$COMPUTER_NAME" ]]; then
    log_info "Computer name not provided; leaving hostname unchanged"
    return 0
  fi

  if ! command -v hostnamectl >/dev/null 2>&1; then
    log_warn "hostnamectl not found; skipping hostname configuration"
    return 0
  fi

  log_info "Configuring hostname to '$LOCAL_HOST_NAME'"
  run_or_warn sudo hostnamectl set-hostname "$LOCAL_HOST_NAME"
}

configure_desktop() {
  log_info "Configuring Linux Mint desktop defaults"

  set_gsetting org.nemo.preferences show-hidden-files true
  set_gsetting org.nemo.preferences show-image-thumbnails "'always'"
  set_gsetting org.nemo.preferences default-folder-viewer "'list-view'"

  set_gsetting org.cinnamon.desktop.interface clock-show-date true
  set_gsetting org.cinnamon.desktop.interface clock-use-24h true
  set_gsetting org.cinnamon.desktop.interface enable-animations false
  set_gsetting org.cinnamon.desktop.interface gtk-theme "'Mint-Y-Dark'"
  set_gsetting org.cinnamon.desktop.interface icon-theme "'Mint-Y'"

  set_gsetting org.cinnamon.desktop.wm.preferences button-layout "'menu:minimize,maximize,close'"
  set_gsetting org.cinnamon.desktop.wm.preferences focus-mode "'click'"
}

configure_keyboard_mouse() {
  log_info "Configuring keyboard and mouse defaults"

  set_gsetting org.cinnamon.desktop.peripherals.keyboard repeat true
  set_gsetting org.cinnamon.desktop.peripherals.keyboard delay 250
  set_gsetting org.cinnamon.desktop.peripherals.keyboard repeat-interval 20
  set_gsetting org.cinnamon.desktop.peripherals.mouse natural-scroll false
  set_gsetting org.cinnamon.desktop.peripherals.touchpad tap-to-click true
  set_gsetting org.cinnamon.desktop.peripherals.touchpad natural-scroll false
}

configure_power() {
  log_info "Configuring power defaults"

  set_gsetting org.cinnamon.settings-daemon.plugins.power sleep-inactive-ac-type "'nothing'"
  set_gsetting org.cinnamon.settings-daemon.plugins.power sleep-inactive-battery-type "'suspend'"
  set_gsetting org.cinnamon.settings-daemon.plugins.power sleep-inactive-battery-timeout 1800
}

main() {
  configure_hostname
  configure_desktop
  configure_keyboard_mouse
  configure_power

  log_info "Linux Mint defaults complete. Some changes may require logging out and back in."
}

main "$@"
