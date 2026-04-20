# Kiro CLI pre block. Keep at the top of this file.
if [[ "$OSTYPE" == darwin* ]]; then
  [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"
else
  [[ -f "${HOME}/.config/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/.config/kiro-cli/shell/zshrc.pre.zsh"
fi

# -----------------------------------------------------------------------------
# Homebrew
# -----------------------------------------------------------------------------
if [[ "$OSTYPE" == darwin* ]]; then
  [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# -----------------------------------------------------------------------------
# Zsh completion system (omz-style: Tab menu, arrow keys, cached daily)
# -----------------------------------------------------------------------------
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'
zstyle ':completion:*:messages'     format '%F{purple}%d%f'
zstyle ':completion:*:warnings'     format '%F{red}no matches for: %d%f'

# -----------------------------------------------------------------------------
# Zinit
# -----------------------------------------------------------------------------
source ~/.local/share/zinit/zinit.git/zinit.zsh

# -----------------------------------------------------------------------------
# Prompt: hand-rolled (robbyrussell-inspired, pure zsh, no external deps)
# Docs: https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html
# -----------------------------------------------------------------------------
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '✗'
zstyle ':vcs_info:git:*' stagedstr  '+'

zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
+vi-git-untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == 'true' ]] && \
     git status --porcelain 2>/dev/null | grep -q '^??'; then
    hook_com[unstaged]+='?'
  fi
}

zstyle ':vcs_info:git:*' formats       ' %F{12}git:(%F{9}%b%F{12})%F{11}%u%c%f'
zstyle ':vcs_info:git:*' actionformats ' %F{12}git:(%F{9}%b|%a%F{12})%f'
precmd() { vcs_info }
setopt prompt_subst

PROMPT='%B%(?.%F{10}➜%f.%F{9}➜%f) %F{14}%c%f${vcs_info_msg_0_}%b '

# Plugins
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions

# omz git aliases (lightweight cherry-pick)
zinit snippet OMZP::git

# -----------------------------------------------------------------------------
# PATH & env
# -----------------------------------------------------------------------------
export PATH="$HOME/bin:$PATH"
export PATH="$PATH:$HOME/.toolbox/bin"

if [[ "$OSTYPE" == darwin* ]]; then
  export JAVA_HOME="/Library/Java/JavaVirtualMachines/amazon-corretto-21.jdk/Contents/Home"
elif [[ -d /usr/lib/jvm/amazon-corretto-21 ]]; then
  export JAVA_HOME="/usr/lib/jvm/amazon-corretto-21"
fi

# NVM (lazy-loaded: only initializes when you first call nvm/node/npm/npx)
export NVM_DIR="$HOME/.nvm"
lazy_load_nvm() {
  unset -f nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}
nvm()  { lazy_load_nvm; nvm "$@" }
node() { lazy_load_nvm; node "$@" }
npm()  { lazy_load_nvm; npm "$@" }
npx()  { lazy_load_nvm; npx "$@" }

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init -)"

# mise (for other tools beyond node/python)
command -v mise >/dev/null && eval "$(mise activate zsh)"

# AWS / Bedrock
export CLAUDE_MODEL_PROVIDER="bedrock"
export AWS_PROFILE="bedrock"
export AWS_REGION="us-west-2"

# Rust
export RUST_BACKTRACE=full

# Docker (Finch on macOS, standard socket on Linux)
if [[ "$OSTYPE" == darwin* ]]; then
  export DOCKER_HOST=unix:///Applications/Finch/lima/data/finch/sock/finch.sock
  export DOCKER_CONFIG=$HOME/.finch
fi

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
if [[ "$OSTYPE" == darwin* ]]; then
  alias ls='ls -G'
  alias ll='ls -lG'
  alias la='ls -laG'
  export LSCOLORS=ExFxBxDxCxegedabagacad
else
  alias ls='ls --color=auto'
  alias ll='ls -l --color=auto'
  alias la='ls -la --color=auto'
  command -v dircolors >/dev/null && eval "$(dircolors -b)"
fi
alias grep='grep --color=auto'

# Force a universally-supported TERM for SSH sessions (avoids garbled input
# when the remote host doesn't have ghostty/iterm2 terminfo installed)
ssh() { TERM=xterm-256color command ssh "$@" }

# -----------------------------------------------------------------------------
# fzf
# -----------------------------------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# -----------------------------------------------------------------------------
# Kiro integration
# -----------------------------------------------------------------------------
[[ "$TERM_PROGRAM" == "kiro" ]] && command -v kiro >/dev/null && . "$(kiro --locate-shell-integration-path zsh)"

# Kiro CLI post block. Keep at the bottom of this file.
if [[ "$OSTYPE" == darwin* ]]; then
  [[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
else
  [[ -f "${HOME}/.config/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/.config/kiro-cli/shell/zshrc.post.zsh"
fi
