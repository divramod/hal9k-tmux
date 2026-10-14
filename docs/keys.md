# Keys

Back to the [README](../README.md). Every key of the plugin is a tmux option; the defaults are in the README's key
table (`hal2-cli-tmux keys --markdown` prints it, `hal2-cli-tmux keys` shows the live ones, `Ctrl+Shift+/` a popup).

## The key options

`@hal9k-tmux-key-<action>` holds a space-separated list of `[table:]key` entries, tmux key names (`C-S-s`, `M-Tab`,
`prefix:s`, `root:F5`). An entry without a table goes in `@hal9k-tmux-table` (default `root`). `none` or `off` drops the
action's keys. Set options in `~/.tmux.conf` above the TPM `run` line; to change one later, set it and run
`hal2-cli-tmux plugin init` (or reload the config): keys that are no longer wanted are unbound.

| Option | Action |
|---|---|
| `@hal9k-tmux-key-picker`, `-key-picker-all` | the picker of the project, of every project |
| `@hal9k-tmux-key-jump-modifier` | the keys before the digit of a numbered worktree session: `C-S-` makes `C-S-0` to `C-S-9` |
| `@hal9k-tmux-key-jump-<digit>` | one numbered jump alone (`-key-jump-0` to `-key-jump-9`); wins over the modifier |
| `@hal9k-tmux-key-jump-main`, `-jump-farmer`, `-jump-nvim` | the main checkout's session, the farmer session, the nvim pane |
| `@hal9k-tmux-key-cli`, `-key-new` | the cli pane, a new worktree session |
| `@hal9k-tmux-key-back`, `-key-cycle` | back to the place before (no default key), the next session |
| `@hal9k-tmux-key-actions`, `-key-help` | the GitHub Actions page, the key list popup |
| `@hal9k-tmux-keys` | `off` binds no key at all (default on) |
| `@hal9k-tmux-hooks` | `off` sets no hooks (default on); `back` then has no history |
| `@hal9k-tmux-quiet` | `on`: nothing is said in the status line (default off) |
| `@hal9k-tmux-table` | the key table of an entry that names none (default `root`) |
| `@hal9k-tmux-leader` | keys that open a leader table `hal9k` (default unset) |

**Option+Tab.** `back` has no default key (the user's decision, plan 0255 D149): `Option+Tab` is the last window of the
current session, the bind of your own tmux.conf (`bind -n M-Tab if-shell -F '#{==:#{session_name},shot}' 'detach-client'
'last-window'`; in `shot` it hides the session), and TPM runs the plugin after tmux.conf, so a plugin bind would replace
it. `hal2-cli-tmux keys` and the help popup list `M-Tab` as "the last window of this session (shot: hides it)" when the
server binds it to `last-window`; they bind nothing. `@hal9k-tmux-key-back M-Tab` makes `back` take the key (a conflict
is said once, as any key an option names). Inside a switcher popup (a worktree's shell, an attach) `Option+Tab` closes
the popup whatever is bound outside, unless `@hal9k-tmux-key-back` names other keys or `none`.

**Leader.** With `@hal9k-tmux-leader` set (say `prefix:Space`), each action also has a key without modifiers in the table
`hal9k`: `s` picker, `g` picker-all, digits, `m`, `f`, `n`, `c`, `w`, `Tab` back, `BTab` cycle, `a` actions, `?` help.

**Conflicts.** A default key that is bound to something else is left alone and said once (set the option to another
key to take it, or to its own key to confirm). A key an option names replaces any binding and is said once. A key
two options name stays with the first. A name tmux does not know is said (`doctor` lists it). A bind of your own that
comes after the plugin loads wins; the plugin does not take it back. A `@hal9k-tmux-key-` option no action has is a typo
`doctor` points out. The hooks (`client-session-changed`, `client-focus-in`, `session-window-changed`,
`window-pane-changed`) sit at index 90, so your own hooks keep theirs.

## The picker's keys

Inside the picker, `@hal9k-tmux-picker-key-<action>` holds tmux key names; `none` drops one. Defaults:

| Option | Default |
|---|---|
| `@hal9k-tmux-picker-key-accept` | `Enter` |
| `@hal9k-tmux-picker-key-abort` | `Escape` `C-c` `C-g` `C-q` `C-\` |
| `@hal9k-tmux-picker-key-up`, `@hal9k-tmux-picker-key-down` | `Up` `C-p` `C-k` `BTab` / `Down` `C-n` `C-j` `Tab` |
| `@hal9k-tmux-picker-key-page-up`, `@hal9k-tmux-picker-key-page-down` | `PPage` / `NPage` |
| `@hal9k-tmux-picker-key-delete-char`, `@hal9k-tmux-picker-key-delete-word`, `@hal9k-tmux-picker-key-clear` | `BSpace` `C-h` / `C-w` `M-BSpace` / `C-u` |
| `@hal9k-tmux-picker-key-project`, `@hal9k-tmux-picker-key-all`, `@hal9k-tmux-picker-key-actions` | `M-s` / `M-d` / `M-a` (the other table, the Actions page) |
| `@hal9k-tmux-picker-key-sort-<digit>` | `M-1` to `M-9`: sort by that column (counted from 1) |
| `@hal9k-tmux-picker-key-sort-clear` | `M-0` |
| `@hal9k-tmux-picker-key-filter-claude`, `@hal9k-tmux-picker-key-filter-clear` | `C-a` / `C-x` |

## Extended keys and terminals

The default `C-S-` keys (Ctrl+Shift+letter) are not told apart from Ctrl+letter by a terminal on its own; they arrive
as CSI u sequences only when tmux asks for extended keys and the terminal sends them. In `~/.tmux.conf`:

```
set -s extended-keys on
set -as terminal-features 'xterm-ghostty:extkeys'
```

(the second line for a terminal whose TERM is `xterm-ghostty`; `hal2-cli-tmux doctor` prints each client's features
and whether `extkeys` is among them, and says what to set). Without extended keys the `M-` defaults still work.

- **Ghostty**: on macOS set `macos-option-as-alt = true` in Ghostty's config so Option sends Alt (`M-s` is Option+S).
  Ghostty can also send a key as a CSI u sequence by a keybind of the form `keybind = ctrl+shift+s=csi:115;6u` (code
  of the key, then 1 plus the modifiers: Shift 1, Alt 2, Ctrl 4). Without such a keybind Ghostty drops the Shift of a Ctrl+Shift key.
- **Other terminals**: Option or Alt must send Escape-prefixed keys (iTerm2: "Left Option key: Esc+"; Terminal.app:
  "Use Option as Meta key"). A terminal that cannot send CSI u cannot use `C-S-` keys: bind them to other keys.
- Inside a popup the plugin recognises a key in all three encodings tmux may write (legacy, `CSI u`, `CSI 27;m;c~`).

## `keys`, `doctor` and the help popup

`hal2-cli-tmux keys` lists the keys that start the plugin on the running server, `keys --conf` the tmux commands
`plugin init` last sourced, `keys --markdown` the default table, `keys --popup <client> <width> <height>` the list in a
popup. The help key opens it (90 by 38 cells, or the client's size). `doctor` reports the tmux version, extended keys,
each terminal's features, whether keys and hooks are on and every notice above.
