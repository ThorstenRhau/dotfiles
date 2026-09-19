"""Check merge-driver availability and conflicts in a disposable repository."""

import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class MergirafTests(unittest.TestCase):
    def test_available_driver_and_missing_executable_fallback(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-mergiraf-") as directory:
            home = Path(directory)
            bin_dir = home / "bin"
            bin_dir.mkdir()
            # Git remains available; the host's Mergiraf is outside this PATH.
            git = shutil.which("git")
            (bin_dir / "git").symlink_to(git)
            env = {
                "HOME": directory,
                "PATH": str(bin_dir),
                "GIT_CONFIG_NOSYSTEM": "1",
                "GIT_CONFIG_GLOBAL": str(ROOT / "git/.config/git/config"),
                "GIT_CONFIG_COUNT": "1",
                "GIT_CONFIG_KEY_0": "core.attributesFile",
                "GIT_CONFIG_VALUE_0": str(ROOT / "git/.config/git/attributes"),
            }

            def run(*args, check=True, **kwargs):
                return subprocess.run(
                    [git, *args], cwd=home, env=env, capture_output=True,
                    timeout=10, check=check, **kwargs,
                )

            run("init", "-q")
            filename = "file with spaces.txt"
            (home / ".git/info/attributes").write_text(
                f'"{filename}" conflict-marker-size=9\n'
            )
            # Synthetic history avoids personal identity, hooks, and signing.
            history = b""
            for number, (branch, content) in enumerate([
                ("base", b"first\nmiddle\nlast\n"),
                ("ours", b"FIRST\nmiddle\nlast\n"),
                ("theirs", b"first\nmiddle\nLAST\n"),
                ("conflict", b"OTHER\nmiddle\nlast\n"),
            ], start=1):
                history += (
                    f"commit refs/heads/{branch}\nmark :{number}\n"
                    f"committer Fixture <fixture@example.invalid> {1700000000 + number} +0000\n"
                    "data 8\nfixture\n"
                ).encode()
                if number != 1:
                    history += b"from :1\n"
                history += (
                    f'M 100644 inline "{filename}"\ndata {len(content)}\n'
                ).encode() + content + b"\n"
            run("fast-import", "--quiet", input=history)

            for branch, expected_status in [("theirs", 0), ("conflict", 1)]:
                with self.subTest(missing=True, branch=branch):
                    result = run("merge-tree", "--write-tree", "ours", branch, check=False)
                    self.assertEqual(result.returncode, expected_status, result.stderr)
                    tree = result.stdout.splitlines()[0].decode()
                    merged = run("show", f"{tree}:{filename}").stdout
                    if branch == "theirs":
                        self.assertEqual(merged, b"FIRST\nmiddle\nLAST\n")
                    else:
                        self.assertIn(b"<<<<<<<<< ours\nFIRST\n", merged)
                        self.assertIn(b"||||||||| ", merged)
                        self.assertIn(b"\nfirst\n=========\nOTHER\n", merged)
                        self.assertIn(b">>>>>>>>> conflict\n", merged)

            executable = bin_dir / "mergiraf"
            executable.write_text(
                '#!/bin/sh\nprintf "%s\\n" "$@" > "$HOME/mergiraf-args"\n'
                'exit "$MERGIRAF_STATUS"\n'
            )
            executable.chmod(0o700)
            for driver_status, git_status in [(0, 0), (1, 1), (129, 128)]:
                with self.subTest(driver_status=driver_status):
                    env["MERGIRAF_STATUS"] = str(driver_status)
                    result = run("merge-tree", "--write-tree", "ours", "theirs", check=False)
                    self.assertEqual(result.returncode, git_status, result.stderr)
                    args = (home / "mergiraf-args").read_text().splitlines()
                    self.assertEqual(args[:2], ["merge", "--git"])
                    self.assertEqual(args[-4:], ["-p", filename, "-l", "9"])


if __name__ == "__main__":
    unittest.main()
