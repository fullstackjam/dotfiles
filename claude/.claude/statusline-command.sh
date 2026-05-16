#!/usr/bin/env bash
# Claude Code statusLine — robbyrussell-style
# Receives JSON on stdin from Claude Code

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir=$(basename "$cwd")

# Git branch via worktree field first, then fallback to git CLI
branch=$(echo "$input" | jq -r '.worktree.branch // .workspace.git_worktree // empty')
if [ -z "$branch" ]; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null || true)
fi

# Context usage
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Model
model=$(echo "$input" | jq -r '.model.display_name // .model.id // empty')

# ANSI colors (will be dimmed by Claude Code)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
RESET='\033[0m'

# Arrow + dir (robbyrussell style)
printf "${GREEN}➜${RESET}  ${CYAN}%s${RESET}" "$dir"

# Git branch
if [ -n "$branch" ]; then
  # Dirty check
  dirty=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | head -1)
  if [ -n "$dirty" ]; then
    printf " ${BLUE}git:(${RED}%s${BLUE})${RESET} ${RED}✗${RESET}" "$branch"
  else
    printf " ${BLUE}git:(${RED}%s${BLUE})${RESET}" "$branch"
  fi
fi

# Model
if [ -n "$model" ]; then
  printf " ${MAGENTA}[%s]${RESET}" "$model"
fi

# Context window usage
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct")
  if [ "$used_int" -ge 80 ]; then
    printf " ${RED}ctx:%d%%${RESET}" "$used_int"
  elif [ "$used_int" -ge 50 ]; then
    printf " ${YELLOW}ctx:%d%%${RESET}" "$used_int"
  else
    printf " ctx:%d%%" "$used_int"
  fi
fi

printf '\n'
