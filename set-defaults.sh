#!/bin/bash

# Exit on error, undefined vars, and pipe failures
set -euo pipefail

# Check if a computer name was provided
if [ $# -eq 0 ]; then
    echo "Error: Please provide a computer name as an argument"
    echo "Usage: $0 <computer-name>"
    exit 1
fi

# Configuration variables
readonly COMPUTER_NAME="$1"
readonly LANGUAGES=(en-US)
readonly LOCALE="enUS"
readonly MEASUREMENT_UNITS="Centimeters"
readonly SCREENSHOTS_FOLDER="${HOME}/Pictures/Screenshots"

# Function to apply system settings
apply_system_settings() {
    echo "Applying system settings..."

    # Quit System Preferences to prevent override
    osascript -e 'tell application "System Preferences" to quit'

    # Ask for the administrator password upfront
    sudo -v

    # Keep-alive: update existing `sudo` time stamp until this script has finished
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
}

# Function to set computer name
set_computer_name() {
    echo "Setting computer name to: $COMPUTER_NAME"

    sudo scutil --set ComputerName "$COMPUTER_NAME"
    sudo scutil --set HostName "$COMPUTER_NAME"
    sudo scutil --set LocalHostName "$COMPUTER_NAME"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$COMPUTER_NAME"
}

# Function to configure localization
configure_localization() {
    echo "Configuring localization settings..."

    defaults write NSGlobalDomain AppleLanguages -array "${LANGUAGES[@]}"
    defaults write NSGlobalDomain AppleLocale -string "$LOCALE"
    defaults write NSGlobalDomain AppleMeasurementUnits -string "$MEASUREMENT_UNITS"
    defaults write NSGlobalDomain AppleMetricUnits -bool true

    # Set timezone automatically
    sudo defaults write /Library/Preferences/com.apple.timezone.auto Active -bool YES
    sudo systemsetup -setusingnetworktime on || true  # Ignore Error:-99
}

# Function to configure system behavior
configure_system() {
    echo "Configuring system behavior..."

    # System
    sudo systemsetup -setrestartfreeze on 2> /dev/null || true
    sudo pmset -a standbydelay 86400
    defaults write com.apple.sound.beep.feedback -bool false
    sudo nvram SystemAudioVolume=" "
    sudo nvram StartupMute=%01

    # Menu bar
    defaults write com.apple.menuextra.battery ShowPercent YES

    # Windows and animations
    defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
    defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
}

# Function to configure keyboard and input
configure_keyboard() {
    echo "Configuring keyboard and input..."

    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
}

# Function to configure trackpad
configure_trackpad() {
    echo "Configuring trackpad..."

    # Tap to click
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # Three finger swipe
    defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerHorizSwipeGesture -int 1
}

# Function to configure screen and screenshots
configure_screen() {
    echo "Configuring screen and screenshots..."

    # Screenshot settings
    mkdir -p "${SCREENSHOTS_FOLDER}"
    defaults write com.apple.screencapture location -string "${SCREENSHOTS_FOLDER}"
    defaults write com.apple.screencapture type -string "png"
    defaults write com.apple.screencapture disable-shadow -bool true

    # Security
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
}

# Function to configure Finder
configure_finder() {
    echo "Configuring Finder..."

    # View preferences
    defaults write com.apple.finder FXPreferredViewStyle Nlsv
    defaults write com.apple.finder ShowStatusBar -bool true
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

    # Show hidden files and extensions
    defaults write com.apple.finder AppleShowAllFiles -bool true
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Disable .DS_Store on network and USB
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
}

# Function to configure Dock
configure_dock() {
    echo "Configuring Dock..."

    defaults write com.apple.dock show-process-indicators -bool true
    defaults write com.apple.dock launchanim -bool false
    defaults write com.apple.dock autohide -bool false
    defaults write com.apple.dock showhidden -bool true
    defaults write com.apple.dock no-bouncing -bool true
    defaults write com.Apple.Dock show-recents -bool false
}

# Main function to run all configurations
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

    echo "Configuration complete! Some changes may require a restart to take effect."
}

# Run the script
main

# Restart affected applications
echo "Restarting affected applications..."
for app in "Finder" "Dock" "SystemUIServer"; do
    killall "${app}" &> /dev/null || true
done
