#!/usr/bin/env bash
# ===================================================
# Script: install_mt5_arch.sh
# Description: Install MetaTrader 5 on Arch Linux using Wine
# Author: Ashish Kushwaha
# ===================================================

set -euo pipefail
IFS=$'\n\t'

# --- Output Colors ---
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"
info() { echo -e "${BLUE}[INFO] $*${RESET}"; }
success() { echo -e "${GREEN}[OK]   $*${RESET}"; }
warn() { echo -e "${YELLOW}[WARN] $*${RESET}"; }
error() {
  echo -e "${RED}[ERR]  $*${RESET}"
  exit 1
}

# --- URLs ---
MT5_URL="https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe"
WEBVIEW2_URL="https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/c1336fd6-a2eb-4669-9b03-949fc70ace0e/MicrosoftEdgeWebview2Setup.exe"

# --- Create working directory ---
BUILD_DIR="$HOME/.mt5_install"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# --- Install Dependencies ---
info "Installing dependencies (wine-staging, winetricks, multilib)..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm wine-staging winetricks wget cabextract lib32-alsa-plugins lib32-libpulse

# --- Configure Wine Prefix (64-bit) ---
export WINEPREFIX="$HOME/.mt5"
export WINEARCH=win64

info "Creating clean 64-bit Wine prefix..."
rm -rf "$WINEPREFIX"
wineboot &>/dev/null
winetricks -q settings win10
success "Wine prefix configured for Windows 10 (64-bit)."

# --- Download MT5 and WebView2 installers ---
info "Downloading MetaTrader 5..."
wget -q "$MT5_URL" -O "$BUILD_DIR/mt5setup.exe"
success "MT5 downloaded."

info "Downloading WebView2..."
wget -q "$WEBVIEW2_URL" -O "$BUILD_DIR/MicrosoftEdgeWebview2Setup.exe"
success "WebView2 downloaded."

# --- Install WebView2 ---
info "Installing WebView2..."
if wine "$BUILD_DIR/MicrosoftEdgeWebview2Setup.exe" /silent /install; then
  success "WebView2 installed successfully."
else
  warn "WebView2 installation may have failed. Consider checking manually."
fi

# --- Launch MT5 Installer ---
info "Launching MetaTrader 5 installer..."
wine "$BUILD_DIR/mt5setup.exe"

success "MetaTrader 5 installation script completed!"
echo -e "${BLUE}To run it in future:\nWINEPREFIX=\"$HOME/.mt5\" wine \"$HOME/.mt5/drive_c/Program Files/MetaTrader 5/terminal64.exe\"${RESET}"
