#!/usr/bin/env bash
# ============================================
#  Script Name : install_mt5_arch.sh
#  Description : Installs MetaTrader 5 with Wine on Arch Linux
#  Author      : Ashish Kushwaha
#  Date        : 2025-07-04
# ============================================

# --- Shell Safety ---
set -euo pipefail
IFS=$'\n\t'

# --- Color Output Functions ---
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"
info() { echo -e "${BLUE}\u2139  $*${RESET}"; }
success() { echo -e "${GREEN}\u2705 $*${RESET}"; }
error() { echo -e "${RED}\u274C $*${RESET}"; }
warn() { echo -e "${YELLOW}\u26A0  $*${RESET}"; }

# --- Define URLs ---
MT5_URL="https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe"
WEBVIEW2_URL="https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/c1336fd6-a2eb-4669-9b03-949fc70ace0e/MicrosoftEdgeWebview2Setup.exe"

# --- Root Check ---
check_sudo() {
  if [[ "$EUID" -ne 0 ]]; then
    error "This script must be run with sudo or as root."
    exit 1
  fi
  info "Running as root. Continuing..."
}

# --- Confirm Installation ---
confirm_installation() {
  read -p $'\nDo you want to install MetaTrader 5 on Arch Linux? [y/n]: ' confirm
  if [[ ! $confirm =~ ^[Yy]$ ]]; then
    warn "Installation cancelled by user."
    exit 0
  fi
}# --- Check Internet Connection ---
check_network() {
  info "Checking internet connectivity..."
  if ! ping -q -c 1 -W 2 archlinux.org &>/dev/null; then
    error "No internet connection detected. Exiting."
    exit 1
  fi
  success "Internet connection is active."
}

# --- Install Dependencies ---
install_dependencies() {
  info "Installing required packages..."
  info "Installing required wine-staging..."
  if sudo pacman -S --noconfirm wine-staging winetricks wget figlet lolcat; then
    success "Dependencies installed."
  else
    error "Failed to install dependencies."
    exit 1
  fi
}

# --- Setup Wine Environment ---
setup_wine() {
  info "Setting up Wine prefix for MetaTrader..."
  export WINEPREFIX="$HOME/.mt5"
  wineboot &>/dev/null &
  winetricks -q settings win10 &>/dev/null &
  success "Wine configured for Windows 10."
}

# --- Download Installers ---
download_files() {
  BUILD_DIR="./build"

  # Create the build directory if it doesn't exist
  mkdir -p "$BUILD_DIR"

  info "Downloading MetaTrader 5..."
  if wget -q "$MT5_URL" -O "$BUILD_DIR/mt5setup.exe"; then
    success "MT5 downloaded to $BUILD_DIR."
  else
    error "Failed to download MetaTrader 5."
    exit 1
  fi

  info "Downloading WebView2 Runtime..."
  if wget -q "$WEBVIEW2_URL" -O "$BUILD_DIR/MicrosoftEdgeWebview2Setup.exe"; then
    success "WebView2 downloaded to $BUILD_DIR."
  else
    error "Failed to download WebView2."
    exit 1
  fi
}

# --- Install WebView2 ---
install_webview() {
  info "Installing WebView2..."
  if WINEPREFIX="$HOME/.mt5" wine "$BUILD_DIR/MicrosoftEdgeWebview2Setup.exe" /silent /install &>/dev/null; then
    success "WebView2 installed."
  else
    warn "WebView2 installation might have failed. Proceeding anyway."
  fi
}

install_mt5() {
  info "Launching MetaTrader 5 Installer..."
  WINEPREFIX="$HOME/.mt5" wine "$BUILD_DIR/mt5setup.exe" &>/dev/null
  success "MetaTrader 5 setup launched. Complete the installation in the GUI window."
}



setup_dotDesktop(){
  wine_desktop="$HOME/.local/share/applications/wine/Programs/MetaTrader 5/MetaTrader 5.desktop"
  manual_desktop="$HOME/.local/share/applications/metatrader5.desktop"
  icon_source="./MetaTrader5.png"
  icon_target="$HOME/.local/share/icons/MetaTrader5.png"

  # --- Copy icon if needed ---
  if [[ -f "$icon_source" ]]; then
    mkdir -p "$(dirname "$icon_target")"
    cp "$icon_source" "$icon_target"
    success "Icon copied to: $icon_target"
  else
    warn "Icon not found: $icon_source. Default system icon will be used."
  fi

  # --- Create or Verify Desktop Entry ---
  if [[ -f "$wine_desktop" ]]; then
    success "Auto-generated desktop entry found at: $wine_desktop"
  elif [[ -f "$manual_desktop" ]]; then
    info "Manual desktop entry already exists at: $manual_desktop"
  else
    info "No desktop entry found. Creating one manually..."
    cat >"$manual_desktop" <<EOF
[Desktop Entry]
Name=MetaTrader 5
Comment=Launch MetaTrader 5 using Wine
Exec=env WINEPREFIX=$HOME/.mt5 wine "$HOME/.mt5/drive_c/Program Files/MetaTrader 5/terminal64.exe"
Icon=metatrader5
Terminal=false
Type=Application
Categories=Finance;Trading;Application;
StartupNotify=true
EOF

    chmod +x "$manual_desktop"
    success "Manual desktop launcher created: $manual_desktop"
  fi
}

# --- Run the Script ---
check_network
install_dependencies
setup_wine
download_files
install_webview
install_mt5
setup_dotDesktop


success "MetaTrader 5 installation script completed. You can launch MT5 from the Wine prefix:"
echo -e "\n${BLUE}Run: WINEPREFIX=\"$HOME/.mt5\" wine \"$HOME/.mt5/drive_c/Program Files/MetaTrader 5/terminal64.exe\"${RESET}"
