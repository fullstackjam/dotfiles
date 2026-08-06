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

The complete global agent directory lives at `agents/.agents/` and is deployed
as the directory-level symlink `~/.agents -> ~/.dotfiles/agents/.agents`.
Installing, updating, or removing a skill through `~/.agents` therefore changes
the repository copy directly, while repository changes are immediately visible
to compatible agents.

Codex reads this canonical directory directly. Claude Code keeps its own
`~/.claude/skills` directory and receives a per-skill symlink to the canonical
copy, which preserves Claude-only skills while avoiding duplicate files.

Install a global skill for both agents directly with the standard CLI:

```bash
npx skills add <source> --global --agent claude-code --agent codex
npx skills add <source> --skill <skill-name> --global --agent claude-code --agent codex --yes
```

Symlinking is the CLI default; do not pass `--copy` when one shared copy is
desired.

## Structure

```
dotfiles/
├── Makefile                             # Install / uninstall entrypoint
├── git/.gitconfig                       # Git configuration
├── ssh/.ssh/config                      # SSH client config
├── zsh/.zshrc                           # Zsh configuration
├── agents/.agents/skills/               # Canonical shared global skills
├── claude/.claude/CLAUDE.md             # → codex/.codex/AGENTS.md
├── claude/.claude/skills/                # Per-skill links to shared skills
├── claude/.claude/settings.json         # Claude Code settings
├── codex/.codex/AGENTS.md               # Global agent instructions
└── ghostty/.config/ghostty/config       # Ghostty terminal configuration
```

## How It Works

`make install` pre-creates the necessary non-agent directories, then deploys
regular configuration packages with `--no-folding` so each config file is
symlinked individually. The `agents` package deliberately allows folding so the
complete global agent directory is one symlink:

```
~/.gitconfig                    → ~/.dotfiles/git/.gitconfig
~/.ssh/config                   → ~/.dotfiles/ssh/.ssh/config
~/.zshrc                        → ~/.dotfiles/zsh/.zshrc
~/.claude/CLAUDE.md             → ~/.dotfiles/claude/.claude/CLAUDE.md
~/.claude/skills/<name>         → ~/.agents/skills/<name>
~/.claude/settings.json         → ~/.dotfiles/claude/.claude/settings.json
~/.agents/                      → ~/.dotfiles/agents/.agents/
~/.codex/AGENTS.md              → ~/.dotfiles/codex/.codex/AGENTS.md
~/.config/ghostty/config        → ~/.dotfiles/ghostty/.config/ghostty/config
```

`codex/.codex/AGENTS.md` is the single source for global instructions, while
`agents/.agents/` is the single source for shared global agent skills and their
package metadata. Claude entries are relative symlinks to those canonical
skills.

Runtime data (`~/.claude/sessions`, `~/.ssh/known_hosts`, etc.) lives in the
real directories and is never tracked.

## License

MIT
