#!/usr/bin/env bash

set -euo pipefail

if [[ "${OSTYPE:-}" != darwin* ]]; then
  echo "This script is intended for macOS only" >&2
  exit 1
fi

if (( $# == 0 )); then
  echo "Usage: $0 <computer-name>" >&2
  exit 1
fi

readonly COMPUTER_NAME="$1"
readonly LANGUAGES=("en-US")
readonly LOCALE="en_US"
readonly MEASUREMENT_UNITS="Centimeters"
readonly SCREENSHOTS_FOLDER="$HOME/Pictures/Screenshots"
readonly DOTFILES_ROOT="${BASE_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# -----------------------------------------------------------------------------
# Logging helpers
# -----------------------------------------------------------------------------

log_info()  { printf '\033[0;32m[INFO]\033[0m %s\n' "$*"; }
log_warn()  { printf '\033[0;33m[WARN]\033[0m %s\n' "$*" >&2; }
log_error() { printf '\033[0;31m[ERROR]\033[0m %s\n' "$*" >&2; }

# -----------------------------------------------------------------------------
# Utility helpers
# -----------------------------------------------------------------------------

require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_error "Required command '$cmd' not found"
    return 1
  fi
}

write_default() {
  local domain="$1" key="$2" type="$3" value="$4" current desired
  current=$(defaults read "$domain" "$key" 2>/dev/null || true)
  case "$type" in
    bool)
      case "$value" in
        1|true|TRUE|yes|YES) desired="1" ; value=true ;;
        *) desired="0" ; value=false ;;
      esac
      ;;
    int)
      desired="$value"
      ;;
    float|string)
      desired="$value"
      ;;
    *)
      desired="$value"
      ;;
  esac

  if [[ "$current" == "$desired" ]]; then
    return 0
  fi

  defaults write "$domain" "$key" -$type "$value"
}

write_default_bool()    { write_default "$1" "$2" bool "$3"; }
write_default_int()     { write_default "$1" "$2" int "$3"; }
write_default_float()   { write_default "$1" "$2" float "$3"; }
write_default_string()  { write_default "$1" "$2" string "$3"; }

write_default_array() {
  local domain="$1" key="$2"; shift 2
  defaults write "$domain" "$key" -array "$@"
}

run_or_warn() {
  if ! "$@"; then
    log_warn "Command failed (ignored): $*"
  fi
}

# -----------------------------------------------------------------------------
# System configuration blocks
# -----------------------------------------------------------------------------

apply_system_settings() {
  log_info "Preparing to apply system settings"
  require_command sudo || return 1

  if command -v osascript >/dev/null 2>&1; then
    osascript -e 'tell application "System Preferences" to quit' || true
  fi

  sudo -v
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
  local keepalive_pid=$!
  trap 'kill "${keepalive_pid}" 2>/dev/null || true' EXIT
}

set_computer_name() {
  log_info "Configuring computer name to '$COMPUTER_NAME'"
  run_or_warn sudo scutil --set ComputerName "$COMPUTER_NAME"
  run_or_warn sudo scutil --set HostName "$COMPUTER_NAME"
  run_or_warn sudo scutil --set LocalHostName "$COMPUTER_NAME"
  run_or_warn sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server \
    NetBIOSName -string "$COMPUTER_NAME"
}

configure_localization() {
  log_info "Configuring localization"
  write_default_array NSGlobalDomain AppleLanguages "${LANGUAGES[@]}"
  write_default_string NSGlobalDomain AppleLocale "$LOCALE"
  write_default_string NSGlobalDomain AppleMeasurementUnits "$MEASUREMENT_UNITS"
  write_default_bool   NSGlobalDomain AppleMetricUnits true
  run_or_warn sudo defaults write /Library/Preferences/com.apple.timezone.auto Active -bool YES
  run_or_warn sudo systemsetup -setusingnetworktime on
}

