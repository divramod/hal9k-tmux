# Changelog

## v0.1.2 (2026-10-14)

- internal changes

## v0.1.1 (2026-10-13)

### Fixes

- the README test resolves paths through hal2_core::fs::canonicalize_sync, so build-windows' seams check passes
- an attach tmux never answers ends with an error after 5 s; the tests that re-run themselves and the resident test wait within a limit

## v0.1.0 (2026-10-13)

- first release
