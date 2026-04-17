# Kiro CLI pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.pre.zsh"

# -----------------------------------------------------------------------------
# zsh modules / options required by zinit + p10k
# -----------------------------------------------------------------------------
zmodload zsh/langinfo
zmodload zsh/system
setopt extended_glob ksh_glob
unsetopt sh_glob

# -----------------------------------------------------------------------------
# Homebrew (Apple Silicon)
# -----------------------------------------------------------------------------
eval "$(/opt/homebrew/bin/brew shellenv)"

# -----------------------------------------------------------------------------
# Zsh completion system (omz-style: Tab pops a selectable menu, arrow keys navigate)
# -----------------------------------------------------------------------------
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select                     # arrow-key menu after Tab
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case-insensitive match
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}  # colorize menu entries
zstyle ':completion:*' group-name ''                   # group results by type
zstyle ':completion:*:descriptions' format '%F{yellow}%d%f'          # omz uses non-bold headers
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

# Hook: also flag untracked files (vcs_info doesn't detect them natively).
# Appends `?` to the unstaged indicator when untracked files exist.
zstyle ':vcs_info:git*+set-message:*' hooks git-untracked
+vi-git-untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2>/dev/null) == 'true' ]] && \
     git status --porcelain 2>/dev/null | grep -q '^??'; then
    hook_com[unstaged]+='?'
  fi
}
# omz-style palette, bold + bright ANSI for high saturation
# Colors 9/10/11/12/14 are the bright variants of red/green/yellow/blue/cyan
zstyle ':vcs_info:git:*' formats       ' %F{12}git:(%F{9}%b%F{12})%F{11}%u%c%f'
zstyle ':vcs_info:git:*' actionformats ' %F{12}git:(%F{9}%b|%a%F{12})%f'
precmd() { vcs_info }
setopt prompt_subst

# Prompt: bold throughout; bright-green ➜ (bright-red on error), bright-cyan path
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
export PATH="/Users/jiallian/Library/Python/3.9/bin:$PATH"
export PATH="$PATH:$HOME/.toolbox/bin"

export JAVA_HOME="/Library/Java/JavaVirtualMachines/amazon-corretto-21.jdk/Contents/Home"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init -)"

# mise
eval "$(mise activate zsh)"

# AWS / Bedrock
export CLAUDE_MODEL_PROVIDER="bedrock"
export AWS_PROFILE="bedrock"
export AWS_REGION="us-west-2"

# Rust
export RUST_BACKTRACE=full

# Finch (Docker replacement)
export DOCKER_HOST=unix:///Applications/Finch/lima/data/finch/sock/finch.sock
export DOCKER_CONFIG=$HOME/.finch

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
alias ls='ls -G'
alias ll='ls -lG'
alias la='ls -laG'
alias grep='grep --color=auto'

# Force a universally-supported TERM for SSH sessions (avoids garbled input
# when the remote host doesn't have ghostty/iterm2 terminfo installed)
ssh() { TERM=xterm-256color command ssh "$@" }
export LSCOLORS=ExFxBxDxCxegedabagacad

# -----------------------------------------------------------------------------
# fzf (brew)
# -----------------------------------------------------------------------------
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# -----------------------------------------------------------------------------
# Kiro integration
# -----------------------------------------------------------------------------
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/kiro-cli/shell/zshrc.post.zsh"
