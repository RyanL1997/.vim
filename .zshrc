# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Enable zsh modules
autoload -Uz compinit && compinit
autoload -Uz promptinit && promptinit

# Initialize zinit
source ~/.local/share/zinit/zinit.git/zinit.zsh

# Plugins
zinit light zdharma-continuum/fast-syntax-highlighting
#zinit light zsh-users/zsh-autosuggestions
#zinit light zsh-users/zsh-completions
zinit ice atclone"./install --all" atpull"%atclone"
zinit light junegunn/fzf

# Theme (optional)
zinit light romkatv/powerlevel10k

# Dev deps

# PATH for Python packages
export PATH="/Users/jiallian/Library/Python/3.9/bin:$PATH"

# Java
export JAVA_HOME="/Library/Java/JavaVirtualMachines/amazon-corretto-11.jdk/Contents/Home"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Conda
__conda_setup="$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/anaconda3/etc/profile.d/conda.sh"
   else
        export PATH="/opt/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# Toolbox bin
export PATH=$PATH:$HOME/.toolbox/bin

# Aliases, exports, etc
export PATH="$HOME/bin:$PATH"
alias ll='ls -lah'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"
