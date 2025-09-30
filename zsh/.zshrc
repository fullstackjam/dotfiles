# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="robbyrussell"

# Which plugins would you like to load?
plugins=(
  git
  kubectl
  helm
  pyenv
)

# Load zsh plugins manually (installed via Homebrew)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='nvim'
export VISUAL='nvim'

# Compilation flags (auto-detect architecture)
export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'
alias gd='git diff'

# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'

# Python aliases
alias py='python3'
alias pip='pip3'

# Custom functions
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Load pyenv (PATH setup is in .zprofile)
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# Load pyenv-virtualenv
if command -v pyenv-virtualenv-init 1>/dev/null 2>&1; then
  eval "$(pyenv virtualenv-init -)"
fi

# Load nvm
if [ -d "/opt/homebrew/opt/nvm" ]; then
  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
fi

# Additional useful exports
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history

# Proxy configuration
# export https_proxy=http://127.0.0.1:7897
# export http_proxy=http://127.0.0.1:7897
# export all_proxy=socks5://127.0.0.1:7897

# Enable history sharing between terminals
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
