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
  `M` = monocle, `R` = rotate, digits = workspaces.
- Direction is split by key group, the same way on both machines: `hjkl`
  moves **focus**, arrows **swap** the window with its neighbour. Arrows are
  not a second way to move focus.
- The compositor owns the SUPER layer. Terminal editing keys are sacred:
  ⌥B/F/D, ⌃A/E/W must never be shadowed.
- **The OS owns what the OS can already do.** A chord only goes in skhd if
  it drives yabai. If macOS has a native equivalent — switching desktops,
  screenshots — it's bound in System Settings, and if an app owns it —
  Alfred, Wispr Flow — it's bound in that app. One chord, one owner, and
  the owner is the lowest layer that can do the job.
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
   | **⌃⌥** | macOS only uses ⌃⌥Space (input source) and VoiceOver (only when enabled). Rectangle and Magnet default to it, so apps tend to avoid it. The cost is a few JetBrains chords |
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

**One live ⌃⌥ collision:** ⌃⌥Space is macOS's "Select next input source"
and is currently enabled. Nothing in the grammar uses it, so it's left
alone; disable it in Keyboard > Input Sources if a ⌃⌥Space flow ever
appears.

**macOS wins ties, so a collision is fatal, not cosmetic.** A system
shortcut consumes the chord before skhd's event tap sees it — ⌃⌥D did
nothing at all until *Move right a space* was unbound from it, with no error
anywhere to explain why. Whenever a new chord appears dead, suspect System
Settings first. §6 has a way to test it.

**macOS 26's window tiling does not use ⌃⌥+arrows** — worth knowing, since
Sequoia's tiling was the obvious threat to the arrow bindings. Its shortcut
group (Fill, Center, halves, quarters, Arrange, Full Screen Tile) is real but
lives elsewhere, and all four ⌃⌥ arrows were confirmed to reach skhd.

## 4. Chord map

Grouped by owner, per the "lowest layer that can do the job" principle.

### skhd → yabai

The whole of `configs/mac/.config/skhd/skhdrc`. Every one of these is
reachable through the public Accessibility API, so none needs the scripting
addition.

| Flow | Omarchy | Mac | Command |
|---|---|---|---|
| Monocle ⇄ dwindle | SUPER+M | ⌃⌥M | `toggle-layout.sh` (stack ⇄ bsp, per space) |
| Rotate | SUPER+R | ⌃⌥R | `yabai -m space --rotate 270` |
| Send window to next display | SUPER+D | ⌃⌥D | `throw-to-display.sh` (float, reframe, re-tile — see §5) |
| Focus hjkl | SUPER+HJKL | ⌃⌥HJKL | `yabai -m window --focus <dir>` |
| Swap window with neighbour | SUPER + arrows † | ⌃⌥ + arrows | `yabai -m window --swap <dir>` — tiling layouts only |

† The Mac half is live. The Omarchy half is four `o.rebind` entries in
`bindings.lua` calling `hyprctl dispatch swapwindow l/d/u/r`, and is **not
applied yet**. It *replaces* Omarchy's default `movefocus` on SUPER+arrows,
which was redundant with SUPER+hjkl — so no `hl.unbind` is needed. Bare SUPER
rather than SUPER+SHIFT mirrors the Mac, at the cost of the "+SHIFT acts on
the thing" reading of §2.

### macOS System Settings

Set by hand in **Keyboard > Keyboard Shortcuts**; not tracked in this repo
(see §6). macOS does these natively and needs no window manager for them.

| Flow | Omarchy | Mac | Settings pane → shortcut |
|---|---|---|---|
| Switch workspace 1-5 | SUPER+N | ⌃⌥1-5 ¶ | Mission Control → *Switch to Desktop N* |
| Region → file | SUPER+I | ⌃⌥I ¶ | Screenshots → *Save picture of selected area as a file* |
| Region → clipboard | SUPER+ALT+I | ⌃⌥⌘I ¶ | Screenshots → *Copy picture of selected area to the clipboard* |
| Full screen → file | SUPER+SHIFT+I | ⌃⌥⇧I ¶ | Screenshots → *Save picture of screen as a file* |
| Full screen → clipboard | SUPER+SHIFT+ALT+I | ⌃⌥⇧⌘I ¶ | Screenshots → *Copy picture of screen to the clipboard* |

