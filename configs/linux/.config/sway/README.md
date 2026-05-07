# Sway Config

## Mental Model

The goal is muscle-memory parity with macOS. The modifier story is split three ways:

- **Super (= Cmd)** — text editing and window/app actions: `Super+C/V/A/X/Z/W`, `Super+Tab`, `Super+Q`, launcher, terminal, screenshots, clipboard.
- **Alt** — Linux/Sway-specific: layout, workspaces, directional focus/move, resize.
- **Ctrl** — left untouched. Terminal/shell semantics (Ctrl+C interrupt, etc.) are preserved.

`Super+C/V/A/X/Z/W` are remapped to `Ctrl+C/V/A/X/Z/W` system-wide via [keyd](https://github.com/rvaiya/keyd) — see `configs/linux/etc/keyd/default.conf`. Super alone passes through unchanged so Sway still receives the Super combos listed below.

## Keybindings

### Text Editing & In-App Close (keyd → Ctrl)

These are not Sway bindings. keyd rewrites them at the input layer so every app that already understands `Ctrl+letter` gets a Cmd-style alias for free.

| Key | Action |
|---|---|
| `Super+C` / `Super+V` / `Super+X` | Copy / paste / cut |
| `Super+A` | Select all |
| `Super+Z` / `Super+Shift+Z` | Undo / redo |
| `Super+W` | In-app close (browser tab, editor doc) |

### Apps & System (Super)

| Key | Action |
|---|---|
| `Super+Return` | Open terminal (kitty) |
| `Super+Space` | App launcher (tofi) |
| `Super+Tab` | Cycle focus to next window |
| `Super+q` | Kill focused window (whole "app") |
| `Alt+Super+c` | Clipboard picker (cliphist) |
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

## Notes

- `Alt+Super+C` for cliphist is bound in Sway as `Ctrl+Mod1+c` — the physical chord stays the same; keyd has already rewritten the Super to Ctrl by the time Sway sees the event.
- `Super+C` (and the other text-editing keys) inside kitty/zsh sends `Ctrl+C` and will interrupt the foreground process — by design. Use mouse-drag (`copy_on_select`) or `Ctrl+Shift+C` for copying inside a terminal.
- Roll-back: `sudo systemctl stop keyd` restores raw key behavior immediately.
