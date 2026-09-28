"""Check Starship generation without changing deployed configurations."""

import os
import shutil
import subprocess
import tempfile
import tomllib
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


class StarshipTests(unittest.TestCase):
    def test_generation_is_independent_of_exported_cdpath(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-starship-") as directory:
            home = Path(directory)
            source = home / "starship/.config/src"
            shutil.copytree(ROOT / "starship/.config/src", source)
            env = {"PATH": os.environ["PATH"], "HOME": directory}
            expected = None
            for cdpath in (None, directory):
                with self.subTest(cdpath=cdpath):
                    if cdpath is not None:
                        env["CDPATH"] = cdpath
                    result = subprocess.run(
                        ["sh", "starship/.config/src/generate.sh"], cwd=home,
                        env=env, capture_output=True, text=True, timeout=10,
                    )
                    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                    configs = {
                        path.name: path.read_bytes()
                        for path in source.parent.glob("starship*.toml")
                    }
                    self.assertEqual(len(configs), 11)
                    for content in configs.values():
                        tomllib.loads(content.decode())
                    if expected is None:
                        expected = configs
                    else:
                        self.assertEqual(configs, expected)


if __name__ == "__main__":
    unittest.main()
