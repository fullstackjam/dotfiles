
# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

# macOS path_helper runs after .zshenv; restore the local CLI precedence.
source "$HOME/.zshenv"
