# Configuration architecture

This document describes the current configuration and data flows. User-facing
commands remain in `README.md`, and maintenance constraints remain in
`AGENTS.md`.

## Package ownership

Each deployed top-level package mirrors its path below `$HOME`. The supported
package set is declared by `stow_all.sh`: `bat`, `fzf`, `ghostty`, `git`,
`herdr`, `kitty`, `lazygit`, `ripgrep`, `starship`, `tmux`, `tuicr`,
`yamllint`, and `zsh`.

`stow_all.sh` is the full deployment boundary. Before restowing packages it
generates Starship configurations. It uses
`--no-folding` for Herdr, tuicr, and Zsh so local files can coexist in their
configuration directories without becoming repository content. It also
rebuilds Bat's cache after deployment when Bat is installed.

## Generated configuration flows

Token owns terminal color definitions:

```text
Token contrib exports
        |
        v
sync_token_themes.sh
        |
        +--> tracked themes for Bat, FZF, Ghostty, Git/Delta,
        |    Herdr, Kitty, LazyGit, Ripgrep, tmux, tuicr, and Zsh/Carapace
        |
        +--> tracked Starship palettes
                    |
                    v
             starship/.config/src/generate.sh
                    |
                    v
             ignored deployable Starship configs
```

The tracked Starship inputs are `starship/.config/src/base.toml` and
`starship/.config/src/palettes/*.toml`. Each palette file holds only Token's
`[palettes.<family>-<mode>]` section. `generate.sh` checks that the section
matches the file name and adds the `palette` directive itself, after the
schema line of `base.toml`. The generated files under
`starship/.config/` are ignored and must be rebuilt before deploying that
package. Imported Token theme files are tracked generated artifacts and must be
refreshed through `sync_token_themes.sh`, not edited individually.

## Runtime appearance and local state

Zsh coordinates the selected Token family and the host light or dark mode.
`zsh/.config/zsh/functions/_system_appearance` reads the mode from macOS
`defaults`, or under WSL2 from the Windows `AppsUseLightTheme` registry value
through `reg.exe`. Elsewhere, or when the query fails, it keeps the inherited
`SYSTEM_APPEARANCE`, defaulting to dark.
`.zshrc` defines the six families, in `token-theme next` order, as the
`_token_appearances` array. `token-theme`, its completion, `_token_appearance`,
and the Git theme include pattern read that array, so functions loaded without
`.zshrc` need it defined first, as `tests/test_zsh.py` does.
`sync_token_themes.sh` and `starship/.config/src/generate.sh` are POSIX `sh`
and keep their own copies of the list.
`zsh/.config/zsh/functions/token-theme` persists the family under
`${XDG_STATE_HOME:-$HOME/.local/state}/token/appearance`.
`zsh/.config/zsh/functions/_apply_appearance` selects the matching Bat,
Delta/Git, FZF, LazyGit, Ripgrep, Starship, Zsh, and Carapace configuration.
It also writes ignored adapters for Ghostty and tmux, which long-running
applications consume when reloaded. Because Herdr has no include directive,
Zsh composes its tracked `config.base.toml` and selected mode-independent Token
family fragment into an ignored `config.toml`.

tuicr reads only its config file, and Neovim starts it directly, so Zsh writes
an ignored `~/.config/tuicr/config.toml` that sets `theme_dark` and
`theme_light` to the selected family. tuicr chooses between them from the
terminal background at startup, so a running review keeps its theme until
tuicr restarts. The file uses the same generated header and unmanaged-file
protection as Herdr's configuration and has no tracked base yet. Both checks
go through `_is_generated_file`, and both files, the Ghostty and tmux adapters,
and the `token-theme` state file are written by `_write_token_adapter`, which
writes atomically, privately, and only when the content changes.

