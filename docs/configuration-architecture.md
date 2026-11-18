# Configuration architecture

This document describes the current configuration and data flows. User-facing
commands remain in `README.md`, and maintenance constraints remain in
`AGENTS.md`.

## Package ownership

Each deployed top-level package mirrors its path below `$HOME`. The supported
package set is declared by `stow_all.sh`: `bat`, `fzf`, `ghostty`, `git`,
`herdr`, `kitty`, `lazygit`, `ripgrep`, `starship`, `tmux`, `tuicr`,
`yamllint`, and `zsh`. Herdr is the primary persistent terminal workspace
manager. The tmux package remains as a fallback, but tmux itself is not
declared in the `Brewfile`.

`stow_all.sh` is the full deployment boundary. Before restowing packages it
generates Starship configurations. It uses
`--no-folding` for Herdr, tuicr, and Zsh so local files can coexist in their
configuration directories without becoming repository content. It also
rebuilds Bat's cache after deployment when Bat is installed.

## Generated configuration flows

Token owns terminal color definitions. Its six appearances are Classic Token,
Token Flint, Token Temper, Token Ultra, Token Meridian, and Token Melange:

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

`sync_token_themes.sh` takes the Token checkout as its argument, reads only
its `contrib` folder, and never modifies it. Most files are copied unchanged.
Three are adapted: the Delta themes are merged into
`git/.config/git/delta_themes.inc`; the Git color files
`token-<family>-<mode>.gitconfig` are built from each Starship palette; and
each Ripgrep theme is the tracked base config without its color options plus
Token's color options. The script ends by running the Starship generator.

The tracked Starship inputs are `starship/.config/src/base.toml` and
`starship/.config/src/palettes/*.toml`. Each palette file holds only Token's
`[palettes.<family>-<mode>]` section. `generate.sh` checks that the section
matches the file name and adds the `palette` directive itself, after the
schema line of `base.toml`. It creates one config per appearance and mode,
plus an unthemed fallback. The generated files under
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

`token-theme` with no argument prints the current family; with a family name it
selects it, and `token-theme next` cycles through all six. Classic Token is
used until another family is selected.
`zsh/.config/zsh/functions/token-theme` persists the family under
`${XDG_STATE_HOME:-$HOME/.local/state}/token/appearance`, outside Git.
`zsh/.config/zsh/functions/_apply_appearance` selects the matching Bat,
Delta/Git, FZF, LazyGit, Ripgrep, Starship, Zsh, and Carapace configuration.
It exports the family as `TOKEN_APPEARANCE`, which Neovim reads once at
startup to load the matching Token colorscheme
(`vim.cmd.colorscheme(vim.env.TOKEN_APPEARANCE or 'token')`). A running Neovim
does not switch when the family changes.
`_apply_appearance` also writes ignored adapters for Ghostty, Kitty, and tmux,
which long-running applications consume when reloaded. Because Herdr has no
include directive, Zsh composes its tracked `config.base.toml` and selected
mode-independent Token family fragment into an ignored `config.toml`.

Shell tools and Ghostty follow the macOS light or dark mode. On WSL2, shell
tools read the Windows app mode when an interactive shell starts. Herdr follows
the appearance reported by Ghostty and uses both modes from the selected family
fragment. Tmux follows the selected family but keeps its own light/dark mode:
it defaults to dark, and its prefix followed by `T` toggles it.

tuicr reads only its config file, and Neovim starts it directly, so Zsh writes
an ignored `~/.config/tuicr/config.toml` that sets `theme_dark` and
`theme_light` to the selected family. tuicr chooses between them from the
terminal background at startup, so a running review keeps its theme until
tuicr restarts. The file uses the same generated header and unmanaged-file
protection as Herdr's configuration and has no tracked base yet. Both checks
go through `_is_generated_file`, and both files, the Ghostty, Kitty, and tmux adapters,
and the `token-theme` state file are written by `_write_token_adapter`, which
writes atomically, privately, and only when the content changes.

