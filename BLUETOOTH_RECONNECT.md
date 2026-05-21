# Bluetooth: BLE mouse won't reconnect after long suspend

## Problem

A Logitech LIFT (BLE) mouse periodically fails to reconnect — most often
after the laptop has been in a long sleep. Symptoms observed:

- `bluetoothctl` shows the mouse `Paired: yes / Trusted: yes / Connected: no`.
- Manually restarting `bluetooth.service` does **not** bring it back.
- Active scans sometimes show **no** Logitech advertisements at all.
- Re-pairing (holding the Easy-Switch button) works, but only because it
  forces the mouse on-air again — the symptom returns after the next sleep.

Hardware: Qualcomm Atheros ROME controller (`qca/rampatch_usb_00130200`,
USB id `0489:e0d0`). All sleeps are deep suspend (S3, `PM: suspend entry
(deep)`), not hibernate — a multi-day S3 just feels like hibernate.

## Root cause

A BLE peripheral like the LIFT only advertises for a brief moment when you
touch it. BlueZ re-attaches a bonded HID device **only while the host is
actively initiating a connection and catches that advertisement**.

`btmon` capture settled host-vs-mouse: when the host was initiating, a
click produced an advertisement, the host connected, and encryption came up
(`Encryption: Enabled with AES-CCM`). So the controller and the bond were
healthy the whole time.

The failure chain after a long suspend:

1. On suspend the link drops; on resume BlueZ retries on its
   `ReconnectIntervals` schedule (`1,2,4,…,64s`, ~2 min total) and then
   gives up — it stops initiating for that device.
2. By the time you actually use the laptop, nothing host-side is trying to
   connect anymore.
3. Your clicks make the mouse advertise, but they land on a host that
   isn't initiating — so nothing reconnects.

This is why a manual `systemctl restart bluetooth` at an idle moment did
nothing: it doesn't make a silent host start initiating at the instant the
mouse happens to advertise.

## Solution

Three layers, all tracked in this repo and re-applied by
`setup_dotfiles.sh` → `setup_bluetooth()`:

| Layer | Purpose | File |
|---|---|---|
| Kernel | Keep the controller awake so brief advertisement windows aren't missed (disables USB autosuspend for `0489:e0d0` only) | `configs/linux/etc/udev/rules.d/50-bluetooth-no-autosuspend.rules` (symlinked) |
| BlueZ | `Experimental = true` (AdvertisementMonitor offload), `FastConnectable`, and a reconnect `[Policy]` | `configs/linux/etc/bluetooth/main.conf` (installed as a real file) |
| Resume | The actual fix: on every wake, retry `bluetoothctl connect <mac>` against each bonded device for ~2 minutes, so the first click re-attaches the mouse | `configs/linux/etc/systemd/system/bt-resume-reconnect.service` + `configs/linux/etc/bluetooth/resume-reconnect.sh` |

> **Earlier approach that didn't work — and why.** The resume hook first ran
> `bluetoothctl --timeout 120 scan le`, on the theory that "bonded devices
> auto-reconnect on sight" during discovery. They don't. A passive LE
> discovery only *reports* advertisements; it never *initiates* a connection
> to a bonded HID device. Observed directly: after a resume the hook scanned
> for the full 120s with the LIFT still `Connected: no`, yet a plain
> `bluetoothctl connect D7:85:1B:A3:96:BE` reconnected it instantly. So the
> hook now loops explicit `connect` attempts instead — `connect` puts the
> controller in the LE *initiating* state, so the pending attempt latches on
> the moment the mouse advertises (the first click).

### Notes / gotchas

- **`main.conf` must be a real file, not a symlink.** `bluetoothd`'s unit
  sets `ProtectHome=true`, so a symlink into `~/sources/dotfiles` is
  unreadable to the daemon and it logs
  `load_config() Parsing /etc/bluetooth/main.conf failed: Permission denied`.
  The udev rule, by contrast, is fine as a symlink (udev has no such
  sandbox). `setup_bluetooth()` `install`s the config and the systemd unit
  as real files, and symlinks the udev rule.
- The resume service uses the canonical Arch sleep-hook pattern
  (`After=` + `WantedBy=` the sleep targets) so it fires on **resume**, not
  on the way into suspend.
- The script enumerates bonded devices with `bluetoothctl devices Bonded`
  and time-boxes each `connect` with `timeout 6` (a not-yet-advertising
  device makes `connect` hang until the controller gives up, so we move on
  and retry). It exits early once everything bonded is connected.
  `TimeoutStartSec=150` in the unit gives systemd headroom beyond the
  ~120s retry loop.

### How to use it

After waking from a long sleep, just **click the mouse within ~2 minutes**;
it reconnects on its own. No manual commands.

### Limits

- If you don't touch the mouse within the discovery window it won't
  reconnect until you do something. If 2 minutes is too short, raise
  `DEADLINE` in `resume-reconnect.sh` and bump `TimeoutStartSec` to match.
- If the mouse is genuinely silent (dead battery / wrong Easy-Switch
  channel) nothing host-side can help — but `btmon` confirmed this mouse
  advertises fine on a click.

### Verifying / debugging

```bash
# Is the controller kept awake?
cat /sys/class/bluetooth/hci0/device/../power/control      # -> on

# Did main.conf load (Experimental active)?
bluetoothctl show | grep -iA3 'Advertisement Monitor'      # lists supported types

# Is the resume hook enabled?
systemctl is-enabled bt-resume-reconnect.service           # -> enabled

# Watch raw HCI to confirm the mouse advertises on a click:
sudo btmon        # then click the mouse; look for the device address + "LIFT"
```
