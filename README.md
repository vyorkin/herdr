# herdr

My [herdr](https://herdr.dev) config, tuned to feel like my [tmux.conf](https://github.com/vyorkin/tmux.conf).

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
| `Alt + t` | Scratch shell popup |

Theme follows macOS appearance: `catppuccin` / `catppuccin-latte`.
