# Prefer local CLI entries in interactive and non-interactive shells.
typeset -U path
path=("$HOME/.local/bin" "${path[@]}")
export PATH

# Optional local environment for both terminal and agent shells.
[[ ! -r "$HOME/.config/zsh/local.zshenv" ]] || source "$HOME/.config/zsh/local.zshenv"
