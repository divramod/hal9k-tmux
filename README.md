# hal9k-tmux

A tmux plugin that jumps between projects, worktrees and panes: a searchable picker, keys for each project's sessions, global hotkeys.

This repository is a snapshot published from divramod/hal2: each publish overwrites it. Issues are welcome here; a
pull request is taken over by hand, never merged. Everything is one program, `hal2-cli-tmux`, which the plugin fetches.

## Install, update, uninstall

With [TPM](https://github.com/tmux-plugins/tpm), in `~/.tmux.conf` above TPM's `run` line, then `prefix + I`:

```
set -g @plugin 'divramod/hal9k-tmux'
```

TPM clones this repository and runs `hal9k-tmux.tmux`. That entry fetches the program for your system from the
[release](https://github.com/divramod/hal9k-tmux/releases) named by `VERSION` into `bin/` (in the background, checked
against `SHA256SUMS`) and starts it. **Pin** a version with `set -g @plugin 'divramod/hal9k-tmux#v0.1.0'` (a tag of the
releases). **Update** with `prefix + U`; the old program keeps working until the new one is there.

**Uninstall** in this order: run `~/.tmux/plugins/hal9k-tmux/bin/hal2-cli-tmux hotkeys uninstall` (removes the hotkey
service, if you used it), delete the `@plugin` line, press `prefix + Alt + u`. If the folder goes first, the hotkey agent
notices its program is gone, frees its keys and ends; `hotkeys uninstall` removes what it left.

Needs tmux 3.2 or newer, and curl or wget for the install. Programs exist for macOS and Linux (arm64, x64), and for
WSL, where the Windows one comes along. What cannot be installed is said once in the status line (no curl and wget,
offline, a file that is not the one `SHA256SUMS` names); the next start of tmux tries again. `hal2-cli-tmux doctor`
reports the tmux version, extended keys, the terminal's features and every key that could not be bound.

## Keys

Default keys, in tmux's root table, from `hal2-cli-tmux keys --markdown`; `hal2-cli-tmux keys` lists the live ones and
`Ctrl+Shift+/` shows them in a popup. Every key is an option (`none` drops it): [docs/keys.md](docs/keys.md).

<!-- keys:start -->
| Option | Default | Table | Action |
|---|---|---|---|
| `@hal9k-tmux-key-picker` | `C-S-s` `M-s` | root | the picker: the project's panes and worktrees |
| `@hal9k-tmux-key-picker-all` | `C-S-g` `M-d` | root | the picker: every project's panes and worktrees |
| `@hal9k-tmux-key-jump-modifier` | `C-S-` | root | before a digit 0-9: the project's worktree session 00-09 (one of them alone: `@hal9k-tmux-key-jump-<digit>`) |
| `@hal9k-tmux-key-jump-main` | `C-S-m` | root | the project's main checkout's session |
| `@hal9k-tmux-key-jump-farmer` | `C-S-f` | root | the project's farmer session |
| `@hal9k-tmux-key-jump-nvim` | `C-S-n` | root | the project's nvim pane |
| `@hal9k-tmux-key-cli` | `C-S-c` | root | the project's cli pane, made under nvim when missing |
| `@hal9k-tmux-key-new` | `C-S-w` | root | a new worktree session in a popup |
| `@hal9k-tmux-key-back` | none | root | back to the place focused before |
| `@hal9k-tmux-key-cycle` | `C-BTab` | root | the next tmux session |
| `@hal9k-tmux-key-actions` | `M-a` | root | the project's GitHub Actions page |
| `@hal9k-tmux-key-help` | `C-S-/` | root | this list of the plugin's keys |
<!-- keys:end -->

`back` (across sessions, to the place focused before) has no default key. `Option+Tab` stays the last window of the
current session (tmux's `last-window`; in the session `shot` it hides it), a bind of your own tmux.conf: the plugin binds
no `M-Tab`, so yours is not replaced, and `keys` lists it when the server binds it that way. `@hal9k-tmux-key-back M-Tab`
(or any key) binds `back`. Inside a popup `Option+Tab` closes the popup.

`C-S-` keys arrive only as extended keys: `set -s extended-keys on` and a terminal that sends them (per terminal in
[docs/keys.md](docs/keys.md)). `M-` keys need Option as Alt on a Mac.

## The picker

A popup of the project's table (`@hal9k-tmux-key-picker`) or of every project's (`-picker-all`). Type to search (a word
is matched in any one column; `'exact`, `^start`, `end$`, `!not` work as in fzf), Up/Down, Enter goes to the row, Escape
closes, a mouse click selects and a double click opens. The query line has no cursor and matches are not highlighted yet.

| Part | What it does |
|---|---|
| Rows | a pane per tmux pane; a detached session; a worktree without a session (Enter opens its session); `nvim`, `cli`, `new`; a repository's standard windows (with smug); GitHub rows |
| GitHub rows | one per page: code, issues, pulls, actions, run (needs `gh`), agents, projects, security, insights, settings, runners; Enter opens it in the browser |
| Order | worktrees and branches first, then nvim, cli, new and the GitHub rows, then plain shells |
| Sorting | click a header to cycle ascending, descending, off (`TOOL▲1`); several columns sort in click order; `[clear sort]` clears; kept per table. Keys `Alt+1` to `Alt+9`, `Alt+0` |
| Claude filter | `Ctrl+a` shows only rows with a started Claude session, `Ctrl+x` shows all again (`[claude]` in the header) |
| Preview | the lower half: a pane's screen, a detached session's screen, a worktree's last commit and status |
| Tables | `Alt+s` the project's, `Alt+d` every project's, `Alt+a` the GitHub Actions page; all keys are options |

Columns: WORKTREE, TOOL, PLAN#, PLAN, STEP, QUEUE, MODEL, EFFORT, CTX, TMUX (PROJECT and ALIAS first in the global table).
The plan, queue, model, effort and CTX columns are filled by the optional tools below; without them the column is left out.

## Popups and commands

- A **shell popup** (a worktree session, `new`) runs behind a key filter: `Ctrl-\` closes a zsh popup (the plugin's own
  `.zshrc`, which keeps your `ZDOTDIR` and `HISTFILE`); in bash, fish or another shell type `exit` (the title says so).
- The **busy popup** (three lines, a spinner) appears when a move takes longer than 0.4 s. The **attach popup** opens a
  detached session in a popup. Inside a popup the plugin's root-table keys still act (none with `@hal9k-tmux-keys off`).

| Command | What it does |
|---|---|
| `plugin init`, `plugin version` | the entry's: bind keys, hooks and aliases on the server; the version this program is for |
| `keys [--markdown\|--conf\|--popup]`, `doctor` | live keys, default table, the commands sourced; the report |
| `list [all] [--fast] [--json]` | the picker's rows as text or JSON |
| `picker`, `pick [all\|actions]` | the picker in a popup; from outside tmux (hotkeys, a launcher) on the terminal's client |
| `jump`, `goto`, `back`, `cycle`, `record` | the moves the keys run; `record` is the hooks' |
| `cli`, `new`, `alias`, `actions`, `standard check` | the cli pane, a new worktree session, a project's window name, the Actions page, the standard windows |
| `hotkeys agent\|install\|uninstall\|status\|reload\|stop\|print` | global hotkeys: [docs/hotkeys.md](docs/hotkeys.md) |
| `navigate`, `copy-word`, `copy-line`, `kill-other-panes`, `edit-pane`, `shot-toggle`, `open-github`, `git-status`, `keybindings`, `smug-load` | helpers for a tmux.conf, listed by `hal2-cli-tmux --help` |

## Options

All are tmux options (`set -g @hal9k-tmux-...`); the defaults below are the author's own, set yours. Keys:
[docs/keys.md](docs/keys.md). Global hotkeys: [docs/hotkeys.md](docs/hotkeys.md).

| Option | Default | What it does |
|---|---|---|
| `@hal9k-tmux-keys`, `@hal9k-tmux-hooks`, `@hal9k-tmux-quiet` | on, on, off | bind the keys / set the hooks that record places for `back` / say nothing in the status line |
| `@hal9k-tmux-projects-root` | `~/a` | every git repository in it gets the standard rows |
| `@hal9k-tmux-hosts-session`, `@hal9k-tmux-popup-sessions` | `hosts`, `shot` | the session for detached sessions without a place / sessions shown in a popup, never a place |
| `@hal9k-tmux-standard-sessions` | `h1:hal2 h2:i` | `<session>:<repository>` pairs: where a repository's standard windows go, the repository being the template in the session's smug config |
| `@hal9k-tmux-smug-dir`, `@hal9k-tmux-editor-command` | `~/.config/smug`, `sl` | where smug configs are / what a standard window's nvim pane runs |
| `@hal9k-tmux-agent` | `claude` | the agent a new session starts |
| `@hal9k-tmux-first-new-slot` | `21` | the first worktree number a `new` session takes |
| `@hal9k-tmux-agents-ttl` | `120` | seconds an agent list stands in for a fresh one |
| `@hal9k-tmux-integrations` | all four | the optional tools to use when found; `none` for none |
| `@hal9k-tmux-popup-width`, `@hal9k-tmux-popup-height`, `@hal9k-tmux-cli-height` | `90%`, `90%`, `30%` | size of a worktree or new-session popup, and of the cli pane |
| `@hal9k-tmux-picker-width`, `@hal9k-tmux-picker-width-all`, `@hal9k-tmux-picker-height` | `80%`, `95%`, `95%` | the picker popup's size (cells or percent) |
| `@hal9k-tmux-browser-app` | `Google Chrome` | macOS: the browser whose open tab for a GitHub page is raised; `none` opens plain |
| `@hal9k-tmux-terminal-termname`, `@hal9k-tmux-terminal-bundle`, `@hal9k-tmux-terminal-command` | `xterm-ghostty`, `com.mitchellh.ghostty`, unset | the terminal a `pick` from outside tmux uses: its client's TERM (`any` for every client), its macOS bundle id or Linux app id, a shell command that opens a window (`{command}` is what it runs) |
| `@hal9k-tmux-bin` (or `HAL9K_TMUX_BIN`) | unset | a hal2-cli-tmux to run instead of the one in `bin/`; nothing is installed then |

## Optional tools, state, platforms

Each is used when found (`@hal9k-tmux-integrations` picks): `hal2-cli-agents` (agent sessions: detached rows, MODEL, EFFORT,
CTX, previews), `hal2-cli-git` (QUEUE, the `new` row, worktree sessions; without it a slot opens a shell), `smug`
(standard rows, sessions started), `gh` (the `run` row). A tool outside `PATH` and Homebrew is not found from a launcher.

State is in `$XDG_STATE_HOME/hal9k-tmux` (else `~/.local/state/hal9k-tmux`; on Windows the logs are in
`%TEMP%\hal9k-tmux`): `conf/` (the keys sourced), `focus/` (places for `back`), `picker-sort.json`, `agents.json`,
`pick.log`, `hotkeys.log` (cut at 256 KB), `hotkeys.*` (the agent), `zsh/` (the popup's `.zshrc`), short-lived `busy-*`.

| System | Keys and picker | Global hotkeys | Raising the terminal |
|---|---|---|---|
| macOS | yes | LaunchAgent, Carbon | Ghostty or `terminal-bundle` app, its tab picked |
| Linux X11 | yes | systemd user unit, XGrabKey | window of the terminal |
| Linux Wayland | yes | the desktop portal (GNOME asks once) | only with `focus-events on`, else a new window |
| sway, Hyprland | yes | sway: none, `hotkeys print` gives `bindsym` lines; Hyprland: the portal, `hotkeys print` its binds | its own IPC |
| WSL | yes | the Windows logon task (install from WSL) | Windows' side |
| Windows | needs tmux (WSL) | logon task, `RegisterHotKey` | `wt.exe` |

On macOS a password field (secure keyboard entry) can withhold global keys; inside the terminal tmux reads keys itself.

## Files

`hal9k-tmux.tmux` (the entry, the only shell), `VERSION`, `SHA256SUMS` (written by the publish), `bin/` (not tracked), `docs/`, `LICENSE` (MIT).
