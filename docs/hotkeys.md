# Global hotkeys

Back to the [README](../README.md). Three keys work outside the terminal: Option+S (Alt elsewhere) opens the picker of
the project the terminal shows, Option+D the picker of every project, Option+A the project's GitHub Actions page. The
terminal's window is raised once the picker is open. They are off until you ask for them, and need no other program.

## Turn them on

```
set -g @hal9k-tmux-hotkeys on
```

Then `prefix + I` or a config reload. `plugin init` installs a small per-user service (the *hotkey agent*) that starts
at login and holds the keys; nothing else runs. The same by hand:
`hal2-cli-tmux hotkeys install [--print] [--backend <name>]` (`--print` shows the file and writes nothing; run again it
changes nothing; a new program or version restarts the agent). It records the tmux server it ran in, so two servers
never take the agent from each other. To turn off: `set -g @hal9k-tmux-hotkeys off` and
`hal2-cli-tmux hotkeys uninstall` (removes the agent, the service, its files and folders; see the README for the
uninstall order).

## Commands

| Command | What it does |
|---|---|
| `hotkeys install` / `uninstall` | the service of the user: a LaunchAgent (macOS), a systemd user unit (Linux), a logon task (Windows, from WSL) |
| `hotkeys status` | the agent's keys and how each stands, its tmux server, the versions, the service; exit 1: no agent runs |
| `hotkeys reload` | the agent reads the options again and registers what changed |
| `hotkeys stop` | the agent frees its keys and ends (under launchd it restarts at once) |
| `hotkeys print [--backend <name>]` | what the desktop's own config needs: sway's `bindsym` lines, Hyprland's binds |
| `hotkeys agent [--check] [--log <file>] [--backend <name>] [--distro <name>] [--wsl-cli <path>]` | the agent itself; `--check` registers, prints and unregisters; `--backend macos\|windows\|x11\|portal\|sway\|wsl\|none` forces a backend; `--distro`, `--wsl-cli` name the WSL distribution and the plugin's program in it |

## The chords

`@hal9k-tmux-hotkey-project` (default `M-s`), `@hal9k-tmux-hotkey-all` (`M-d`) and `@hal9k-tmux-hotkey-actions` (`M-a`)
hold a tmux key name with `C-` and `M-` (Ctrl, Alt or Option), F1 to F12 at most; `none` gives no key. After a change
run `hal2-cli-tmux hotkeys reload`. A chord the system refuses is asked for again with Ctrl added (Ctrl+Option+S); two
actions with one chord leave the second without a key. One press is served at a time; a press during a pick is dropped.
The agent holds the defaults until the first press that reaches a tmux server, then reads your options.

## Per system

- **macOS**: the agent is a LaunchAgent `app.hal9k.tmux.hotkeys`; its output is in `hotkeys.out`. macOS shows a notice
  under *System Settings > General > Login Items & Extensions* ("Allow in the Background"): leave it on. While another
  app holds Secure Keyboard Entry (a password field) macOS may withhold global keys; inside the terminal tmux reads keys
  itself. Another app that owns the same chord (Alfred, Karabiner) can still get the press: free the chord there.
- **Linux, X11**: a systemd user unit tied to `graphical-session.target`, which gives it the session's `DISPLAY`. The keys
  are grabbed with XGrabKey (also with Caps or Num Lock on); a changed keyboard layout needs `hotkeys stop` and a new start.
- **Linux, Wayland**: the desktop's GlobalShortcuts portal. GNOME shows a dialog once to confirm the shortcuts (up to 60 s
  wait); a key you change in the desktop's settings survives a changed option. Raising a window is impossible on Wayland
  in general: with tmux's `focus-events on` a client that tmux marks focused counts as in front, else the pick opens a
  new terminal window (`@hal9k-tmux-terminal-command` can name one).
- **sway**: there is no portal; `hotkeys print --backend sway` prints three `bindsym` lines for `~/.config/sway/config`
  (then `swaymsg reload`). Hyprland uses the portal, and `hotkeys print` run in a Hyprland session prints the `bind = ..., global, :<action>` lines
  for `hyprland.conf` (not tested by the author).
- **No systemd** (startx, a window manager without `graphical-session.target`): the unit never starts. Start the agent
  from your session's startup file: `hal2-cli-tmux hotkeys agent &`; `hotkeys stop` ends it.
- **Windows with WSL**: tmux runs in WSL, the keys in Windows (`RegisterHotKey`). Run `hal2-cli-tmux hotkeys install`
  inside WSL: it copies the programs to `%LOCALAPPDATA%\hal9k-tmux` and creates a logon task that starts
  `hal2-cli-tmux-windows.exe` (a launcher without a console window, so no window flashes per press). A press runs `wsl.exe`
  and opens `wt.exe` when there is no terminal. The log is in `%TEMP%\hal9k-tmux\hotkeys.log`. On Windows itself
  `hotkeys install` says to run it in WSL.

## Where things are

The launcher's `PATH` is bare: `~/.local/bin` and `~/.cargo/bin` are added, but a tool elsewhere (a smug in `~/go/bin`)
is not found from a hotkey or a launcher, so put it in one of those or Homebrew's folder. The agent's files are in the
plugin's state folder (README): `hotkeys.log` (one line per press and refusal, cut at 256 KB), `hotkeys.out`,
`hotkeys.sock`, `hotkeys.server`, `hotkeys.installed`, and `pick.log` for the picks.

## Troubleshooting

Run `hal2-cli-tmux hotkeys status`: it prints each action's chord, what the system bound (or why it refused), the agent's
tmux server, the agent's and the program's versions and a `service` line. No agent runs (exit 1)? `hotkeys install --print`
shows what would be installed, `hotkeys agent --check` registers the keys once and says what is wrong ("none: no desktop
here" means the session has no X11 or Wayland display). A press that does nothing: read `hotkeys.log`.
