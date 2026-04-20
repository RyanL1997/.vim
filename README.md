# Dotfiles

Cross-platform zsh environment for macOS, Linux, and WSL.

## Quick Start

```bash
git clone https://github.com/RyanL1997/.vim.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
exec zsh
```

## What's Included

- **zsh** with [zinit](https://github.com/zdharma-continuum/zinit) — syntax highlighting, autosuggestions, completions, omz git aliases
- **Prompt** — hand-rolled single-line (`➜ dir git:(branch) ✗`), no external theme
- **Version managers** — [nvm](https://github.com/nvm-sh/nvm) (lazy-loaded), [pyenv](https://github.com/pyenv/pyenv), [mise](https://github.com/jdx/mise)
- **CLI tools** — fzf, ripgrep, jq, neovim, htop, yazi, zellij, gh
- **Terminal** — [Ghostty](https://ghostty.org/) config (Tokyo Night theme)
- **tmux** — starter config for Linux cloud dev sessions (`.tmux.conf`, symlinked on Linux only)

## Repo Structure

```text
.
├── install.sh                  # Entry point — detects OS, delegates
├── .zshrc                      # Cross-platform zsh config
├── .tmux.conf                  # tmux config (Linux only)
├── ghostty/config              # Ghostty terminal settings
├── platform/
│   ├── common/setup.sh         # Zinit, nvm, pyenv, symlinks
│   ├── mac/
│   │   ├── install.sh          # Homebrew + Brewfile
│   │   └── Brewfile
│   └── linux/
│       ├── install.sh          # apt/yum + GitHub release fallbacks
│       └── packages.txt
└── iterm2/                     # Legacy iTerm2 profiles
```

## Platform Support

- macOS (Apple Silicon / Intel) — Homebrew
- Ubuntu / Debian — apt
- Amazon Linux 2 — yum
- WSL2 — same as Linux

## Customization

**Prompt** — edit the `PROMPT=` line in `.zshrc`. Colors use bright ANSI codes (9-14). Reference: [zsh prompt expansion](https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html).

**Terminal theme** — edit `ghostty/config`. Run `ghostty +list-themes` to browse.

**Adding tools** — macOS: add to `platform/mac/Brewfile`. Linux: add to `platform/linux/packages.txt`.

## Post-Install

The installer sets up nvm and pyenv but does **not** install any Node or Python versions. Install what you need:

```bash
nvm install <version>           # e.g. nvm install 22
pyenv install <version>         # e.g. pyenv install 3.12
```

## Notes

- SSH sessions force `TERM=xterm-256color` to prevent garbled input on remote hosts without Ghostty's terminfo. See [Ghostty terminfo docs](https://ghostty.org/docs/help/terminfo).
- nvm is lazy-loaded for faster shell startup — it initializes on first `node`/`npm` call, not at shell open.