The appearance check runs every third prompt. It picks up Token family changes
on every platform but re-reads the system mode only on macOS; WSL2 reads the
Windows mode once at shell startup, because each `reg.exe` call crosses the
Windows interop boundary. `token-theme` applies a changed family to its own
shell immediately; other existing shells pick it up at their next check.
The Ghostty adapter sets `theme = dark:<family>-dark,light:<family>-light`
and a font grade (`GRAD` of 15 in light mode and -15 in dark mode, for every
font variation). When the adapter contents change, Zsh writes
it atomically and, on macOS only, sends `SIGUSR2` to this user's processes
named exactly `ghostty`, including the shell's ancestor process.
Ghostty reloads its configuration for both mode and Token family changes, so
it also reloads immediately after a `token-theme` family change.
Identical adapters do not trigger another reload; Ghostty being absent is silent.
If CoreText does not refresh the grade in an existing surface, open a new
surface or restart Ghostty.
Kitty's tracked `dark-theme.auto.conf` and `light-theme.auto.conf` load Classic
Token and then optionally include `token-active-dark.conf` and
`token-active-light.conf`. Zsh writes both when the Kitty package is deployed,
and when either changes on macOS it sends `SIGUSR1` to this user's `kitty`
processes in the same way, so Kitty reloads for family changes. Kitty switches
between the two modes itself.
Idle terminals and active editors wait until a shell reaches the check. Reloading
has the same font-refresh limitations as the manual reload action.
When the family changes and a tmux server is running whose `@token_appearance`
differs, Zsh sources `tmux.conf` again so tmux reloads the selected family.

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

## Git

### Identity and signing

The tracked configuration never requires 1Password or a key, so Git works on
any machine. The main `config` sets `user.name` and `user.useConfigOnly`, and
`github.inc`, included for GitHub remotes, sets the personal author email.
Signing is machine-local and off by default. It
turns on only when the untracked `~/.gitconfig`, which Git reads after
`~/.config/git/config`, includes a signing profile (ADR-0005):

- `1password.inc`: the 1Password key through `op-ssh-sign`. Used on
  tesseract.home.
- `ssh-key.inc`: `~/.ssh/id_ed25519.pub` through the default `ssh-keygen`.
  Used on mighty.home, whose `~/.gitconfig` also sets the MightyHome identity
  so its commits verify on GitHub.

Both profiles sign every commit and annotated tag. `allowed_signers` lists
the public key of every signing host. A repository's own `.git/config` still
overrides all of this. Without the include, commits are unsigned.

### Diffs in the terminal

Delta is the Git pager and the interactive staging filter. It shows diffs side
by side and wraps long lines in full.

Interactive Zsh adds structural diff commands through an optional Git include,
`~/.config/git/difftastic.inc`. `_init_difftastic` runs once at startup: when
`difft` is on `PATH` it includes the fragment, and when `difft` is absent it
removes inherited copies. Child processes inherit the include, and a nested
Zsh removes it if `difft` is absent. Availability changes take effect in a new
shell after installing or removing difftastic. The fragment owns `git difft`,
`git dshow`, `git dlog`, and the explicitly selected
`git difftool -t difftastic`; Delta remains the default viewer and staging
filter.

```sh
git difft                         # Working tree diff
git dshow HEAD                    # Commit with structural diff
git dlog -5                       # History with structural patches
git difftool -t difftastic        # Explicit difftool selection
```

Difftastic uses its native adaptive side-by-side layout, syntax highlighting,
three context lines, and automatic terminal width; none of these is forced. The
commands use `less -FRX` to preserve colors, exit for short output, and leave
the result visible. Automatic color detection keeps redirected output plain.
Ghostty's existing Token ANSI palette supplies terminal colors; no extra theme
export is needed.

The difftastic difftool pages its own output, only when stdout is a terminal.
Setting `pager.difftool` would apply to every difftool and take the terminal
away from Neovim.

`_apply_appearance` exports `DFT_BACKGROUND=light` or `dark` when `difft` is
available. It runs at startup, whenever `token-theme` changes the family (on
every platform), and at the next scheduled appearance check (every third
prompt) after a detected change of the Token family or, on macOS only, of the
system mode. Changes affect subsequent
difftastic invocations; idle shells wait until another prompt. Per-command
overrides of the display options work as usual:

