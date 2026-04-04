# Sway Config

## Mental Model

- **Alt** — window and tiling management (focus, move, resize, layout, workspaces)
- **Super** — system and app actions (launch, kill, reload, exit, screenshots, clipboard)

## Keybindings

### Apps & System (Super)

| Key | Action |
|---|---|
| `Super+Return` | Open terminal (kitty) |
| `Super+Space` | App launcher (tofi) |
| `Super+q` | Kill focused window |
| `Alt+Super+c` | Clipboard picker |
| `Super+p` | Force display reprobe |
| `Super+Shift+r` | Reload sway config |
| `Super+Shift+e` | Exit sway |
| `F12` | Lock screen |
| `Shift+F12` | Suspend |

### Screenshots (Super)

| Key | Action |
|---|---|
| `Super+3` | Fullscreen screenshot to file |
| `Super+4` | Region screenshot to file |
| `Super+Shift+3` | Fullscreen screenshot to clipboard |
| `Super+Shift+4` | Region screenshot to clipboard |

### Focus (Alt)

| Key | Action |
|---|---|
| `Alt+h/j/k/l` | Focus left/down/up/right |
| `Alt+Left/Down/Up/Right` | Focus left/down/up/right |
| `Alt+Tab` | Cycle focus to next window |
| `Alt+a` | Focus parent container |
| `Alt+d` | Focus child container |
| `Alt+Space` | Toggle focus between tiling/floating |

### Move Windows (Alt)

| Key | Action |
|---|---|
| `Alt+Shift+h/j/k/l` | Move window left/down/up/right |
| `Alt+Shift+Left/Down/Up/Right` | Move window left/down/up/right |

### Layout (Alt)

| Key | Action |
|---|---|
| `Alt+b` | Split horizontal |
| `Alt+v` | Split vertical |
| `Alt+f` | Toggle fullscreen |
| `Alt+s` | Stacking layout |
| `Alt+w` | Tabbed layout |
| `Alt+e` | Toggle split direction (horizontal/vertical) |
| `Alt+Shift+f` | Toggle floating (resizes to 1344x756) |

### Workspaces (Alt)

| Key | Action |
|---|---|
| `Alt+1-5` | Switch to workspace |
| `Alt+Shift+1-5` | Move window to workspace |

### Resize Mode (Alt)

| Key | Action |
|---|---|
| `Alt+r` | Enter resize mode |
| `h/j/k/l` | Shrink width / grow height / shrink height / grow width |
| `Left/Down/Up/Right` | Same as above |
| `Escape` / `Enter` / `Alt+r` | Exit resize mode |
