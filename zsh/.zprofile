# Pyenv configuration
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"

# Homebrew configuration
eval "$(/opt/homebrew/bin/brew shellenv)"
