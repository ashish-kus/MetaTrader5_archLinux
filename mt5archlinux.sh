#!/usr/bin/env bash
# ============================================
#  Script Name : install_mt5_arch.sh
#  Description : Installs MetaTrader 5 with Wine on Arch Linux
#  Author      : Ashish Kushwaha
#  Date        : 2025-07-05
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

# --- Variables ---
INSTALLER_URL="https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe"
WINEPREFIX_PATH="$HOME/.wine_mt5"
INSTALLER_NAME="mt5setup.exe"

# --- Functions ---
check_network() {
  info "Checking internet connectivity..."
  if ! ping -q -c 1 -W 2 archlinux.org &>/dev/null; then
    error "No internet connection detected. Exiting."
    exit 1
  fi
  success "Internet connection is active."
}

install_dependencies() {
  info "Installing required packages..."
  if ! command -v wine &>/dev/null; then
    sudo pacman -Syu --noconfirm wine-staging winetricks wine-gecko wget figlet lolcat
    success "All dependencies installed."
  else
    success "Dependencies already installed."
  fi
}

setup_wine() {
  if [ ! -d "$WINEPREFIX_PATH" ]; then
    info "Creating Wine prefix at: $WINEPREFIX_PATH"
    mkdir -p "$WINEPREFIX_PATH"
    WINEPREFIX="$WINEPREFIX_PATH" wineboot &>/dev/null
    success "Wine prefix initialized."
  else
    success "Wine prefix already exists at: $WINEPREFIX_PATH"
  fi
}

download_installer() {
  if [ ! -f "$INSTALLER_NAME" ]; then
    info "Downloading MetaTrader 5 installer..."
    wget --show-progress -O "$INSTALLER_NAME" "$INSTALLER_URL"
    success "Installer downloaded: $INSTALLER_NAME"
  else
    warn "Installer already exists: $INSTALLER_NAME (skipping download)"
  fi
}

launch_installer() {
  info "Launching MetaTrader 5 installer..."
  WINEPREFIX="$WINEPREFIX_PATH" wine "$INSTALLER_NAME"
  success "Installer executed. Follow the on-screen instructions."
}

# --- Main Execution ---
check_network
install_dependencies
setup_wine
download_installer
launch_installer

success "MetaTrader 5 installation script completed!"
