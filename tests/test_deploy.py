"""Exercise deployment against disposable homes, without credentials or network."""
from pathlib import Path
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest


SOURCE = Path(__file__).resolve().parents[1]


def snapshot(root):
    result = {}
    for path in root.rglob("*"):
        if ".git" in path.parts:
            continue
        relative = str(path.relative_to(root))
        if path.is_symlink():
            result[relative] = ("link", os.readlink(path))
        elif path.is_file():
            result[relative] = ("file", path.read_bytes(), path.stat().st_mtime_ns)
        else:
            result[relative] = ("dir",)
    return result


class DeployTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="dotfiles tests ")
        self.addCleanup(self.temp.cleanup)
        root = Path(self.temp.name).resolve()
        self.repo = root / "repo"
        self.repo.mkdir()
        for name in ["git", "ssh", "zsh", "codex", "ghostty", "zed", "scripts"]:
            shutil.copytree(SOURCE / name, self.repo / name, symlinks=True)
        subprocess.run(["git", "init", "--quiet", str(self.repo)], check=True)
        self.target = root / "home"
        self.target.mkdir()
        (self.repo / "agents/.agents").mkdir(parents=True)
        (self.repo / "agents/.agents/.skill-lock.json").write_text('{"version": 1}')
        (self.repo / "bin").mkdir()
        runner = self.repo / "bin/op"
        runner.write_text('#!/usr/bin/python3\nimport sys\nprint("available")\n')
        runner.chmod(0o755)
        for name in ["op-vault", "work-one", "work-two"]:
            folder = self.repo / "agents/.agents/skills" / name
            folder.mkdir(parents=True)
            (folder / "SKILL.md").write_text(f"---\nname: {name}\ndescription: A test skill\n---\n")

    def deploy(self, action, *extra, ok=True):
        result = subprocess.run([sys.executable, "-B", str(self.repo / "scripts/deploy.py"),
                                 "--target", str(self.target),
                                 *extra, action], capture_output=True, text=True)
        self.assertEqual(result.returncode == 0, ok, result.stdout + result.stderr)
        return result

    def test_install_repeat_check_and_uninstall_preserve_sources_and_state(self):
        source_before = snapshot(self.repo)
        self.deploy("install")
        self.assertFalse((self.target / ".agents").is_symlink())
        self.assertEqual(len(list((self.target / ".agents/skills").iterdir())), 3)
        self.assertEqual((self.target / ".codex/AGENTS.md").resolve(), self.repo / "codex/.codex/AGENTS.md")
        self.assertFalse((self.target / ".local/share/dotfiles/AGENTS.md").exists())
        self.assertFalse((self.target / ".claude").exists())
        state = self.target / ".agents/state/owned.json"
        state.parent.mkdir()
        state.write_text('{"keep": true}')
        user_skill = self.target / ".agents/skills/user-only"
        user_skill.mkdir()
        before_check = snapshot(self.target)
        self.deploy("check")
        self.assertEqual(before_check, snapshot(self.target))
        self.deploy("install")
        self.assertEqual(before_check, snapshot(self.target))
        self.deploy("uninstall")
        self.assertTrue(state.exists())
        self.assertTrue(user_skill.exists())
        self.assertFalse((self.target / ".gitconfig").is_symlink())
        self.assertFalse((self.target / ".codex/AGENTS.md").is_symlink())
        self.assertEqual(source_before, snapshot(self.repo))

    def extension(self):
        extra = self.repo.parent / "local extension"
        extra.mkdir()
        subprocess.run(["git", "init", "--quiet", str(extra)], check=True)
        (extra / "bin").mkdir()
        command = extra / "bin/tool"
        command.write_text('#!/bin/sh\nprintf "%s" available\n')
        command.chmod(0o755)
        (extra / "skills/team-only").mkdir(parents=True)
        (extra / "skills/team-only/SKILL.md").write_text("A private skill")
        (extra / "AGENTS.md").write_text("Private environment instructions")
        (extra / "config").write_text("[user]\n email = test@example.test\n")
        config = {"files": {".local/bin/tool": "bin/tool", ".config/git/local.conf": "config"},
                  "skills": "skills", "instructions": "AGENTS.md"}
        (extra / "deployment.json").write_text(json.dumps(config))
        return extra

    def test_extension_install_remember_refresh_and_detach(self):
        extra = self.extension()
        self.deploy("install", "--extra-source", str(extra))
        command = self.target / ".local/bin/tool"
        self.assertEqual(subprocess.check_output([str(command)], text=True), "available")
        self.assertEqual((self.target / ".agents/skills/team-only").resolve(), extra / "skills/team-only")
        entry = self.target / ".codex/AGENTS.md"
        self.assertEqual(entry.resolve(), self.target / ".local/share/dotfiles/AGENTS.md")
        self.assertIn((self.repo / "codex/.codex/AGENTS.md").read_text().strip(), entry.read_text())
        self.assertIn("Private environment instructions", entry.read_text())
        env = {**os.environ, "HOME": str(self.target), "GIT_CONFIG_NOSYSTEM": "1"}
        email = subprocess.check_output(["git", "config", "--global", "--includes", "user.email"], env=env, text=True)
        self.assertEqual(email.strip(), "test@example.test")
        before = snapshot(self.target)
        self.deploy("check")
        self.assertEqual(before, snapshot(self.target))
        self.deploy("install")
        self.assertEqual(before, snapshot(self.target))
        (extra / "AGENTS.md").write_text("Updated private instructions")
        self.deploy("install")
        self.assertIn("Updated private instructions", entry.read_text())
        self.deploy("install", "--without-extra")
        self.assertFalse(command.is_symlink())
        self.assertFalse((self.target / ".agents/skills/team-only").is_symlink())
        self.assertTrue((self.target / ".agents/skills/work-one").exists())
        self.assertEqual(entry.resolve(), self.repo / "codex/.codex/AGENTS.md")
        self.assertTrue((extra / "bin/tool").exists())
        self.assertFalse((self.target / ".local/share/dotfiles/AGENTS.md").exists())

    def test_extension_migrates_existing_managed_links(self):
        self.deploy("install")
        extra = self.extension()
        old = self.repo / "agents/.agents/skills/work-one"
        shutil.move(old, extra / "skills/work-one")
        # A formerly Stow-managed file was not recorded in the agent manifest.
        identity = self.repo / "git/.config/git/identity.conf"
        identity.parent.mkdir(parents=True, exist_ok=True)
        identity.write_text("[user]\n email = private@example.test\n")
        dest = self.target / ".config/git/identity.conf"
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.symlink_to(identity)
        shutil.move(identity, extra / "identity.conf")
        path = extra / "deployment.json"
        config = json.loads(path.read_text())
        config["files"][".config/git/identity.conf"] = "identity.conf"
        path.write_text(json.dumps(config))
        self.deploy("install", "--extra-source", str(extra))
        self.assertEqual((self.target / ".agents/skills/work-one").resolve(), extra / "skills/work-one")
        self.assertEqual(dest.resolve(), extra / "identity.conf")
        self.deploy("uninstall")
        self.assertFalse(dest.is_symlink())
        self.assertFalse((self.target / ".local/bin/tool").is_symlink())
        self.assertTrue((extra / "identity.conf").exists())

    def test_duplicate_extension_skill_writes_nothing(self):
        extra = self.extension()
        shutil.copytree(extra / "skills/team-only", extra / "skills/work-one")
        before = snapshot(self.target)
        self.deploy("install", "--extra-source", str(extra), ok=False)
        self.assertEqual(before, snapshot(self.target))

    def test_missing_saved_extension_writes_nothing(self):
        extra = self.extension()
        self.deploy("install", "--extra-source", str(extra))
        shutil.rmtree(extra)
        before = snapshot(self.target)
        self.deploy("install", ok=False)
        self.assertEqual(before, snapshot(self.target))
        self.deploy("install", "--without-extra")

    def test_migrate_existing_directory_link_and_agent_entries(self):
        (self.target / ".agents").symlink_to(self.repo / "agents/.agents")
        for rel, source in [(".codex/AGENTS.md", "codex/.codex/AGENTS.md")]:
            dest = self.target / rel
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.symlink_to(self.repo / source)
        before = snapshot(self.repo)
        self.deploy("check")
        self.assertTrue((self.target / ".agents").is_symlink())
        self.deploy("install")
        self.assertFalse((self.target / ".agents").is_symlink())
        self.assertTrue((self.target / ".agents/.skill-lock.json").is_file())
        self.assertEqual(before, snapshot(self.repo))

    def test_migrate_old_checkout_links_then_remove_old_checkout(self):
        old = self.repo.parent / "old-checkout"
        sources = {
            ".agents/skills/work-one": "agents/.agents/skills/work-one",
            ".config/dotfiles/work/git.conf": "git/.gitconfig",
            ".local/bin/work-run": "bin/op",
        }
        manifest = self.target / ".local/share/dotfiles/links.json"
        manifest.parent.mkdir(parents=True)
        links = {}
        for relative, source in sources.items():
            old_source = old / source
            old_source.parent.mkdir(parents=True, exist_ok=True)
            if (self.repo / source).is_dir():
                shutil.copytree(self.repo / source, old_source)
            else:
                shutil.copy2(self.repo / source, old_source)
            dest = self.target / relative
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.symlink_to(old_source)
            links[relative] = str(old_source)
        manifest.write_text(json.dumps(links))
        before = snapshot(self.target)
        self.deploy("check")
        self.assertEqual(before, snapshot(self.target))
        self.deploy("install")
        shutil.rmtree(old)
        for relative, source in sources.items():
            if relative.startswith(".config/dotfiles/work/") or relative == ".local/bin/work-run":
                self.assertFalse((self.target / relative).is_symlink())
            else:
                self.assertEqual((self.target / relative).resolve(), self.repo / source)
                self.assertTrue((self.target / relative).exists())
        self.deploy("check")

    def test_check_detects_staged_whitespace_without_writes(self):
        path = self.repo / "staged.txt"
        path.write_text("staged trailing space \n")
        subprocess.run(["git", "-C", str(self.repo), "add", "staged.txt"], check=True)
        before = snapshot(self.target)
        self.deploy("check", ok=False)
        self.assertEqual(before, snapshot(self.target))

    def test_unmanaged_entry_conflict_writes_nothing(self):
        dest = self.target / ".codex/AGENTS.md"
        dest.parent.mkdir()
        dest.write_text("user instructions")
        before = snapshot(self.target)
        self.deploy("install", ok=False)
        self.assertEqual(before, snapshot(self.target))

    def test_non_executable_extension_command_writes_nothing(self):
        before = snapshot(self.target)
        extra = self.extension()
        (extra / "bin/tool").chmod(0o644)
        self.deploy("install", "--extra-source", str(extra), ok=False)
        self.assertEqual(before, snapshot(self.target))

    def test_uninstall_preserves_replaced_user_file(self):
        self.deploy("install")
        path = self.target / ".codex/AGENTS.md"
        path.unlink()
        path.write_text("replacement")
        self.deploy("uninstall")
        self.assertEqual(path.read_text(), "replacement")

    def test_retire_managed_claude_links_preserves_user_data(self):
        self.deploy("install")
        manifest = self.target / ".local/share/dotfiles/links.json"
        links = json.loads(manifest.read_text())
        retired = {
            ".claude/CLAUDE.md": self.target / ".local/share/dotfiles/AGENTS.md",
            ".claude/skills/op-vault": self.target / ".agents/skills/op-vault",
        }
        for relative, source in retired.items():
            dest = self.target / relative
            dest.parent.mkdir(parents=True, exist_ok=True)
            dest.symlink_to(source)
            links[relative] = str(source)
        manifest.write_text(json.dumps(links))
        settings = self.target / ".claude/settings.json"
        settings.write_text('{"userOwned": true}')
        session = self.target / ".claude/projects/session.jsonl"
        session.parent.mkdir()
        session.write_text("user session\n")
        before = snapshot(self.target)
        self.deploy("check")
        self.assertEqual(before, snapshot(self.target))
        self.deploy("install")
        for relative in retired:
            self.assertFalse((self.target / relative).is_symlink())
        self.assertEqual(settings.read_text(), '{"userOwned": true}')
        self.assertEqual(session.read_text(), "user session\n")
        self.assertFalse(any(k.startswith(".claude/") for k in json.loads(manifest.read_text())))

    def test_migrate_generated_instructions_to_direct_source(self):
        self.deploy("install")
        generated = self.target / ".local/share/dotfiles/AGENTS.md"
        generated.write_text("<!-- Generated by make install; edit source repositories. -->\nold rules")
        entry = self.target / ".codex/AGENTS.md"
        entry.unlink()
        entry.symlink_to(generated)
        manifest = self.target / ".local/share/dotfiles/links.json"
        links = json.loads(manifest.read_text())
        links[".codex/AGENTS.md"] = str(generated)
        manifest.write_text(json.dumps(links))
        self.deploy("install")
        self.assertFalse(generated.exists())
        self.assertEqual(entry.resolve(), self.repo / "codex/.codex/AGENTS.md")

    def test_missing_instructions_writes_nothing(self):
        self.deploy("install")
        (self.repo / "codex/.codex/AGENTS.md").unlink()
        before = snapshot(self.target)
        self.deploy("install", ok=False)
        self.assertEqual(before, snapshot(self.target))

    def test_redirected_runtime_is_rejected(self):
        parent = self.target / ".local/share"
        parent.mkdir(parents=True)
        (parent / "dotfiles").symlink_to(self.repo)
        before = snapshot(self.repo)
        self.deploy("install", ok=False)
        self.assertEqual(before, snapshot(self.repo))


if __name__ == "__main__":
    unittest.main()
