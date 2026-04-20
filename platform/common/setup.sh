#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "==> Common setup"

# Install zinit
if [[ ! -d ~/.local/share/zinit/zinit.git ]]; then
  echo "==> Installing zinit..."
  mkdir -p ~/.local/share/zinit
  git clone https://github.com/zdharma-continuum/zinit.git ~/.local/share/zinit/zinit.git
fi

# Install nvm
if [[ ! -d "$HOME/.nvm" ]]; then
  echo "==> Installing nvm..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# Install pyenv
if ! command -v pyenv &>/dev/null; then
  echo "==> Installing pyenv..."
  curl https://pyenv.run | bash
fi

# Symlink .zshrc
echo "==> Symlinking .zshrc..."
if [[ -f ~/.zshrc && ! -L ~/.zshrc ]]; then
  mv ~/.zshrc ~/.zshrc.backup
  echo "    Backed up existing .zshrc to ~/.zshrc.backup"
fi
ln -sf "$REPO_DIR/.zshrc" ~/.zshrc

# Symlink ghostty config
if [[ -f "$REPO_DIR/ghostty/config" ]]; then
  echo "==> Symlinking ghostty config..."
  mkdir -p ~/.config/ghostty
  ln -sf "$REPO_DIR/ghostty/config" ~/.config/ghostty/config
fi

# Symlink tmux config (Linux/WSL only — for SSH cloud dev sessions)
if [[ "$OSTYPE" == linux* && -f "$REPO_DIR/.tmux.conf" ]]; then
  echo "==> Symlinking .tmux.conf..."
  ln -sf "$REPO_DIR/.tmux.conf" ~/.tmux.conf
fi

# Set zsh as default shell (if not already)
if [[ "$SHELL" != */zsh ]]; then
  ZSH_PATH=$(command -v zsh)
  if [[ -n "$ZSH_PATH" ]]; then
    echo "==> Setting zsh as default shell..."
    if grep -q "$ZSH_PATH" /etc/shells; then
      chsh -s "$ZSH_PATH"
    else
      echo "$ZSH_PATH" | sudo tee -a /etc/shells
      chsh -s "$ZSH_PATH"
    fi
  fi
fi

echo "==> Common setup complete"
echo "    Run 'exec zsh' or open a new terminal to start using the new config."
