#!/usr/bin/env bash
# Linux setup — works on Debian/Ubuntu (apt), Amazon Linux 2 (yum), and similar.
# Designed to degrade gracefully: missing packages don't abort the install,
# and modern tools (fzf, ripgrep, neovim) fall back to GitHub releases when
# the distro repos don't carry them.

set -uo pipefail   # note: no `-e` — we handle failures per-package below

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Linux setup"

# --- detect package manager --------------------------------------------------
if command -v apt &>/dev/null; then
  PKG_MGR="apt"
elif command -v yum &>/dev/null; then
  PKG_MGR="yum"
else
  echo "Error: no supported package manager found (apt or yum)"
  exit 1
fi
echo "    Package manager: $PKG_MGR"

# --- detect architecture (for GitHub release fallbacks) ----------------------
ARCH_RAW="$(uname -m)"
case "$ARCH_RAW" in
  x86_64|amd64)   RG_ARCH="x86_64-unknown-linux-musl"; NVIM_ARCH="x86_64" ;;
  aarch64|arm64)  RG_ARCH="aarch64-unknown-linux-gnu"; NVIM_ARCH="arm64"  ;;
  *)              echo "Warning: unknown arch $ARCH_RAW — fallbacks may fail"
                  RG_ARCH="x86_64-unknown-linux-musl"; NVIM_ARCH="x86_64" ;;
esac

# --- install packages from packages.txt, one at a time (don't abort on miss) -
echo "==> Installing packages (missing ones are skipped; fallbacks run after)..."
mapfile -t PACKAGES < <(grep -v '^#' "$SCRIPT_DIR/packages.txt" | grep -v '^$')

[[ "$PKG_MGR" == "apt" ]] && sudo apt update -y
for pkg in "${PACKAGES[@]}"; do
  if [[ "$PKG_MGR" == "apt" ]]; then
    sudo apt install -y "$pkg" 2>/dev/null && echo "    [ok]  $pkg" || echo "    [skip] $pkg (not in repo)"
  else
    sudo yum install -y "$pkg" 2>/dev/null && echo "    [ok]  $pkg" || echo "    [skip] $pkg (not in repo)"
  fi
done

# --- pyenv build dependencies (needed later for `pyenv install <version>`) ---
echo "==> Installing pyenv build dependencies..."
if [[ "$PKG_MGR" == "apt" ]]; then
  sudo apt install -y \
    build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
    libffi-dev liblzma-dev 2>/dev/null || true
elif [[ "$PKG_MGR" == "yum" ]]; then
  sudo yum groupinstall -y "Development Tools" 2>/dev/null || true
  sudo yum install -y \
    gcc make zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel \
    openssl-devel xz xz-devel libffi-devel ncurses-devel 2>/dev/null || true
fi

# --- fzf fallback ------------------------------------------------------------
if ! command -v fzf &>/dev/null; then
  echo "==> Installing fzf from git..."
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
fi

# --- ripgrep fallback --------------------------------------------------------
if ! command -v rg &>/dev/null; then
  echo "==> Installing ripgrep ($ARCH_RAW) from GitHub release..."
  RG_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | grep tag_name | cut -d '"' -f 4)
  if [[ -z "$RG_VERSION" ]]; then
    echo "    [warn] could not fetch ripgrep version — skipping"
  else
    TARBALL="ripgrep-${RG_VERSION}-${RG_ARCH}.tar.gz"
    TMPDIR_RG="$(mktemp -d)"
    pushd "$TMPDIR_RG" >/dev/null
    if curl -fLO "https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/${TARBALL}"; then
      tar xzf "$TARBALL"
      sudo cp "ripgrep-${RG_VERSION}-${RG_ARCH}/rg" /usr/local/bin/ && echo "    [ok] rg installed"
    else
      echo "    [warn] ripgrep release download failed — skipping"
    fi
    popd >/dev/null
    rm -rf "$TMPDIR_RG"
  fi
fi

# --- neovim fallback ---------------------------------------------------------
if ! command -v nvim &>/dev/null; then
  echo "==> Installing neovim ($ARCH_RAW) from GitHub release..."
  TARBALL="nvim-linux-${NVIM_ARCH}.tar.gz"
  TMPDIR_NV="$(mktemp -d)"
  pushd "$TMPDIR_NV" >/dev/null
  if curl -fLO "https://github.com/neovim/neovim/releases/latest/download/${TARBALL}"; then
    sudo tar xzf "$TARBALL" -C /usr/local --strip-components=1 && echo "    [ok] nvim installed"
  else
    echo "    [warn] neovim release download failed — skipping"
  fi
  popd >/dev/null
  rm -rf "$TMPDIR_NV"
fi

echo "==> Linux setup complete"