The appearance check runs every third prompt. It picks up Token family changes
on every platform but re-reads the system mode only on macOS; WSL2 reads the
Windows mode once at shell startup, because each `reg.exe` call crosses the
Windows interop boundary. When the Ghostty adapter contents change, Zsh writes
it atomically and, on macOS only, sends `SIGUSR2` to this user's processes
named exactly `ghostty`, including the shell's ancestor process.
Ghostty reloads its configuration for both mode and Token family changes.
Identical adapters do not trigger another reload; Ghostty being absent is silent.
Idle terminals and active editors wait until a shell reaches the check. Reloading
has the same font-refresh limitations as the manual reload action.

Herdr's family fragments enable automatic light/dark switching from the host
terminal appearance reported by Ghostty. Its active configuration is written
atomically with file mode `0600` under a `0700` directory. Existing files
without the fixed generated header are not overwritten. A changed file reloads
the default server only when `herdr status server` reports it running. Herdr
logs, sockets, sessions, and pane history remain local; pane-history persistence
is disabled because terminal output may contain sensitive data. Zsh composes the
configuration at interactive startup and when the Token family or macOS
appearance changes. Base and theme-fragment edits take effect when a new
interactive shell starts.

Both Git includes, the theme and difftastic, are managed by
`_git_env_include` through `GIT_CONFIG_COUNT` and its numbered entries. It
reuses the first matching `include.path` entry, removes further copies
inherited from parent shells, preserves unrelated entries and their order, and
exports only values that change. Tmux follows the selected family but retains
its manually selected light/dark mode.

Interactive Zsh calls `_init_difftastic` once at startup. When `difft` is on
`PATH`, it includes `~/.config/git/difftastic.inc`; when `difft` is absent, it
removes inherited copies.
Availability changes take effect in a new shell and apply to its child processes.
The fragment owns `git difft`, `git dshow`, `git dlog`, and the explicitly selected
`git difftool -t difftastic`; Delta remains the default viewer and staging filter.

`_apply_appearance` exports `DFT_BACKGROUND=light` or `dark` when `difft` is
available, both at startup and after a detected change at the three-prompt
check. Subsequent invocations use the updated value. Difftastic's
native display, context, syntax, width, and automatic color defaults remain
unforced; per-command `DFT_DISPLAY`, `DFT_CONTEXT`, `DFT_WIDTH`, and
`DFT_BACKGROUND` overrides are documented in `README.md`. Its pager is
`less -FRX`, and colors use Ghostty's existing Token ANSI palette.

Ctrl-R history deletion runs in the parent Zsh widget. Zsh reads and writes
complete history events, then the widget loads a replacement history context
and reopens the finder. Subsequent deletions reuse that context. Other running
shells retain their own in-memory history lists.

Private configuration, shell history, caches, generated appearance adapters,
Herdr runtime state, and deployable Starship outputs are intentionally outside
version control.
The relevant boundaries are enforced by `.gitignore` and package-local
`.stow-local-ignore` files; the Zsh startup files create the XDG state and
cache directories.

## Platform differences

Zsh takes Homebrew paths from `HOMEBREW_PREFIX`:
`/opt/homebrew` on macOS and `/home/linuxbrew/.linuxbrew` on WSL2 Ubuntu. The
`Brewfile` installs casks and macOS-only formulae only under `OS.mac?`. On
WSL2, Zsh uses commands that ship with Windows. Ctrl-Y in the Ctrl-R finder
copies through `clip.exe`, converting to UTF-16LE with `iconv` first, and
`open` and `BROWSER` use `explorer.exe`, converting existing paths with
`wslpath -w`. The macOS-only `whichapp` function and the Ghostty and Kitty
packages have no WSL2 counterpart.

## Validation boundaries

Validation is package-scoped. `AGENTS.md` lists the authoritative checks for
shell, TOML, Ghostty, Markdown, and simulated Stow deployment. Full deployment,
Token synchronization, cache cleanup, and other runtime mutations are
operational actions rather than validation steps.
