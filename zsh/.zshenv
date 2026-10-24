# Prefer local CLI entries in interactive and non-interactive shells.
typeset -U path
path=("$HOME/.local/bin" "${path[@]}")
export PATH
