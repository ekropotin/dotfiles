-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Toggle window floating/tiling, unused -- it's easy to hit by accident
-- (e.g. reaching for SUPER+TAB) and leaves a window stuck floating, invisible
-- to dwindle/monocle until toggled back.
hl.unbind("SUPER + T")

-- Voxtype push-to-talk on SUPER+` instead of the default F9. SUPER is
-- compositor-reserved, so unlike a bare F-key it cannot collide with whatever
-- app has focus.
--
-- Do NOT add ignore_mods here. It skips the modifier-mask check, so the release
-- bind then matches GRAVE under any modifiers -- swallowing bare backtick and
-- SHIFT+GRAVE (tilde) system-wide. ignore_mods is only safe on a key that is
-- not a printable character.
--
-- The tradeoff: releasing SUPER before the backtick may leave the recorder
-- running, since the release bind no longer matches. Recover with SUPER+CTRL+X
-- (toggle dictation) or `voxtype record stop`.
hl.unbind("F9")
o.bind("SUPER + GRAVE", "Start dictation (push-to-talk)", "voxtype record start")
o.bind("SUPER + GRAVE", "Stop dictation (push-to-talk)", "voxtype record stop", { release = true })

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- ---------------------------------------------------------------------------
-- Vim-style window focus on SUPER + HJKL
-- ---------------------------------------------------------------------------
-- Focus moves to SUPER+HJKL; SUPER+arrows is freed up for swap below, since
-- it was redundant with this. SUPER+H was already free; the other three
-- defaults are re-homed just below.
hl.unbind("SUPER + J") -- was: Toggle window split
hl.unbind("SUPER + K") -- was: Keybindings
hl.unbind("SUPER + L") -- was: Toggle workspace layout (locally: monocle toggle)

o.bind("SUPER + H", "Focus on left window", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + J", "Focus on below window", hl.dsp.focus({ direction = "d" }))
o.bind("SUPER + K", "Focus on above window", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + L", "Focus on right window", hl.dsp.focus({ direction = "r" }))

-- ---------------------------------------------------------------------------
-- Swap window with neighbour on bare SUPER + arrows
-- ---------------------------------------------------------------------------
-- Mirrors the Mac's bare ctrl+alt+arrows (docs/hotkeys.md section 4). Direction
-- is split by key group on both machines: hjkl moves focus, arrows swap the
-- window with its neighbour -- so this replaces the stock movefocus on
-- SUPER+arrows, which duplicated SUPER+HJKL above. Hyprland does not replace
-- a bind on re-registration -- it stacks both -- so the stock focus binds are
-- unbound explicitly first. Bare SUPER rather than SUPER+SHIFT mirrors the
-- Mac, at the cost of the "+SHIFT acts on the thing" reading of the grammar
-- for this one flow. SUPER+SHIFT+arrows keeps doing the same swap stock
-- already bound there.
hl.unbind("SUPER + LEFT")  -- was: Focus on left window
hl.unbind("SUPER + RIGHT") -- was: Focus on right window
hl.unbind("SUPER + UP")    -- was: Focus on above window
hl.unbind("SUPER + DOWN")  -- was: Focus on below window

o.bind("SUPER + LEFT", "Swap window to the left", hl.dsp.window.swap({ direction = "l" }))
o.bind("SUPER + RIGHT", "Swap window to the right", hl.dsp.window.swap({ direction = "r" }))
o.bind("SUPER + UP", "Swap window up", hl.dsp.window.swap({ direction = "u" }))
o.bind("SUPER + DOWN", "Swap window down", hl.dsp.window.swap({ direction = "d" }))

-- Re-homed from SUPER+J. R for "rotate".
o.bind("SUPER + R", "Toggle window split", hl.dsp.layout("togglesplit"))

-- Re-homed from SUPER+L. M for "monocle"; toggles dwindle <-> monocle rather
-- than Omarchy's stock dwindle <-> scrolling.
o.bind("SUPER + M", "Toggle workspace layout", "omarchy-monocle-toggle")

-- Re-homed from SUPER+K onto SLASH, freed by moving monitor scaling to -/=.
hl.unbind("SUPER + SLASH")       -- was: Monitor scaling up
hl.unbind("SUPER + ALT + SLASH") -- was: Monitor scaling down
o.bind("SUPER + SLASH", "Keybindings", "omarchy-menu-keybindings")

-- ---------------------------------------------------------------------------
-- Monitor scaling on SUPER + -/=
-- ---------------------------------------------------------------------------
-- code:20 is MINUS, code:21 is EQUAL -- match the keycodes stock Omarchy uses,
-- or the unbinds below will not find the defaults.
hl.unbind("SUPER + code:20") -- was: Expand window left
hl.unbind("SUPER + code:21") -- was: Shrink window left

o.bind("SUPER + code:21", "Monitor scaling up", "omarchy-hyprland-monitor-scaling up")
o.bind("SUPER + code:20", "Monitor scaling down", "omarchy-hyprland-monitor-scaling down")

-- The displaced normal-depth horizontal resize lands on SUPER+CTRL+ALT. The
-- "a little" (ALT), "a lot" (CTRL) and vertical (SHIFT) resize layers are
-- untouched.
o.bind("SUPER + CTRL + ALT + code:20", "Expand window left", hl.dsp.window.resize({ x = -100, y = 0, relative = true }))
o.bind("SUPER + CTRL + ALT + code:21", "Shrink window left", hl.dsp.window.resize({ x = 100, y = 0, relative = true }))

-- Layout-aware window cycling.
-- Omarchy binds ALT+TAB to window.cycle_next(), which monocle ignores -- monocle
-- only responds to its own "cyclenext"/"cycleprev" layout messages, and those in
-- turn are rejected by dwindle. Branch on the active workspace's layout.
local function cycle_windows(forward)
  return function()
    local ws = hl.get_active_workspace()
    if ws and ws.tiled_layout == "monocle" then
      hl.dispatch(hl.dsp.layout(forward and "cyclenext" or "cycleprev"))
    else
      hl.dispatch(hl.dsp.window.cycle_next({ next = forward }))
      hl.dispatch(hl.dsp.window.bring_to_top())
    end
  end
end

-- OmaSwitch moves from ALT+TAB to SUPER+TAB, to match the Mac's native
-- Cmd+Tab (SUPER translates to Ctrl+Alt there). SUPER+TAB and
-- SUPER+SHIFT+TAB were stock next/previous workspace; SUPER+CTRL+TAB
-- (former workspace) is untouched and stays stock.
hl.unbind("SUPER + TAB")         -- was: Next workspace
hl.unbind("SUPER + SHIFT + TAB") -- was: Previous workspace
o.bind("SUPER + TAB", "OmaSwitch", "omarchy-shell shell summon piyush.omaswitch '{\"mode\":\"cycle\",\"direction\":1}'")
o.bind("SUPER + SHIFT + TAB", "OmaSwitch (reverse)", "omarchy-shell shell summon piyush.omaswitch '{\"mode\":\"cycle\",\"direction\":-1}'")

-- ALT+TAB ends up unbound -- it used to run OmaSwitch, now moved to SUPER+TAB.
hl.unbind("ALT + TAB")
hl.unbind("ALT + SHIFT + TAB")
-- o.bind("ALT + TAB", "Focus on next window", cycle_windows(true))
-- o.bind("ALT + SHIFT + TAB", "Focus on previous window", cycle_windows(false))

-- ---------------------------------------------------------------------------
-- SUPER+D, send window to the other monitor ("D" for "display")
-- ---------------------------------------------------------------------------
-- hl.dsp.window.move has no `monitor` argument -- only direction, x/y,
-- workspace, into_group and out_of_group -- so this moves the window onto
-- the target monitor's active workspace instead, which follows it there like
-- the stock SUPER+SHIFT+N workspace-move chords. Matches SUPER+CTRL+D
-- "Display" on the Mac.
local function send_window_to_other_monitor()
  local monitors = hl.get_monitors()
  local active = hl.get_active_monitor()
  if not active or #monitors < 2 then
    return
  end

  table.sort(monitors, function(a, b)
    return a.id < b.id
  end)

  local active_index
  for i, monitor in ipairs(monitors) do
    if monitor.id == active.id then
      active_index = i
      break
    end
  end
  if not active_index then
    return
  end

  local target = monitors[(active_index % #monitors) + 1]
  hl.dispatch(hl.dsp.window.move({ workspace = tostring(target.active_workspace.id) }))
end

o.bind("SUPER + D", "Send window to other monitor", send_window_to_other_monitor)

-- ---------------------------------------------------------------------------
-- Screenshots on SUPER+I ("image")
-- ---------------------------------------------------------------------------
-- The stock capture family lives on PRINT, which the ZSA Voyager has no key
-- for. Base action writes a file; the ALT variant is the quieter one that only
-- touches the clipboard. Omarchy's own PRINT binding does both at once.
--
-- While the region picker is open, RETURN grabs the highlighted window,
-- CTRL+RETURN grabs the whole screen, and TAB/arrows pick a window -- so one
-- chord covers region, window and fullscreen captures.
--
-- Still unreachable without a PRINT key: ALT+PRINT (screen recording),
-- SUPER+PRINT (color picker), SUPER+CTRL+PRINT (OCR). SUPER+CTRL+C opens the
-- capture menu, which reaches all of them.
o.bind("SUPER + I", "Screenshot region to file", "omarchy-capture-screenshot region save")
o.bind("SUPER + ALT + I", "Screenshot region to clipboard", "omarchy-capture-screenshot region copy")

-- Full-screen variants, for the cross-machine chord map. "fullscreen" grabs
-- the focused monitor with no picker (unlike the Mac, which grabs the main
-- display for a single-file capture).
o.bind("SUPER + SHIFT + I", "Screenshot fullscreen to file", "omarchy-capture-screenshot fullscreen save")
o.bind("SUPER + SHIFT + ALT + I", "Screenshot fullscreen to clipboard", "omarchy-capture-screenshot fullscreen copy")

-- ---------------------------------------------------------------------------
-- Herdr takes tmux's slots on SUPER+ALT+RETURN and SUPER+ALT+K
-- ---------------------------------------------------------------------------
-- Fits the grammar: ALT is the terminal-flavor variant, and CTRL is reserved
-- for system panels. tmux is gone, so its SUPER+ALT slots move to herdr and
-- its own former SUPER+CTRL slots are freed rather than re-homed.
hl.unbind("SUPER + ALT + RETURN")  -- was: Tmux
hl.unbind("SUPER + CTRL + RETURN") -- was: Herdr
o.bind("SUPER + ALT + RETURN", "Herdr", { omarchy = "terminal-herdr" })

hl.unbind("SUPER + ALT + K")  -- was: Tmux keybindings
hl.unbind("SUPER + CTRL + K") -- was: Herdr keybindings
o.bind("SUPER + ALT + K", "Herdr keybindings", "omarchy-menu-herdr-keybindings")
