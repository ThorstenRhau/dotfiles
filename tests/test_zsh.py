"""Regression checks using disposable state and shells without personal startup files."""

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FUNCTIONS = ROOT / "zsh/.config/zsh/functions"
HERDR_SOURCE = ROOT / "herdr/.config/herdr"


class ZshTests(unittest.TestCase):
    def run_zsh(self, script, *args):
        with tempfile.TemporaryDirectory(prefix="dotfiles-zsh-") as home:
            result = subprocess.run(
                ["zsh", "-dfi", "-c", script, "test", str(FUNCTIONS), *map(str, args)],
                env={
                    "PATH": os.environ["PATH"],
                    "HOME": home,
                    "ZDOTDIR": home + "/.config/zsh",
                    "XDG_CONFIG_HOME": home + "/.config",
                    "XDG_STATE_HOME": home + "/.local/state",
                },
                capture_output=True,
                text=True,
                timeout=10,
                check=False,
            )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(result.stderr, "")
        return result.stdout

    def test_git_configuration_survives_appearance_changes(self):
        self.run_zsh(r"""
            fpath=("$1" $fpath)
            autoload -Uz _apply_appearance
            _token_appearance() { print -r -- "$test_appearance"; }
            _write_token_adapter() { return 0; }
            pkill() { return 1; }
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

    appearance_setup = r"""
        fpath=("$1" $fpath)
        autoload -Uz _apply_appearance _write_token_adapter _token_appearance
        autoload -Uz _check_appearance token-theme
        _OS_TYPE=Darwin
        SYSTEM_APPEARANCE=light
        TOKEN_APPEARANCE=token
        tmux() { return 1; }
        adapter="$XDG_CONFIG_HOME/ghostty/token-active.ghostty"
        signal_count=0
        signal_status=0
        pkill() {
          [[ "$*" == "-USR2 -a -x -u $EUID ghostty" ]] || exit 90
          # Inspect the complete on-disk adapter at the moment of delivery.
          local grade=15
          [[ $SYSTEM_APPEARANCE == dark ]] && grade=-15
          local expected="theme = dark:$TOKEN_APPEARANCE-dark,light:$TOKEN_APPEARANCE-light
font-variation = GRAD = $grade
font-variation-bold = GRAD = $grade
font-variation-italic = GRAD = $grade
font-variation-bold-italic = GRAD = $grade"
          [[ -f $adapter && "$(<"$adapter")" == "$expected" ]] || exit 91
          [[ ! -e "$adapter.tmp.$$" ]] || exit 92
          ((signal_count++))
          return $signal_status
        }
    """

    herdr_setup = r"""
        fpath=("$1" $fpath)
        autoload -Uz _apply_appearance _write_token_adapter
        _token_appearance() { print -r -- "$test_appearance"; }
        _OS_TYPE=Darwin
        SYSTEM_APPEARANCE=light
        TOKEN_APPEARANCE=token
        test_appearance=token
        pkill() { return 1; }
        tmux() { return 1; }
        herdr_source="$2"
        herdr_dir="$XDG_CONFIG_HOME/herdr"
        mkdir -p "$herdr_dir/themes"
        cp "$herdr_source/config.base.toml" "$herdr_dir/config.base.toml"
        cp "$herdr_source/themes/"*.toml "$herdr_dir/themes/"
        herdr_events="$HOME/herdr-events"
        herdr_running=false
        herdr() {
          case "$*" in
            "status server")
              [[ -f "$herdr_dir/config.toml" &&
                "$(<"$herdr_dir/config.toml")" == *"$expected_accent"* ]] || exit 92
              print -r -- status >> "$herdr_events"
              if [[ $herdr_running == true ]]; then
                print -r -- "status: running"
              else
                print -r -- "status: not running"
              fi
              ;;
            "server reload-config")
              [[ -f "$herdr_dir/config.toml" &&
                "$(<"$herdr_dir/config.toml")" == *"$expected_accent"* ]] || exit 93
              print -r -- reload >> "$herdr_events"
              ;;
            *) exit 94 ;;
          esac
        }
    """

    def test_herdr_generation_family_switching_and_reload_order(self):
        self.run_zsh(
            self.herdr_setup
            + r"""
            config="$herdr_dir/config.toml"
            header='# Generated by _apply_appearance. Do not edit.'
            expected_accent='#f4906f'
            _apply_appearance
            expected="$header
$(<"$herdr_dir/config.base.toml")