¶ Verified live against `com.apple.symbolichotkeys`: *Switch to Desktop 1-5*
on ⌃⌥1-5, and all four Screenshots rows on the ⌃⌥I family. Five is the whole
working set, so the digit row deliberately stops there rather than running to
9 — §2 scope discipline. *Switch to Desktop 6* is pre-filled with ⌃⌥6 but
left **disabled**, so it's one checkbox away if a sixth ever earns its place.
Re-verify with the `defaults read` in §6 rather than trusting this table.

*Switch to Desktop N* only appears in Settings for desktops that already
exist, so create the spaces first, then bind. "Displays have separate
Spaces" is on, so the shortcut acts on the focused display.

### App-owned

Set as each app's own global hotkey, and deliberately absent from skhd so
they pass through.

| Flow | Omarchy | Mac | Owner |
|---|---|---|---|
| Clipboard history | SUPER+CTRL+V | ⌃⌥⌘V | Alfred |
| Quick actions menu | SUPER+SPACE | ⌘Space (literal, like ⌘Tab) | Alfred |
| Push-to-talk | SUPER+\` | ⌃⌥\` | Wispr Flow |
| Window/app switcher | SUPER+Tab / +Shift → OmaSwitch | ⌘Tab (native) | macOS |

Alfred's two chords are verified against
`Alfred.alfredpreferences/preferences/features/*/prefs.plist` — clipboard
history on ⌃⌥⌘V, main hotkey on ⌘Space. That bundle lives in OneDrive, not
this repo, so it syncs between machines but isn't version-controlled here.
Wispr Flow's chord is **unverified**: its config is `flow.sqlite`, which has
no settings table, so ⌃⌥\` above is the intent rather than a reading.

### Not available on the Mac

| Flow | Omarchy | Why not |
|---|---|---|
| Send window to workspace N | SUPER+SHIFT+N | Needs yabai's scripting addition, and macOS has no native shortcut for it either (§5) |

Earlier revisions of skhdrc also bound focus-kitty, mirror x/y, float
toggle, zoom-fullscreen, balance and prev/next space. Those were removed and
not re-homed, because none served a scoped flow. Swap-on-arrows was removed
with them and later brought back deliberately, once it had a twin on both
machines.

## 5. Known trade-offs

- **Send-window-to-workspace has no Mac counterpart.** Which space a window
  belongs to is opaque window-server state with no public API, so yabai
  changes it with private `CGS` calls that only work from inside `Dock.app` —
  the "scripting addition" — which needs SIP partially disabled. This is a
  DEP-enrolled, Jamf-managed machine with SIP enabled, and disabling it would
  drop the volume to Reduced Security, which fleet tooling reports on. macOS
  has no native shortcut for the flow either (dragging in Mission Control is
  the only way), so there is nowhere to re-home it. It's simply absent.
  - Worth knowing if you ever revisit this: `space --focus` fails loudly
    (`cannot focus space due to an error with the scripting-addition`), but
    `window --space` and `window --display` fail **silently** — exit 0, no
    movement, nothing in any log.
- **Send-window-to-display looks like the same problem but isn't, which is why
  ⌃⌥D still works.** Displays, unlike spaces, are just regions of one global
  coordinate plane, and a window's frame is a public, settable Accessibility
  attribute. Put the frame inside the other display's rect and the window
  server reassigns the space membership itself. `throw-to-display.sh` does
  exactly that; yabai's own `window --display` routes through the space-move
  path instead, which is why *it* needs the injection.
  - yabai refuses `--move abs` on a window it manages (`cannot move a managed
    window`), so the script floats the window, reframes it, and re-tiles it.
    It lands tiled on the far display, and rejoins the stack when sent back.
  - **It depends on the window keeping focus, and that's a real fragility.**
    yabai's tree learns the new space from the focus event. If focus leaves
    the window before the tree catches up, the stale tree wins and the window
    is dragged home on the next reflow — silently, with no error. Observed
    twice: once by reframing a non-focused window, and once by throwing two
    windows in quick succession, where focus bounced to a third window on the
    origin display and *both* thrown windows returned on the next layout
    change. Interactively this is fine, since the chord acts on the window you
    are looking at and it keeps focus. Don't script it in a loop, and don't
    expect a throw to survive if you immediately click elsewhere.
- **Swap is arrows, focus is hjkl**, on both machines. Keeping them on
  different key groups means neither needs a modifier change mid-gesture, at
  the cost of `hjkl` no longer being the only direction idiom. On Omarchy this
  costs the default `movefocus` on SUPER+arrows, which duplicated SUPER+hjkl.
  `--swap` is a tree operation, so it only means anything in a tiling layout —
  in a `stack` space it exits 1 with `could not locate a <dir>ward managed
  window` and nothing moves, which makes the chord harmless to press by
  reflex.
- **⌃⌥ shadows some JetBrains Mac-keymap chords, and the two layers differ
  in how recoverable that is.**
  - *System-level, unconditional:* ⌃⌥I (auto-indent lines) is now a macOS
    screenshot shortcut. Since system shortcuts consume a chord before
    anything else sees it (§3), JetBrains never receives it — stopping skhd
    doesn't help, and the only fix is to rebind one side.
  - *skhd-level, only while skhd runs:* ⌃⌥H (call hierarchy), ⌃⌥R (run…) and
    ⌃⌥D (debug…). `skhd --stop-service` hands these back.
  - The focus keys (⌃⌥J/K/L) and the ⌃⌥1-5 desktop switches may hit other
    chords depending on your keymap. Check a specific one in JetBrains under
    Settings > Keymap by searching the chord — a hand-maintained list here
    goes stale the moment either side is rebound.
- Native screenshots name files macOS-style (`Screenshot 2026-09-11 at
  17.22.19.png`) rather than the `screenshot-region-<timestamp>.png` the old
  skhd bindings produced. Traded for not having to shell out through skhd,
  which also removes a `defaults read com.apple.screencapture location`
  fallback and a Screen Recording permission question for skhd's children.
- "Rotate" keeps the Mac's existing `--rotate 270` (whole tree). Omarchy's
  SUPER+R is `togglesplit` (parent split). They match for 2 windows but
  differ with 3 or more.

## 6. Where things live

- `~/.config/hypr/bindings.lua` plus `~/Work/omarchy-modifier-grammar.md`
  (the Omarchy-specific override log)
- `configs/mac/.config/skhd/skhdrc` and `configs/mac/.config/yabai/`
- **Untracked, set by hand:** the Mission Control and Screenshots shortcuts
  in System Settings > Keyboard > Keyboard Shortcuts, and the Alfred and
  Wispr Flow hotkeys in their own GUIs. §4 is the record of what they should
  be; re-set them after a rebuild.
- Mission Control's *Move left a space* and *Move right a space* (two
  modifier variants each, symbolic hotkeys 79-82) must stay **disabled**.
  macOS ships them on ⌃←/⌃→; they had been customised to ⌃⌥C/⌃⌥D on this
  machine, which contested ⌃⌥D with skhd. Prev/next space is dropped
  deliberately: Omarchy has no twin for it, and `D` belongs to *display*.
- These all live in `com.apple.symbolichotkeys`. It **can** be scripted, with
  one trap: `defaults write -dict-add` with inline dict syntax stores the
  parameter triplets as *strings*, which the Settings pane won't read. Export
  the whole domain, edit it as a typed plist, and import it back:
  `defaults export com.apple.symbolichotkeys -` … `defaults import`. Then run
  `activateSettings -u` (in
  `/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/`)
  or the change won't take effect until you log out.
- To see what is *actually* bound rather than what §4 intends:
  `defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys`. Entries that
  are absent are still at their macOS defaults. Decoding needs the modifier
  masks — ⇧131072, ⌃262144, ⌥524288, ⌘1048576, summed — and a virtual
  keycode, in the order `(ascii, keycode, mask)`.
- To test whether a chord even reaches skhd, bind it to something inert and
  observable rather than guessing — `ctrl + alt - left : touch /tmp/probe`,
  `skhd --restart-service`, then `skhd -k "ctrl + alt - left"`. A missing file
  means the system swallowed the chord. Note that `skhd -V` is *not* a version
  flag; it starts a second daemon.
- After editing `skhdrc`, run `skhd --restart-service`. Its config
  hot-reload does not reliably survive the file being replaced by a checkout.
