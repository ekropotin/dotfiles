# Hotkeys: one grammar, two machines

Home is Omarchy (Hyprland); work is a Mac. The same ZSA Voyager keyboard is
used on both, so there's no `fn` key to lean on. This doc explains *why* the
keys are laid out the way they are, for a person rather than as a config
dump.

## 1. Goal

One mental model across Omarchy and the Mac, so muscle memory survives
switching machines. The same physical keyboard is in front of you either
way — only the modifier that means "window manager" changes.

## 2. Principles

- Omarchy defaults are the baseline. Diverge only with a reason.
- Each modifier layer has one meaning:
  - **SUPER** = primary action
  - **+SHIFT** = move/act on the thing (and app launchers)
  - **+ALT** = variant/quieter
  - **+CTRL** = system panels
  - bare CTRL/ALT = left to apps
- Letters keep their meaning across layers: `I` = image, `D` = display,
  `M` = monocle, `R` = rotate, `hjkl` = direction, digits = workspaces.
- The compositor owns the SUPER layer. Terminal editing keys are sacred:
  ⌥B/F/D, ⌃A/E/W must never be shadowed.
- In-app tab navigation is Ctrl+Tab everywhere. kitty passes it through to
  herdr.
- Scope discipline: bind only daily flows. Don't port a feature that has no
  twin on the other machine.

## 3. Mac translation

The rule: **`SUPER → ⌃⌥`, `+SHIFT → +⇧`, and any extra ALT or CTRL → `+⌘`.**

### Why ⌃⌥

The choice is by elimination:

1. **The base must leave room for the grammar layers.** Shift can't be part
   of it — it's the "move/act on the thing" layer. It has to be two keys,
   since there's no `fn` on the Voyager and bare ⌘ is the Mac app layer.
   Without Shift, the only two-key options are ⌃⌥, ⌃⌘ and ⌥⌘, and each
   leaves one spare modifier for the ALT/CTRL variant layer. The Voyager's
   Meh and Hyper keys are out because they already include Shift.
2. **Of those, only ⌃⌥ is mostly left alone by macOS and apps:**

   | Base | Collides with |
   |---|---|
   | ⌥⌘ | Heavily used. System: ⌥⌘H hide others, ⌥⌘D dock, ⌥⌘Esc force quit. Browsers: ⌥⌘I/J devtools, ⌥⌘←→ tabs. JetBrains: ⌥⌘L reformat |
   | ⌃⌘ | System-owned: ⌃⌘F fullscreen, ⌃⌘Q lock screen, ⌃⌘Space emoji, ⌃⌘D dictionary. Hits D (send to display) directly |
   | **⌃⌥** | macOS only uses ⌃⌥Space (input source, can be disabled) and VoiceOver (only when enabled). Rectangle and Magnet default to it, so apps tend to avoid it. The cost is a few JetBrains chords |
3. **It doesn't hurt the terminal.** Terminals rarely use ⌃⌥+letter, and
   ⌥B, ⌥F, ⌥D and ⌃A/E/W stay free. This fixes the problem with bare-`alt`
   skhd, which collided with kitty's `macos_option_as_alt yes`
   (`alt-f` zoom, `alt-b` balance, `alt-d` display all stole word
   navigation).
4. **It's ergonomic on the Voyager.** An Oryx thumb key can send
   LCtrl+LAlt on hold, so it's one press, like SUPER.

**Accepted cost:** SUPER+ALT and SUPER+CTRL both collapse onto `+⌘`. That's
fine for the scoped flows below, where only `I` and `V` use those layers. A
future letter present in both layers would collide — e.g. SUPER+ALT+S and
SUPER+CTRL+S would both become ⌃⌥⌘S.

**Rejected alternative:** a Voyager key sends F18 and Karabiner turns it
into a virtual SUPER. That gives a true 1:1 grammar, but costs the Karabiner
driver (a work MDM risk) plus a config to maintain.

Bare ⌘ is the Mac app layer, roughly Omarchy's SUPER+C/V/X.

**Literal exceptions:** ⌘Tab and ⌘Space keep their native meaning on the
Mac — the Mac already has the same key doing the same job, so there's
nothing to translate.

## 4. Chord map

| Flow | Omarchy | Mac | Mac handled by |
|---|---|---|---|
| Monocle ⇄ dwindle | SUPER+M | ⌃⌥M | skhd → toggle-layout.sh (stack ⇄ bsp) |
| Rotate | SUPER+R | ⌃⌥R | skhd → `yabai -m space --rotate 270` |
| Send window to/back from other display | SUPER+D | ⌃⌥D | skhd → `--display recent` + focus |
| Focus hjkl | SUPER+HJKL | ⌃⌥HJKL | skhd → yabai focus |
| Switch workspace N | SUPER+N | ⌃⌥N | skhd → `yabai -m space --focus N` |
| Send window to workspace N | SUPER+SHIFT+N | ⌃⌥⇧N | skhd → `window --space N` + focus, following the window like Omarchy |
| Window/app switcher | SUPER+Tab / +Shift → OmaSwitch | ⌘Tab (native) | macOS |
| Clipboard history | SUPER+CTRL+V | ⌃⌥⌘V | Alfred hotkey (manual setting) |
| Quick actions menu | SUPER+SPACE | ⌘Space (literal, like ⌘Tab) | Alfred hotkey (manual setting) |
| Push-to-talk | SUPER+\` | ⌃⌥\` | Wispr Flow hotkey (manual setting) |
| Region → file | SUPER+I | ⌃⌥I | skhd → `screencapture -i <file>` |
| Region → clipboard | SUPER+ALT+I | ⌃⌥⌘I | skhd → `screencapture -ic` |
| Full screen → file | SUPER+SHIFT+I | ⌃⌥⇧I | skhd → `screencapture <file>` |
| Full screen → clipboard | SUPER+SHIFT+ALT+I | ⌃⌥⇧⌘I | skhd → `screencapture -c` |

skhd contains only the skhd-handled rows above. Every other mapping that
used to live there (focus kitty, mirror x/y, float toggle, zoom-fullscreen,
balance, swap on arrows, prev/next space) was removed and not re-homed,
because none of them served a scoped flow.

## 5. Known trade-offs

- ⌃⌥ shadows a few JetBrains Mac-keymap chords while skhd runs: ⌃⌥H call
  hierarchy, ⌃⌥I auto-indent, ⌃⌥R/⌃⌥D run/debug popups, ⌃⌥T surround.
- "Rotate" keeps the Mac's existing `--rotate 270` (whole tree). Omarchy's
  SUPER+R is `togglesplit` (parent split). They match for 2 windows but
  differ with 3 or more.
- Mac full-screen capture with a single filename grabs the main display.
  Omarchy grabs the focused monitor.

## 6. Where things live

- `~/.config/hypr/bindings.lua` plus `~/Work/omarchy-modifier-grammar.md`
  (the Omarchy-specific override log)
- `configs/mac/.config/skhd/skhdrc` and yabai
- App-side hotkeys (Alfred, Wispr) set in their own GUIs, not tracked here
