#!/usr/bin/env bash

# --- Define URLs ---
MT5_URL="https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe"
WEBVIEW2_URL="https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/c1336fd6-a2eb-4669-9b03-949fc70ace0e/MicrosoftEdgeWebview2Setup.exe"

sudo pacman -S --noconfirm wine-staging wine-gecko wine-mono winetricks wget figlet lolcat

setup_wine() {
  export WINEPREFIX="$HOME/.mt5"
  wineboot &>/dev/null &
  winetricks -q settings win10 &>/dev/null &
}

setup_wine
wget -q "$MT5_URL" -O "./mt5setup.exe"
wget -q "$WEBVIEW2_URL" -O "./MicrosoftEdgeWebview2Setup.exe"

WINEPREFIX="$HOME/.mt5" wine "./MicrosoftEdgeWebview2Setup.exe" /silent /install
WINEPREFIX="$HOME/.mt5" wine "./mt5setup.exe" &>/dev/null
