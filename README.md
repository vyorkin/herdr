# herdr

My [herdr](https://herdr.dev) config, tuned to feel like my [tmux.conf](https://github.com/vyorkin/tmux.conf). A single `config.toml` works on both macOS and Linux.

## Setup

```sh
git clone https://github.com/vyorkin/herdr.git ~/projects/personal/herdr
mkdir -p ~/.config/herdr
ln -sf ~/projects/personal/herdr/config.toml ~/.config/herdr/config.toml
herdr config check
```

Only `config.toml` is symlinked: `~/.config/herdr` also holds runtime state (logs, sockets, `session.json`).

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

- `theme.auto_switch` follows the host terminal's light/dark report, so it works
  on macOS and on Linux terminals that report `color-scheme` (foot, Ghostty,
  kitty, ...). Terminals without that support keep the dark `catppuccin` theme.
- The `Alt + t` scratch popup runs `exec "${SHELL:-sh}" -l`, i.e. your login
  shell on either OS (zsh on macOS, whatever `$SHELL` is on Linux).
- `terminal.shell_mode = "auto"` starts login shells on macOS and non-login
  shells elsewhere, matching each platform's convention. `terminal.default_shell`
  is left unset so new panes use `$SHELL`.
- The `prefix + G` popup requires `lazygit` on `PATH` (Homebrew on macOS, the
  distro package on Linux).

Theme follows the host terminal's light/dark appearance: `catppuccin` /
`catppuccin-latte`.
