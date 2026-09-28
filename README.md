# herdr

My [herdr](https://herdr.dev) config, tuned to feel like my [tmux.conf](https://github.com/vyorkin/tmux.conf). A single `config.toml` works on both macOS and Linux.

## Setup

```sh
git clone https://github.com/vyorkin/herdr.git ~/projects/personal/herdr
```

**macOS** — symlink the config directly:

```sh
mkdir -p ~/.config/herdr
ln -sf ~/projects/personal/herdr/config.toml ~/.config/herdr/config.toml
herdr config check
```

**Linux (Omarchy)** — install the theme hook, which writes the effective config:

```sh
mkdir -p ~/.config/omarchy/hooks/theme-set.d ~/.config/omarchy/hooks/post-boot.d
ln -sf ~/projects/personal/herdr/omarchy/herdr-theme.sh ~/.config/omarchy/hooks/theme-set.d/herdr
ln -sf ~/projects/personal/herdr/omarchy/herdr-theme.sh ~/.config/omarchy/hooks/post-boot.d/herdr
~/.config/omarchy/hooks/theme-set.d/herdr
herdr config check
```

Herdr has no config include, so on Linux the hook renders
`~/.config/herdr/config.toml` from `config.toml` plus a `[theme.custom]` block
derived from the active Omarchy theme, then reloads the running server. Re-run
the hook after editing `config.toml` (any `omarchy theme set` does it too). On
macOS nothing is generated: the file stays a plain symlink.

## Key bindings

Prefix is `Ctrl+Space`.

| Key | Action |
|---|---|
| `prefix + j` / `prefix + l` | Split down / right |
| `prefix + x` | Close pane |
| `prefix + q` | Close tab |
| `prefix + d` | Detach |
| `prefix + C-h` | Toggle zoom |
| `prefix + H/J/K/L` | Resize pane |
| `prefix + Tab` | Last pane |
| `prefix + C-s` | Cycle panes |
| `prefix + C-g` | New worktree |
| `prefix + G` | Lazygit popup |
| `Alt + h/j/k/l` | Focus pane |
| `Alt + p / n` | Previous / next tab |
| `Alt + t` | Scratch shell popup (`$SHELL -l`) |

## Platform notes

One config file targets both macOS and Linux:

- The base `theme.auto_switch` follows the host terminal's light/dark report, so
  it works on macOS and on Linux terminals that report `color-scheme` (foot,
  Ghostty, kitty, ...). Terminals without that support keep `catppuccin`.
- The `Alt + t` scratch popup runs `exec "${SHELL:-sh}" -l`, i.e. your login
  shell on either OS (zsh on macOS, whatever `$SHELL` is on Linux).
- `terminal.shell_mode = "auto"` starts login shells on macOS and non-login
  shells elsewhere, matching each platform's convention. `terminal.default_shell`
  is left unset so new panes use `$SHELL`.
- The `prefix + G` popup requires `lazygit` on `PATH` (Homebrew on macOS, the
  distro package on Linux).

## Theme

The base config uses `catppuccin` with `theme.auto_switch`, so the UI follows the
host terminal's light/dark report on macOS and on Linux terminals that report
`color-scheme`.

On Linux/Omarchy the `theme-set` hook additionally layers a `[theme.custom]`
block rendered from the active Omarchy `colors.toml`, so Herdr matches the
desktop theme instead of Catppuccin. It regenerates on every `omarchy theme set`
and at login (`post-boot`).

Secondary text (`overlay0`/`overlay1`/`subtext0`) and the active sidebar row are
derived with the same `mix` helper Omarchy uses for its own TUI themes
(`pi.json`, `claude.json`, `t3code.json`, `shell.toml`), because the theme's
`muted` slot is the bright-black ANSI colour and can sit too close to the
background to read. If a theme ships a declarative `colors-herdr.toml`
(`schema = 1`, the `colors-<app>.toml` convention behind
[basecamp/omarchy#8011](https://github.com/basecamp/omarchy/pull/8011)), its
`[theme.custom]` block takes precedence over the derived palette.
