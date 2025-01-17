#!/bin/sh

# Check if "bat" binary exists, if not exit with error
if ! command -v bat >/dev/null; then
  echo "Error: 'bat' binary not found."
  exit 1
fi

# Create directory if it does not exist "$(bat --config-dir)/themes"
THEMES_DIR="$(bat --config-dir)/themes"
mkdir -p "$THEMES_DIR"

# Copy all .tmTheme files from current directory to "$(bat --config-dir)/themes"
cp ./*.tmTheme "$THEMES_DIR"

# Compile themes by running "bat cache --clean" followed by "bat cache --build"
bat cache --clear
bat cache --build
