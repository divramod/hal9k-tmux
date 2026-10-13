#!/bin/sh
# hal9k-tmux's entry, the plugin's only shell (TPM runs it): starts hal2-cli-tmux, the plugin's program, and when
# bin/ holds none or another version fetches this release's in the background, checked against SHA256SUMS.
d=$(cd "$(dirname "$0")" && pwd) && v=$(cat "$d/VERSION") && o=$(tmux show-option -gqv @hal9k-tmux-bin) || exit 1
b=${o:=$HAL9K_TMUX_BIN} && b=${b:-$d/bin/hal2-cli-tmux}
say() { tmux display-message "hal9k-tmux v$v: $1"; exit 0; } # exit 0: tmux shows a failed job's status in a pane
if [ "$1" != --install ]; then
  [ "$("$b" plugin version 2>/dev/null)" = "$v" ] && exec "$b" plugin init
  [ -x "$b" ] && "$b" plugin init # another version: its keys stay bound meanwhile
  [ -z "$o" ] && exec tmux run-shell -b "'$d/${0##*/}' --install"
  say "$o is not hal2-cli-tmux $v (@hal9k-tmux-bin, HAL9K_TMUX_BIN)"
fi
t=$d/bin/.lock && mkdir -p "$d/bin" && find "$t" -prune -mmin +10 -exec rm -rf {} + 2>/dev/null
mkdir "$t" 2>/dev/null || exit 0 # another install runs
trap 'rm -rf "$t"' EXIT
u=${HAL9K_TMUX_RELEASE_URL:-https://github.com/divramod/hal9k-tmux/releases/download}/v$v
get() { # the release's asset for system $1 into the lock dir, its sha256 the one SHA256SUMS names
  n=hal9k-tmux-v$v.$1 && w=$(sed -n "s/  $n\$//p" "$d/SHA256SUMS" 2>/dev/null)
  [ -n "$w" ] || say "cannot install, SHA256SUMS names no $n"
  if command -v curl >/dev/null; then curl -fsSL --retry 2 --connect-timeout 10 -o "$t/$n" "$u/$n"
  elif command -v wget >/dev/null; then wget -q -T 10 -O "$t/$n" "$u/$n"
  else say "cannot install, needs curl or wget"; fi || say "cannot fetch $n (offline?)"
  { sha256sum "$t/$n" || shasum -a 256 "$t/$n"; } 2>/dev/null | grep -q "^$w " || say "$n is not what SHA256SUMS names"
}
get "$(uname -sm | sed 's/Darwin /macos./; s/Linux /linux./; s/x86_64/x64/; s/aarch64/arm64/').tar.gz"
tar -xzf "$t/$n" -C "$t" hal2-cli-tmux || say "cannot unpack $n"
case $(uname -r) in *[Mm]icrosoft*) get windows.x64.zip && mv -f "$t/$n" "$d/bin/hal2-cli-tmux.windows.x64.zip" ;; esac
mv -f "$t/hal2-cli-tmux" "$d/bin/hal2-cli-tmux" && "$d/bin/hal2-cli-tmux" plugin init
exit 0
