#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Linux setup"

# Detect package manager
if command -v apt &>/dev/null; then
  PKG_MGR="apt"
elif command -v yum &>/dev/null; then
  PKG_MGR="yum"
else
  echo "Error: no supported package manager found (apt or yum)"
  exit 1
fi

# Install packages from packages.txt
echo "==> Installing packages via $PKG_MGR..."
PACKAGES=$(grep -v '^#' "$SCRIPT_DIR/packages.txt" | grep -v '^$' | tr '\n' ' ')

if [[ "$PKG_MGR" == "apt" ]]; then
  sudo apt update -y
  sudo apt install -y $PACKAGES
elif [[ "$PKG_MGR" == "yum" ]]; then
  sudo yum install -y $PACKAGES
fi

# Install tools not available in standard repos via official methods

# fzf (if not available from package manager or too old)
if ! command -v fzf &>/dev/null; then
  echo "==> Installing fzf from git..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
fi

# ripgrep (if not available from package manager)
if ! command -v rg &>/dev/null; then
  echo "==> Installing ripgrep from GitHub release..."
  RG_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep tag_name | cut -d '"' -f 4)
  curl -LO "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz"
  tar xzf "ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz"
  sudo cp "ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl/rg" /usr/local/bin/
  rm -rf "ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl" "ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz"
fi

# neovim (if not available or too old)
if ! command -v nvim &>/dev/null; then
  echo "==> Installing neovim from GitHub release..."
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
  sudo tar xzf nvim-linux-x86_64.tar.gz -C /usr/local --strip-components=1
  rm -f nvim-linux-x86_64.tar.gz
fi

echo "==> Linux setup complete"
