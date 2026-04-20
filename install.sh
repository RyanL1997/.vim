#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=============================="
echo "  Dotfiles Setup"
echo "=============================="

# Detect platform
case "$OSTYPE" in
  darwin*)
    echo "Platform: macOS"
    bash "$REPO_DIR/platform/mac/install.sh"
    ;;
  linux*)
    echo "Platform: Linux"
    bash "$REPO_DIR/platform/linux/install.sh"
    ;;
  *)
    echo "Error: unsupported platform: $OSTYPE"
    exit 1
    ;;
esac

# Run common setup (zinit, nvm, pyenv, symlinks)
bash "$REPO_DIR/platform/common/setup.sh"

echo ""
echo "=============================="
echo "  Setup complete!"
echo "=============================="
echo ""
echo "Next steps:"
echo "  1. Run 'exec zsh' to reload your shell"
echo "  2. Install a Node version:  nvm install 22"
echo "  3. Install a Python version: pyenv install 3.12"
echo ""