configure_system() {
  log_info "Configuring system behaviour"
  run_or_warn sudo systemsetup -setrestartfreeze on
  run_or_warn sudo pmset -a standbydelay 86400
  run_or_warn defaults write com.apple.sound.beep.feedback -bool false
  run_or_warn sudo nvram SystemAudioVolume=" "
  run_or_warn sudo nvram StartupMute=%01
  write_default_bool  com.apple.menuextra.battery ShowPercent true
  write_default_bool  NSGlobalDomain NSAutomaticWindowAnimationsEnabled false
  write_default_float NSGlobalDomain NSWindowResizeTime 0.001
  write_default_bool  NSGlobalDomain NSNavPanelExpandedStateForSaveMode  true
  write_default_bool  NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 true
}

configure_keyboard() {
  log_info "Configuring keyboard"
  write_default_bool NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled false
  write_default_bool NSGlobalDomain NSAutomaticDashSubstitutionEnabled false
  write_default_int  NSGlobalDomain AppleKeyboardUIMode 3
  write_default_int  NSGlobalDomain KeyRepeat 1
  write_default_int  NSGlobalDomain InitialKeyRepeat 15
  write_default_bool NSGlobalDomain NSAutomaticSpellingCorrectionEnabled false
}

configure_trackpad() {
  log_info "Configuring trackpad"
  write_default_bool com.apple.AppleMultitouchTrackpad Clicking true
  write_default_bool com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking true
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  write_default_int NSGlobalDomain com.apple.mouse.tapBehavior 1
  write_default_bool NSGlobalDomain AppleEnableSwipeNavigateWithScrolls true
  defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerHorizSwipeGesture -int 1
}

configure_screen() {
  log_info "Configuring screen and screenshots"
  mkdir -p "$SCREENSHOTS_FOLDER"
  write_default_string com.apple.screencapture location "$SCREENSHOTS_FOLDER"
  write_default_string com.apple.screencapture type png
  write_default_bool   com.apple.screencapture disable-shadow true
  write_default_int    com.apple.screensaver askForPassword 1
  write_default_int    com.apple.screensaver askForPasswordDelay 0
}

configure_finder() {
  log_info "Configuring Finder"
  write_default_string com.apple.finder FXPreferredViewStyle Nlsv
  write_default_bool   com.apple.finder ShowStatusBar true
  write_default_bool   com.apple.finder ShowPathbar true
  write_default_bool   com.apple.finder _FXShowPosixPathInTitle true
  write_default_bool   com.apple.finder AppleShowAllFiles true
  write_default_bool   NSGlobalDomain AppleShowAllExtensions true
  write_default_bool   com.apple.desktopservices DSDontWriteNetworkStores true
  write_default_bool   com.apple.desktopservices DSDontWriteUSBStores true
}

configure_dock() {
  log_info "Configuring Dock"
  write_default_bool com.apple.dock show-process-indicators true
  write_default_bool com.apple.dock launchanim false
  write_default_bool com.apple.dock autohide false
  write_default_bool com.apple.dock showhidden true
  write_default_bool com.apple.dock no-bouncing true
  write_default_bool com.apple.dock show-recents false
}

set_wallpaper() {
  local image="$1"

  if [[ -z "$image" || ! -f "$image" ]]; then
    log_warn "Wallpaper not applied – file missing: $image"
    return 0
  fi

  log_info "Setting wallpaper to $image"

  osascript <<EOF
tell application "System Events"
  repeat with d in desktops
    set picture of d to POSIX file "$image"
  end repeat
end tell
EOF
}


main() {
  apply_system_settings
  set_computer_name
  configure_localization
  configure_system
  configure_keyboard
  configure_trackpad
  configure_screen
  configure_finder
  configure_dock
  set_wallpaper "$DOTFILES_ROOT/assets/images/wallpapers/flatppuccin_4k_macchiato.png"

  log_info "Configuration complete. Some changes may require a restart."

  log_info "Restarting affected applications"
  for app in Finder Dock SystemUIServer; do
    run_or_warn killall "$app"
  done
}

main
