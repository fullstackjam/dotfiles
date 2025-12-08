#!/bin/bash
# 04-configure-macos.sh - Apply custom macOS preferences (Dock, Trackpad, Login Items)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

print_header "Configuring macOS preferences"

if ! is_macos; then
    print_error "macOS preferences can only be configured on macOS."
    exit 1
fi

# -----------------------------
# Dock configuration
# -----------------------------
print_info "Configuring Dock..."
defaults write com.apple.dock autohide -bool false
defaults write com.apple.dock "show-recents" -bool false
defaults write com.apple.dock tilesize -int 38

# Set Dock apps
print_info "Configuring Dock apps..."
defaults delete com.apple.dock persistent-apps 2>/dev/null || true

DOCK_APPS=(
    "/Applications/Microsoft Edge.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/Antigravity.app"
    "/Applications/Warp.app"
    "/Applications/ChatGPT.app"
)

for app in "${DOCK_APPS[@]}"; do
    if [ -d "$app" ]; then
        defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
    else
        print_warning "App not found: $app"
    fi
done

# -----------------------------
# Desktop & Stage Manager configuration
# -----------------------------
print_info "Configuring Desktop & Stage Manager..."
# Show Desktop: Only in Stage Manager on Click
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# Restart Dock to apply changes
killall Dock >/dev/null 2>&1 || true

# -----------------------------
# Trackpad configuration
# -----------------------------
print_info "Configuring Trackpad gestures..."
TRACKPAD_SETTINGS=(
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:Clicking:1"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:DragLock:0"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:Dragging:0"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadCornerSecondaryClick:0"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadFiveFingerPinchGesture:2"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadFourFingerHorizSwipeGesture:2"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadFourFingerPinchGesture:2"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadFourFingerVertSwipeGesture:2"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadHandResting:1"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadHorizScroll:1"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadMomentumScroll:1"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadPinch:1"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadRightClick:1"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadRotate:1"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadScroll:1"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadThreeFingerDrag:0"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadThreeFingerHorizSwipeGesture:2"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadThreeFingerTapGesture:0"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadThreeFingerVertSwipeGesture:2"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadTwoFingerDoubleTapGesture:1"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:TrackpadTwoFingerFromRightEdgeSwipeGesture:3"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:USBMouseStopsTrackpad:0"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:UserPreferences:1"
    "com.apple.driver.AppleBluetoothMultitouch.trackpad:version:5"
    "com.apple.AppleMultitouchTrackpad:ActuateDetents:1"
    "com.apple.AppleMultitouchTrackpad:Clicking:1"
    "com.apple.AppleMultitouchTrackpad:DragLock:0"
    "com.apple.AppleMultitouchTrackpad:Dragging:0"
    "com.apple.AppleMultitouchTrackpad:FirstClickThreshold:1"
    "com.apple.AppleMultitouchTrackpad:ForceSuppressed:0"
    "com.apple.AppleMultitouchTrackpad:SecondClickThreshold:1"
    "com.apple.AppleMultitouchTrackpad:TrackpadCornerSecondaryClick:0"
    "com.apple.AppleMultitouchTrackpad:TrackpadFiveFingerPinchGesture:2"
    "com.apple.AppleMultitouchTrackpad:TrackpadFourFingerHorizSwipeGesture:2"
    "com.apple.AppleMultitouchTrackpad:TrackpadFourFingerPinchGesture:2"
    "com.apple.AppleMultitouchTrackpad:TrackpadFourFingerVertSwipeGesture:2"
    "com.apple.AppleMultitouchTrackpad:TrackpadHandResting:1"
    "com.apple.AppleMultitouchTrackpad:TrackpadHorizScroll:1"
    "com.apple.AppleMultitouchTrackpad:TrackpadMomentumScroll:1"
    "com.apple.AppleMultitouchTrackpad:TrackpadPinch:1"
    "com.apple.AppleMultitouchTrackpad:TrackpadRightClick:1"
    "com.apple.AppleMultitouchTrackpad:TrackpadRotate:1"
    "com.apple.AppleMultitouchTrackpad:TrackpadScroll:1"
    "com.apple.AppleMultitouchTrackpad:TrackpadThreeFingerDrag:0"
    "com.apple.AppleMultitouchTrackpad:TrackpadThreeFingerHorizSwipeGesture:2"
    "com.apple.AppleMultitouchTrackpad:TrackpadThreeFingerTapGesture:0"
    "com.apple.AppleMultitouchTrackpad:TrackpadThreeFingerVertSwipeGesture:2"
    "com.apple.AppleMultitouchTrackpad:TrackpadTwoFingerDoubleTapGesture:1"
    "com.apple.AppleMultitouchTrackpad:TrackpadTwoFingerFromRightEdgeSwipeGesture:3"
    "com.apple.AppleMultitouchTrackpad:USBMouseStopsTrackpad:0"
    "com.apple.AppleMultitouchTrackpad:UserPreferences:1"
    "com.apple.AppleMultitouchTrackpad:version:12"
)

for entry in "${TRACKPAD_SETTINGS[@]}"; do
    domain="${entry%%:*}"
    remainder="${entry#*:}"
    key="${remainder%%:*}"
    value="${remainder##*:}"
    defaults write "$domain" "$key" -int "$value"
done

# -----------------------------
# Login items
# -----------------------------
print_info "Configuring login items..."
LOGIN_ITEMS=(
    "Scroll Reverser:/Applications/Scroll Reverser.app:false"
    "Maccy:/Applications/Maccy.app:false"
    "BetterDisplay:/Applications/BetterDisplay.app:false"
)

for item in "${LOGIN_ITEMS[@]}"; do
    IFS=":" read -r name path hidden <<<"$item"
    if [ ! -d "$path" ]; then
        print_warning "Login item '$name' expected at '$path' but was not found"
    fi
done

osascript <<'OSA'
tell application "System Events"
    set desiredItems to {¬
        {name:"Scroll Reverser", path:"/Applications/Scroll Reverser.app", hidden:false}, ¬
        {name:"Maccy", path:"/Applications/Maccy.app", hidden:false}, ¬
        {name:"BetterDisplay", path:"/Applications/BetterDisplay.app", hidden:false}}
    repeat with itemProps in desiredItems
        set itemName to name of itemProps
        if exists login item itemName then delete login item itemName
    end repeat
    repeat with itemProps in desiredItems
        make new login item with properties itemProps
    end repeat
end tell
OSA

print_success "macOS preferences configured!"
