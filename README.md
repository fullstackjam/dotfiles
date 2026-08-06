# Dotfiles

Pure configuration files managed with [GNU Stow](https://www.gnu.org/software/stow/).

Software installation is handled by [OpenBoot](https://openboot.dev).

## Quick Start

```bash
curl -fsSL openboot.dev/fullstackjam | bash
```

This will:
1. Install Homebrew and packages
2. Clone this repo to `~/.dotfiles`
3. Deploy configs via stow
4. Install Oh-My-Zsh and plugins

## Manual Deploy

```bash
git clone https://github.com/fullstackjam/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

## Global Agent Skills

`op-vault` is vendored in this repository at
`agents/.agents/skills/op-vault/`. Codex reads the deployed universal skill
directly, and Claude Code follows the relative symlink at
`claude/.claude/skills/op-vault`.

The vendored copy is deliberately updated only through a reviewed repository
change; it is not managed by an external installer or updated automatically.

## Structure

```
dotfiles/
├── Makefile                             # Install / uninstall entrypoint
├── git/.gitconfig                       # Git configuration
├── ssh/.ssh/config                      # SSH client config
├── zsh/.zshrc                           # Zsh configuration
├── agents/.agents/skills/op-vault/      # Shared global skill source
├── claude/.claude/CLAUDE.md             # → codex/.codex/AGENTS.md
├── claude/.claude/skills/op-vault       # → agents/.agents/skills/op-vault
├── claude/.claude/settings.json         # Claude Code settings
├── codex/.codex/AGENTS.md               # Global agent instructions
└── ghostty/.config/ghostty/config       # Ghostty terminal configuration
```

## How It Works

`make install` pre-creates the necessary directories, then deploys regular
configuration packages with `--no-folding` so each config file is symlinked
individually. The `agents` package deliberately allows folding so each complete
skill directory is a symlink, as required by compatible agent clients:

```
~/.gitconfig                    → ~/.dotfiles/git/.gitconfig
~/.ssh/config                   → ~/.dotfiles/ssh/.ssh/config
~/.zshrc                        → ~/.dotfiles/zsh/.zshrc
~/.claude/CLAUDE.md             → ~/.dotfiles/claude/.claude/CLAUDE.md
~/.claude/skills/op-vault       → ~/.dotfiles/claude/.claude/skills/op-vault
~/.claude/settings.json         → ~/.dotfiles/claude/.claude/settings.json
~/.agents/skills/op-vault/      → ~/.dotfiles/agents/.agents/skills/op-vault/
~/.codex/AGENTS.md              → ~/.dotfiles/codex/.codex/AGENTS.md
~/.config/ghostty/config        → ~/.dotfiles/ghostty/.config/ghostty/config
```

`codex/.codex/AGENTS.md` is the single source for global instructions, while
`agents/.agents/skills/op-vault/` is the single source for the shared skill.
Their Claude counterparts are relative symlinks to those files.

Runtime data (`~/.claude/sessions`, `~/.ssh/known_hosts`, etc.) lives in the
real directories and is never tracked.

## License

MIT