$(<"$herdr_dir/themes/token.toml")"
            [[ "$(<"$config")" == "$expected" ]] || exit 1
            [[ $(stat -f %Lp "$herdr_dir") == 700 &&
              $(stat -f %Lp "$config") == 600 ]] || exit 2
            [[ "$(<"$herdr_events")" == status ]] || exit 3

            _apply_appearance
            SYSTEM_APPEARANCE=dark
            _apply_appearance
            [[ "$(<"$herdr_events")" == status ]] || exit 4

            test_appearance=token-flint
            expected_accent='#EB9E83'
            herdr_running=true
            _apply_appearance
            [[ "$(<"$herdr_events")" == $'status\nstatus\nreload' ]] || exit 5
            [[ "$(<"$config")" == *"$expected_accent"* ]] || exit 6
        """,
            HERDR_SOURCE,
        )

    def test_herdr_write_failure_does_not_query_or_reload_server(self):
        self.run_zsh(
            self.herdr_setup
            + r"""
            _write_token_adapter() {
              [[ $1 == "$herdr_dir/config.toml" ]] && return 1
              return 0
            }
            _apply_appearance 2> "$HOME/errors"
            [[ ! -e "$herdr_dir/config.toml" && ! -e "$herdr_events" ]] || exit 1
            [[ "$(<"$HOME/errors")" == *"Unable to update $herdr_dir/config.toml"* ]] || exit 2
        """,
            HERDR_SOURCE,
        )

    def test_herdr_missing_theme_and_unmanaged_config_are_protected(self):
        self.run_zsh(
            self.herdr_setup
            + r"""
            rm "$herdr_dir/themes/token.toml"
            _apply_appearance 2> "$HOME/errors"
            [[ ! -e "$herdr_dir/config.toml" && ! -e "$herdr_events" ]] || exit 1
            [[ "$(<"$HOME/errors")" == *"missing $herdr_dir/themes/token.toml"* ]] || exit 2

            cp "$herdr_source/themes/token.toml" "$herdr_dir/themes/token.toml"
            print -r -- '# Personal Herdr config' > "$herdr_dir/config.toml"
            _apply_appearance 2> "$HOME/errors"
            [[ "$(<"$herdr_dir/config.toml")" == '# Personal Herdr config' ]] || exit 3
            [[ ! -e "$herdr_events" ]] || exit 4
            [[ "$(<"$HOME/errors")" == *"Refusing to overwrite unmanaged $herdr_dir/config.toml"* ]] || exit 5
        """,
            HERDR_SOURCE,
        )

    def test_herdr_is_silent_when_base_package_is_absent(self):
        self.run_zsh(r"""
            fpath=("$1" $fpath)
            autoload -Uz _apply_appearance _write_token_adapter
            _token_appearance() { print -r -- token; }
            _OS_TYPE=Darwin
            SYSTEM_APPEARANCE=light
            TOKEN_APPEARANCE=token
            pkill() { return 1; }
            tmux() { return 1; }
            herdr() { exit 90; }
            _apply_appearance
            [[ ! -e "$XDG_CONFIG_HOME/herdr" ]] || exit 1
        """)

    def test_ghostty_reload_on_mode_changes_and_missing_adapter(self):
        output = self.run_zsh(self.appearance_setup + r"""
            _apply_appearance
            [[ $signal_count == 1 ]] || exit 1
            for SYSTEM_APPEARANCE in dark light; do
              _apply_appearance
            done
            [[ $signal_count == 3 ]] || exit 2
            _apply_appearance
            [[ $signal_count == 3 ]] || exit 3
            # A later shell sharing the adapter must not deliver another signal.
            (pkill() { exit 94; }; _apply_appearance) || exit 4
            rm "$adapter"
            _apply_appearance
            [[ $signal_count == 4 ]] || exit 5
        """)
        self.assertEqual(output, "")

    def test_ghostty_write_failure_does_not_signal(self):
        self.run_zsh(self.appearance_setup + r"""
            _apply_appearance
            original=$(<"$adapter")
            # A file in place of the parent directory forces the real writer to fail.
            XDG_CONFIG_HOME="$HOME/blocked"
            print -r -- blocked > "$XDG_CONFIG_HOME"
            SYSTEM_APPEARANCE=dark
            _apply_appearance 2> "$HOME/errors"
            [[ $signal_count == 1 && "$(<"$adapter")" == "$original" ]] || exit 1
            [[ "$(<"$HOME/errors")" == *"Unable to update $XDG_CONFIG_HOME/ghostty/token-active.ghostty"* ]] || exit 2
        """)

    def test_ghostty_absent_is_silent_and_signal_errors_are_reported(self):
        self.run_zsh(self.appearance_setup + r"""
            signal_status=1
            _apply_appearance > "$HOME/output" 2> "$HOME/errors"
            [[ $signal_count == 1 && ! -s "$HOME/output" && ! -s "$HOME/errors" ]] || exit 1
            signal_status=3
            SYSTEM_APPEARANCE=dark
            _apply_appearance 2> "$HOME/errors"
            [[ $signal_count == 2 && "$(<"$HOME/errors")" == *"Unable to reload Ghostty (pkill status 3)"* ]] || exit 2
            [[ $BAT_THEME == token-dark ]] || exit 3
        """)

    def test_ghostty_reload_on_token_family_changes(self):
        output = self.run_zsh(self.appearance_setup + r"""
            _apply_appearance
            for family in token-flint token-temper token-ultra token-meridian token; do
              token-theme "$family"
              [[ $TOKEN_APPEARANCE == $family ]] || exit 1
            done
            [[ $signal_count == 6 ]] || exit 2
            token-theme token
            [[ $signal_count == 6 ]] || exit 3
        """)
        self.assertEqual(output.splitlines(), [
            "token-flint", "token-temper", "token-ultra", "token-meridian", "token", "token"
        ])

    def test_ghostty_reload_waits_for_third_prompt(self):
        output = self.run_zsh(self.appearance_setup + r"""
            _apply_appearance
            defaults() { print -r -- Dark; }
            _appearance_prompt_count=0
            _check_appearance
            _check_appearance
            [[ $signal_count == 1 && $SYSTEM_APPEARANCE == light ]] || exit 1
            _check_appearance
            [[ $signal_count == 2 && $SYSTEM_APPEARANCE == dark ]] || exit 2
            repeat 3 _check_appearance
            [[ $signal_count == 2 ]] || exit 3
        """)
        self.assertEqual(output, "")

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
