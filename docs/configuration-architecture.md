# Configuration architecture

This document describes the current configuration and data flows. User-facing
commands remain in `README.md`, and maintenance constraints remain in
`AGENTS.md`.

## Package ownership

Each deployed top-level package mirrors its path below `$HOME`. The supported
package set is declared by `stow_all.sh`: `bat`, `fzf`, `ghostty`, `git`,
`herdr`, `lazygit`, `ripgrep`, `starship`, `tmux`, and `zsh`.

`stow_all.sh` is the full deployment boundary. Before restowing packages it
generates Starship configurations and migrates Zsh history, caches, local
configuration, and secrets out of repository-owned paths. It uses
`--no-folding` for Herdr and Zsh so local files can coexist in their
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
        |    Herdr, LazyGit, Ripgrep, tmux, and Zsh/Carapace
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
`starship/.config/src/palettes/*.toml`. The generated files under
`starship/.config/` are ignored and must be rebuilt before deploying that
package. Imported Token theme files are tracked generated artifacts and must be
refreshed through `sync_token_themes.sh`, not edited individually.

## Runtime appearance and local state

Zsh coordinates the selected Token family and the macOS light or dark mode.
`zsh/.config/zsh/functions/token-theme` persists the family under
`${XDG_STATE_HOME:-$HOME/.local/state}/token/appearance`.
`zsh/.config/zsh/functions/_apply_appearance` selects the matching Bat,
Delta/Git, FZF, LazyGit, Ripgrep, Starship, Zsh, and Carapace configuration.
It also writes ignored adapters for Ghostty and tmux, which long-running
applications consume when reloaded. Because Herdr has no include directive,
Zsh composes its tracked `config.base.toml` and selected mode-independent Token
family fragment into an ignored `config.toml`.

The macOS appearance check runs every third prompt. When the Ghostty adapter
contents change, Zsh writes it atomically and then sends `SIGUSR2` to this user's
processes named exactly `ghostty`, including the shell's ancestor process.
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

The Git theme include preserves inherited environment configuration and reuses
its existing entry when the appearance changes. Tmux follows the selected
family but retains its manually selected light/dark mode.

Interactive Zsh calls `_init_difftastic` once at startup. When `difft` is on
`PATH`, it includes `~/.config/git/difftastic.inc` through `GIT_CONFIG_COUNT`.
The helper preserves unrelated entries and their order, deduplicates its own
include in nested shells, and removes inherited copies when `difft` is absent.
Availability changes take effect in a new shell and apply to its child processes.
The fragment owns `git difft`, `git dshow`, `git dlog`, and the explicitly selected
`git difftool -t difftastic`; Delta remains the default viewer and staging filter.

On macOS, `_apply_appearance` exports `DFT_BACKGROUND=light` or `dark` when
`difft` is available, both at startup and after a detected change at the
three-prompt check. Subsequent invocations use the updated value. Difftastic's
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
The relevant boundaries are enforced by `.gitignore`, package-local
`.stow-local-ignore` files, and the migrations in `stow_all.sh`.

## Validation boundaries

Validation is package-scoped. `AGENTS.md` lists the authoritative checks for
shell, TOML, Ghostty, Markdown, and simulated Stow deployment. Full deployment,
Token synchronization, cache cleanup, and other runtime mutations are
operational actions rather than validation steps.
