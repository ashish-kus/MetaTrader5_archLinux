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
info() { echo -e "${BLUE}ℹ  $*${RESET}"; }
success() { echo -e "${GREEN}✅ $*${RESET}"; }
error() { echo -e "${RED}❌ $*${RESET}"; }
warn() { echo -e "${YELLOW}⚠️  $*${RESET}"; }

# --- Define URLs ---
MT5_URL="https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe"
WEBVIEW2_URL="https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/c1336fd6-a2eb-4669-9b03-949fc70ace0e/MicrosoftEdgeWebview2Setup.exe"

# --- Check Internet Connection ---
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
  info "Installing required packages (wine-staging, winetricks, wget)..."
  if sudo pacman -S --noconfirm wine-staging winetricks wget figlet lolcat; then
    success "Dependencies installed successfully."
  else
    error "Failed to install dependencies."
    exit 1
  fi
}

# --- Setup Wine Environment ---
setup_wine() {
  info "Configuring Wine prefix..."
  export WINEPREFIX="$HOME/.mt5"
  wineboot
  winetricks -q settings win10
  success "Wine prefix is ready for MetaTrader 5."
}

# --- Download Installers ---
download_files() {
  info "Downloading MetaTrader 5 setup..."
  wget -q "$MT5_URL" -O "./mt5setup.exe" && success "✅ MT5 downloaded." || {
    error "Failed to download MT5."
    exit 1
  }

  info "Downloading WebView2 installer..."
  wget "$WEBVIEW2_URL" -O "./MicrosoftEdgeWebview2Setup.exe" && success "✅ WebView2 downloaded." || {
    error "Failed to download WebView2."
    exit 1
  }
}

# --- Install WebView2 (GUI installer) ---

install_webview() {
  info "Launching WebView2 installer (GUI)..."
  export WINEPREFIX="$HOME/.mt5"

  if [[ -f "./MicrosoftEdgeWebview2Setup.exe" ]]; then
    wine "./MicrosoftEdgeWebview2Setup.exe"
    success "WebView2 installer executed. Complete it in the GUI."
  else
    error "WebView2 installer not found. Please download it first."
    exit 1
  fi
}

# --- Install MetaTrader 5 (GUI installer) ---
install_mt5() {
  info "Launching MetaTrader 5 installer (GUI)..."
  WINEPREFIX="$HOME/.mt5" wine "./mt5setup.exe"
  success "MetaTrader 5 installer launched. Complete it in the GUI."
}

# --- Run the Script ---
check_network
install_dependencies
setup_wine
download_files
install_webview
install_mt5

success "MetaTrader 5 setup completed."
echo -e "\n${BLUE}➡️  To run MetaTrader 5 later, use:${RESET}"
echo -e "WINEPREFIX=\"\$HOME/.mt5\" wine \"\$HOME/.mt5/drive_c/Program Files/MetaTrader 5/terminal64.exe\""
