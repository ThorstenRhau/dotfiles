"""Exercise optional Git commands with real difftastic in a disposable repository."""

import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


@unittest.skipUnless(shutil.which("difft"), "difftastic is not installed")
class DifftasticTests(unittest.TestCase):
    def test_commands_redirected_and_paged(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-difftastic-") as directory:
            home = Path(directory)
            repo = home / "repo"
            repo.mkdir()
            env = {
                "PATH": os.environ["PATH"],
                "HOME": directory,
                "TERM": "xterm-256color",
                "GIT_CONFIG_NOSYSTEM": "1",
                "GIT_CONFIG_GLOBAL": str(ROOT / "git/.config/git/config"),
                "GIT_CONFIG_COUNT": "1",
                "GIT_CONFIG_KEY_0": "include.path",
                "GIT_CONFIG_VALUE_0": str(ROOT / "git/.config/git/difftastic.inc"),
            }

            def run(*args, **kwargs):
                return subprocess.run(
                    args, cwd=repo, env=env, capture_output=True,
                    timeout=15, check=True, **kwargs,
                ).stdout

            run("git", "init", "-q")
            # Import synthetic history without accessing signing or user credentials.
            history = b""
            for number in (1, 2):
                content = f"def answer():\n    return {number}\n".encode()
                history += (
                    f"commit refs/heads/main\n"
                    f"committer Fixture <fixture@example.invalid> {1700000000 + number} +0000\n"
                    f"data 8\nfixture\n\n"
                    f'M 100644 inline "file with spaces.py"\n'
                    f"data {len(content)}\n"
                ).encode() + content + b"\n"
            run("git", "fast-import", "--quiet", input=history)
            run("git", "symbolic-ref", "HEAD", "refs/heads/main")
            run("git", "checkout", "-q", "HEAD", "--", "file with spaces.py")
            (repo / "file with spaces.py").write_text("def answer():\n    return 3\n")

            self.assertEqual(run("git", "config", "--get", "core.pager").strip(), b"delta")
            self.assertEqual(
                run("git", "config", "--get", "interactive.diffFilter").strip(),
                b"delta --color-only",
            )
            for command in ("difft", "dshow", "dlog", "difftool -t difftastic"):
                with self.subTest(command=command):
                    args = ["git", *command.split(), "--", "file with spaces.py"]
                    plain = run(*args)
                    self.assertIn(b"file with spaces.py", plain)
                    self.assertIn(b"return", plain)
                    self.assertNotIn(b"\x1b[", plain)
                    self.assertNotIn(b"error:", plain)
                    # A real terminal lets Git activate the configured less pager.
                    paged = run(
                        "/usr/bin/script", "-q", "/dev/null", "/bin/sh", "-c",
                        'stty rows 40 cols 120; exec "$@"', "test", *args,
                        input=b"",
                    )
                    self.assertIn(b"file with spaces.py", paged)
                    self.assertIn(b"return", paged)
                    self.assertIn(b"\x1b[", paged)


if __name__ == "__main__":
    unittest.main()
