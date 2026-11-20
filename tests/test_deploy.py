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
        for name in ["git", "ssh", "zsh", "ghostty", "zed", "scripts"]:
            shutil.copytree(SOURCE / name, self.repo / name, symlinks=True)
        subprocess.run(["git", "init", "--quiet", str(self.repo)], check=True)
        self.target = root / "home"
        self.target.mkdir()
        (self.repo / "agents").mkdir(parents=True)
        shutil.copy2(SOURCE / "agents/AGENTS.md", self.repo / "agents/AGENTS.md")
        (self.repo / "bin").mkdir()
        runner = self.repo / "bin/op"
        runner.write_text('#!/usr/bin/python3\nimport sys\nprint("available")\n')
        runner.chmod(0o755)
        for name in ["op-vault", "work-one", "work-two"]:
            folder = self.repo / "agents/skills" / name
            folder.mkdir(parents=True)
            (folder / "SKILL.md").write_text(f"---\nname: {name}\ndescription: A test skill\n---\n")

    def deploy(self, action, ok=True):
        result = subprocess.run([sys.executable, "-B", str(self.repo / "scripts/deploy.py"),
                                 "--target", str(self.target), action],
                                capture_output=True, text=True)
        self.assertEqual(result.returncode == 0, ok, result.stdout + result.stderr)
        return result

    def test_install_repeat_check_and_uninstall_preserve_sources_and_state(self):
        source_before = snapshot(self.repo)
        self.deploy("install")
        self.assertFalse((self.target / ".agents").is_symlink())
        self.assertEqual(len(list((self.target / ".agents/skills").iterdir())), 3)
        self.assertEqual(len(list((self.target / ".gemini/config/skills").iterdir())), 3)
        self.assertEqual((self.target / ".codex/AGENTS.md").resolve(), self.repo / "agents/AGENTS.md")
        self.assertEqual((self.target / ".gemini/config/AGENTS.md").resolve(), self.repo / "agents/AGENTS.md")
        self.assertFalse((self.target / ".local/share/dotfiles/AGENTS.md").exists())
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
        self.assertFalse((self.target / ".gemini/config/AGENTS.md").is_symlink())
        self.assertEqual(source_before, snapshot(self.repo))

    def test_migrate_existing_directory_link_and_agent_entries(self):
        legacy_agents = self.repo / "agents/.agents"
        legacy_agents.mkdir(parents=True)
        (legacy_agents / ".skill-lock.json").write_text('{"version": 1}')
        (self.target / ".agents").symlink_to(legacy_agents)
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
            ".agents/skills/work-one": "agents/skills/work-one",
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

    def test_uninstall_preserves_replaced_user_file(self):
        self.deploy("install")
        path = self.target / ".codex/AGENTS.md"
        path.unlink()
        path.write_text("replacement")
        self.deploy("uninstall")
        self.assertEqual(path.read_text(), "replacement")

    def test_migrate_generated_instructions_to_direct_source(self):
        self.deploy("install")
        generated = self.target / ".local/share/dotfiles/AGENTS.md"
        generated.write_text("<!-- Generated by make install; edit source repositories. -->\nold rules")
        sources = self.target / ".local/share/dotfiles/sources.json"
        sources.write_text("{}\n")
        entry = self.target / ".codex/AGENTS.md"
        entry.unlink()
        entry.symlink_to(generated)
        manifest = self.target / ".local/share/dotfiles/links.json"
        links = json.loads(manifest.read_text())
        links[".codex/AGENTS.md"] = str(generated)
        manifest.write_text(json.dumps(links))
        self.deploy("install")
        self.assertFalse(generated.exists())
        self.assertFalse(sources.exists())
        self.assertEqual(entry.resolve(), self.repo / "agents/AGENTS.md")

    def test_missing_instructions_writes_nothing(self):
        self.deploy("install")
        (self.repo / "agents/AGENTS.md").unlink()
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
