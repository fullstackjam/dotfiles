#!/usr/bin/env python3
"""Deploy personal configuration."""
from __future__ import annotations

import argparse
import ast
import json
import os
from pathlib import Path
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parents[1]
PACKAGES = ["git", "ssh", "zsh", "ghostty", "zed"]
INSTRUCTION_LINKS = (".codex/AGENTS.md", ".gemini/config/AGENTS.md")
SKILL_ROOTS = (".agents/skills", ".gemini/config/skills")


def run(*args):
    subprocess.run(args, cwd=ROOT, check=True)


def linked_to(path, source):
    return path.is_symlink() and Path(os.path.abspath(path.parent / os.readlink(path))) == source


def atomic_write(path, text):
    if path.exists() and not path.is_symlink() and path.read_text() == text:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(dir=path.parent, prefix=".dotfiles-")
    try:
        with os.fdopen(fd, "w") as stream:
            stream.write(text)
        os.replace(name, path)
    finally:
        if os.path.exists(name):
            os.unlink(name)


class Deployment:
    def __init__(self, target):
        self.target = target.resolve()
        self.runtime = self.target / ".local/share/dotfiles"
        self.manifest = self.runtime / "links.json"
        for path in [self.runtime, *self.runtime.parents]:
            if path == self.target:
                break
            if path.is_symlink() or (path.exists() and not path.is_dir()):
                raise ValueError(f"Expected a real runtime directory: {path}")
        if self.manifest.is_symlink():
            raise ValueError(f"Manifest must not be a symlink: {self.manifest}")
        self.old = json.loads(self.manifest.read_text()) if self.manifest.exists() else {}
        self.links = {}
        self.legacy = {
            ".codex/AGENTS.md": ROOT / "codex/.codex/AGENTS.md",
            ".config/git/identity.conf": ROOT / "git/.config/git/identity.conf",
        }
        self.agent_root = self.target / ".agents"
        self.migrate = linked_to(self.agent_root, ROOT / "agents/.agents")

    def prepare(self):
        if self.target.is_relative_to(ROOT):
            raise ValueError("Deployment target must be outside the source repository")
        instructions = ROOT / "agents/AGENTS.md"
        if not instructions.is_file():
            raise ValueError(f"Missing instructions: {instructions}")
        for relative in INSTRUCTION_LINKS:
            self.links[relative] = instructions
        skills = [skill for skill in sorted((ROOT / "agents/skills").iterdir())
                  if (skill / "SKILL.md").is_file()]
        for skill in skills:
            for root in SKILL_ROOTS:
                self.links[f"{root}/{skill.name}"] = skill
        self.skill_count = len(skills)
        self.preflight()

    def preflight(self):
        if self.migrate and self.agent_root.exists():
            extra = {p.name for p in self.agent_root.iterdir()} - {"skills", ".skill-lock.json", "AGENTS.md"}
            if extra:
                raise ValueError(f"Move existing agent runtime data out of the source first: {sorted(extra)}")
        # Refuse redirected runtime directories before reading/writing manifest files.
        paths = list(self.links) + list(self.old) + [".local/share/dotfiles/links.json"]
        for relative in paths:
            rel = Path(relative)
            if rel.is_absolute() or ".." in rel.parts or not rel.parts or relative == ".":
                raise ValueError(f"Invalid managed path: {relative}")
            dest = self.target / relative
            for parent in dest.parents:
                if parent == self.target:
                    break
                if self.migrate and (parent == self.agent_root or parent.is_relative_to(self.agent_root)):
                    continue
                if parent.is_symlink() or (parent.exists() and not parent.is_dir()):
                    raise ValueError(f"Expected a real directory: {parent}")
            if relative.startswith(".local/share/dotfiles/"):
                if dest.is_symlink():
                    raise ValueError(f"Runtime file must not be a symlink: {dest}")
                continue
            if not dest.exists() and not dest.is_symlink():
                continue
            if self.migrate and relative.startswith(".agents/skills/"):
                if dest.resolve() == self.links.get(relative):
                    continue
            owners = [self.links.get(relative), self.legacy.get(relative)]
            if relative in self.old:
                owners.append(Path(self.old[relative]))
            if not any(owner and linked_to(dest, owner) for owner in owners):
                raise ValueError(f"Refusing to replace an unmanaged path: {dest}")

    def stow(self, mode):
        run("stow", mode, "-v", "--no-folding",
            "--target=" + str(self.target), *PACKAGES)

    def check(self):
        self.prepare()
        for filename in [".zshenv", ".zprofile", ".zshrc"]:
            run("zsh", "-n", str(ROOT / "zsh" / filename))
        ast.parse(Path(__file__).read_text())
        subprocess.run(["git", "config", "--file", str(ROOT / "git/.gitconfig"), "--list"],
                       check=True, stdout=subprocess.DEVNULL)
        run("git", "diff", "--check")
        run("git", "diff", "--cached", "--check")
        self.stow("-n")
        print(f"CHECK PASS: {self.skill_count} skills; no files written")

    def cleanup_legacy_runtime(self):
        generated = self.runtime / "AGENTS.md"
        if generated.is_file() and not generated.is_symlink() and generated.read_text().startswith("<!-- Generated by make install;"):
            generated.unlink()
        sources = self.runtime / "sources.json"
        if sources.is_file() and not sources.is_symlink():
            sources.unlink()

    def install(self):
        self.check()
        if self.migrate:
            lock = self.agent_root / ".skill-lock.json"
            lock_text = lock.read_text() if lock.exists() else None
            self.agent_root.unlink()
            self.agent_root.mkdir()
            if lock_text is not None:
                atomic_write(self.agent_root / ".skill-lock.json", lock_text)
        self.runtime.mkdir(parents=True, exist_ok=True, mode=0o700)
        os.chmod(self.runtime, 0o700)
        # Complete desired links before removing obsolete ones; never delete source files.
        for relative, source in self.links.items():
            dest = self.target / relative
            if linked_to(dest, source):
                continue
            dest.parent.mkdir(parents=True, exist_ok=True)
            if dest.is_symlink():
                dest.unlink()
            dest.symlink_to(source)
        for relative, source in self.old.items():
            if relative not in self.links:
                dest = self.target / relative
                if linked_to(dest, Path(source)):
                    dest.unlink()
        self.cleanup_legacy_runtime()
        for relative in [".config/dotfiles/work", ".config/dotfiles"]:
            directory = self.target / relative
            if directory.is_dir() and not directory.is_symlink() and not any(directory.iterdir()):
                directory.rmdir()
        atomic_write(self.manifest, json.dumps({k: str(v) for k, v in self.links.items()}, indent=2) + "\n")
        self.stow("-S")
        for relative in self.links:
            if not (self.target / relative).exists():
                raise ValueError(f"Broken deployed link: {relative}")
        print(f"INSTALL PASS: {self.skill_count} skills; sources unchanged; runtime={self.runtime}")

    def uninstall(self):
        # Only unlink paths still owned by the saved manifest. Keep user additions and state.
        for relative, source in self.old.items():
            rel = Path(relative)
            if rel.is_absolute() or ".." in rel.parts:
                raise ValueError(f"Invalid managed path: {relative}")
            dest = self.target / rel
            if any(p.is_symlink() for p in dest.parents if p != self.target and p.is_relative_to(self.target)):
                raise ValueError(f"Refusing to unlink through a redirected directory: {dest}")
            if linked_to(dest, Path(source)):
                dest.unlink()
        self.stow("-D")
        if self.manifest.exists():
            self.manifest.unlink()
        self.cleanup_legacy_runtime()
        print("UNINSTALL PASS: managed links removed; source files and runtime data retained")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("action", choices=["check", "install", "uninstall"])
    parser.add_argument("--target", type=Path, default=Path.home())
    args = parser.parse_args()
    try:
        deployment = Deployment(args.target)
        getattr(deployment, args.action)()
    except (ValueError, OSError, subprocess.CalledProcessError) as exc:
        parser.exit(1, f"Deployment failed: {exc}\n")


if __name__ == "__main__":
    main()
