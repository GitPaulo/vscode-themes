#!/usr/bin/env bash

set -e

echo "Building themes..."
node scripts/build-themes.js

echo "Cleaning up old packages..."
rm -f gitpaulo-vscode-themes-*.vsix

echo "Packaging extension..."
vsce package

echo "Uninstalling old extension..."
code --uninstall-extension GitPaulo.gitpaulo-vscode-themes || true

echo "Installing new extension..."
code --install-extension gitpaulo-vscode-themes-*.vsix

echo "✅ Done! Extension installed successfully."