```sh
DFT_DISPLAY=inline git difft
DFT_DISPLAY=side-by-side-show-both DFT_CONTEXT=5 git dshow HEAD
DFT_WIDTH=120 DFT_BACKGROUND=light git difft
```

The Git theme include (`<family>-<mode>.gitconfig`) and the difftastic include
are both managed by `_git_env_include` through `GIT_CONFIG_COUNT` and its
numbered entries. It reuses the first matching `include.path` entry, removes
further copies inherited from parent shells, preserves unrelated entries and
their order, and exports only values that change.

### Diffs in Neovim

`git difftool` opens Neovim's built-in `nvim.difftool`, one file at a time.
`git dt [<revision>...]` is `git difftool -d`: it opens the whole changeset,
with the changed files in the quickfix list and each one as a side-by-side
diff.

### Lazygit

Lazygit renders diffs with delta, unified when the diff view is narrower than
160 columns and side by side above that. `|` cycles to difftastic. Zsh points
`LG_CONFIG_FILE` at the tracked `config.yml` plus the selected
`<family>-<mode>.yml` theme.

### Merges

Mergiraf handles Git merges for all files (`attributes` sets
`merge=mergiraf`) and detects supported languages automatically. Its conflicts
and errors are returned directly. Other text files use ordinary text merging.

When `mergiraf` is missing from `PATH`, the merge driver falls back to
`git merge-file` with the configured conflict style, labels, and marker size.
Binary conflicts then keep the current branch's version and stay unresolved for
manual resolution, while other merge errors still fail.

## Herdr

Herdr starts with its sidebar hidden; the prefix `Ctrl-B`, then lowercase `b`,
toggles it (Herdr's default `toggle_sidebar`, not overridden here). The sidebar
uses attention-priority agent ordering and status symbols. Panes have outer
frames with agent labels and Herdr's built-in gaps between them. A single pane
is also framed. The bottom tab bar is hidden for a single tab. Expanded sidebar
rows use bold workspace names and dim secondary details. `Ctrl-B` retains the
standard prefix actions, while `Alt` plus an arrow focuses an adjacent pane
directly. New tabs and workspaces prompt for names. Herdr's worktree creation
binding is disabled.

Background-agent notifications use Ghostty's terminal notification support
after a one-second delay, without sounds. Experimental pane-history persistence
is explicitly disabled because saved terminal output may contain sensitive
data. The Codex integration is not installed, so Codex panes do not natively
resume their conversations after a full Herdr restart.

Herdr does not support configuration includes, so Zsh composes the ignored
`~/.config/herdr/config.toml` from two tracked sources: the non-theme
preferences in `herdr/.config/herdr/config.base.toml` and the selected Token
fragment under `themes/`. Zsh only replaces files carrying its generated
header, writes the result privately (file mode `0600` under a `0700`
directory), and reloads a running default Herdr server after the content
changes. It reloads only when `herdr status server` reports the server running.
Zsh composes the configuration at interactive startup and when the Token family
or macOS appearance changes, so base and theme-fragment edits take effect when
a new interactive shell starts.

The family fragments enable automatic light/dark switching from the host
terminal appearance reported by Ghostty. Settings UI edits to `config.toml` are
temporary; durable preferences belong in the tracked base and durable colors
belong in Token.

Tombi linting applies to the imported fragments, but formatting is disabled so
they remain byte-identical to Token. Herdr logs, sockets, sessions, and pane
history remain local and untracked.

## Typography

Ghostty uses the licensed `MonoLisaCode` family for terminal cells and
`MonoLisaText` for window and tab titles. `Symbols Nerd Font Mono`, installed
through the declared Homebrew cask, is the fallback for semantic prompt and UI
icons that MonoLisa does not provide. Font files are installed locally and are
not part of this repository. The light/dark font grade is part of the Ghostty
adapter described under runtime appearance.

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
