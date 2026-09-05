"""Regression checks using disposable state and shells without personal startup files."""

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FUNCTIONS = ROOT / "zsh/.config/zsh/functions"


class ZshTests(unittest.TestCase):
    def run_zsh(self, script, *args):
        result = subprocess.run(
            ["zsh", "-dfi", "-c", script, "test", str(FUNCTIONS), *map(str, args)],
            env={**os.environ, "ZDOTDIR": "/nonexistent"},
            capture_output=True,
            text=True,
            timeout=10,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result.stdout

    def test_git_configuration_survives_appearance_changes(self):
        self.run_zsh(r"""
            fpath=("$1" $fpath)
            autoload -Uz _apply_appearance
            _token_appearance() { print -r -- "$test_appearance"; }
            _write_token_adapter() { return 0; }
            tmux() { return 1; }
            _OS_TYPE=Darwin
            SYSTEM_APPEARANCE=light
            test_appearance=token
            TOKEN_APPEARANCE=token
            export GIT_CONFIG_COUNT=2
            export GIT_CONFIG_KEY_0=review.first GIT_CONFIG_VALUE_0=first
            export GIT_CONFIG_KEY_1=review.second GIT_CONFIG_VALUE_1=second
            for test_appearance in token token-flint token-ultra token; do
              _apply_appearance
              [[ $GIT_CONFIG_COUNT == 3 && $GIT_CONFIG_KEY_2 == include.path &&
                 $GIT_CONFIG_VALUE_2 == "$HOME/.config/git/$test_appearance-light.gitconfig" &&
                 $(git config --get review.first) == first &&
                 $(git config --get review.second) == second ]] || exit 1
            done
            _OS_TYPE=Linux
            _apply_appearance
            [[ $GIT_CONFIG_COUNT == 3 && $GIT_CONFIG_VALUE_0 == first ]] || exit 2
        """)

    def test_completion_audit_handles_empty_and_spaced_paths(self):
        self.run_zsh(r"""
            fpath=("$1" $fpath)
            autoload -Uz zcompaudit
            compaudit() { return 0; }
            [[ $(zcompaudit) == 'No insecure zsh completion directories found.' ]] || exit 1
            compaudit() { print -r -- '/nonexistent/path with spaces'; return 1; }
            result=$(zcompaudit 2>&1)
            [[ $? == 1 && $result == *'/nonexistent/path with spaces  missing'* ]] || exit 2
        """)

    def test_history_deletion_preserves_other_complete_events(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-history-") as directory:
            history_file = Path(directory) / "history"
            history_file.write_text(
                ": 1700000000:0;echo keep-first\n"
                ": 1700000001:0;echo multiline\\\necho café\n"
                ": 1700000002:0;echo literal * [glob] (pattern)\n"
                ": 1700000003:0;echo multiline\\\necho café\n"
                ": 1700000004:0;echo keep-last\n",
                encoding="utf-8",
            )
            history_file.chmod(0o600)
            self.run_zsh(
                r"""
                fpath=("$1" $fpath)
                source "$1/../scripts/fzf-history-delete"
                HISTFILE="$2"
                HISTSIZE=100
                SAVEHIST=100
                setopt SHARE_HISTORY EXTENDED_HISTORY
                fc -R "$HISTFILE"
                _delete_history_entry $'echo multiline\necho café' || exit 1
                [[ ${(j: :)history} != *multiline* ]] || exit 2
                _delete_history_entry 'echo literal * [glob] (pattern)' || exit 3
                [[ ${(j: :)history} != *literal* ]] || exit 4
                [[ -o SHARE_HISTORY && $HISTSIZE == 100 && $SAVEHIST == 100 ]] || exit 5
            """,
                history_file,
            )
            self.assertEqual(
                history_file.read_text(encoding="utf-8"),
                ": 1700000000:0;echo keep-first\n: 1700000004:0;echo keep-last\n",
            )
            self.assertEqual(history_file.stat().st_mode & 0o777, 0o600)

    def test_empty_history_selection_restores_command_buffer(self):
        self.run_zsh(r"""
            fpath=("$1" $fpath)
            source "$1/../scripts/fzf-history-delete"
            # Model the native widget's output when fzf accepts with no match.
            fzf-history-widget() { LBUFFER=dotfiles-delete-history; return 1; }
            BUFFER='echo keep buffer'
            CURSOR=4
            LBUFFER='echo'
            _fzf-history-widget
            [[ $? == 1 && $BUFFER == 'echo keep buffer' && $CURSOR == 4 ]] || exit 1
        """)

    def test_history_deletion_honors_existing_ignore_and_can_empty_history(self):
        with tempfile.TemporaryDirectory(prefix="dotfiles-history-") as directory:
            history_file = Path(directory) / "history"
            history_file.write_text(
                ": 1700000000:0;echo ignored\n: 1700000001:0;echo delete-me\n",
                encoding="utf-8",
            )
            self.run_zsh(
                r"""
                fpath=("$1" $fpath)
                source "$1/../scripts/fzf-history-delete"
                HISTFILE="$2"
                HISTSIZE=100
                SAVEHIST=100
                HISTORY_IGNORE='echo ignored'
                setopt SHARE_HISTORY EXTENDED_HISTORY
                fc -R "$HISTFILE"
                _delete_history_entry 'echo delete-me' || exit 1
                [[ -z ${(j: :)history} && $HISTORY_IGNORE == 'echo ignored' ]] || exit 2
            """,
                history_file,
            )
            self.assertEqual(history_file.read_bytes(), b"")


if __name__ == "__main__":
    unittest.main()
