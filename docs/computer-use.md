# GUI Automation & Computer-Use on COSMIC Wayland

Reference notes for driving GUI applications, capturing screenshots, and injecting mouse/keyboard input on this machine (`Desktop`).

## Environment Summary

| Property | Value |
|----------|-------|
| Compositor | COSMIC (`cosmic-comp`) on Wayland (`WAYLAND_DISPLAY=wayland-1`, Xwayland `DISPLAY=:1`) |
| Total Canvas | `4480x1440` dual-monitor layout |
| Left Monitor | `2560x1440` (`x = 0..2560`, `y = 0..1440`) |
| Right Monitor | `1920x1440` (`x = 2560..4480`, `y = 0..1440`) |
| Orca CLI Shim | `ORCA_CLI_COMMAND=/home/kbb/.config/orca/linux-orca-cli-shim/orca` |
| GI / AT-SPI Python | `/nix/store/z81av5a19scxkg2jfp7rzz275lkc3xdk-python3-3.14.8-env/bin/python3.14` (`Atspi`, `Gdk`, `GdkPixbuf`) |

---

## 1. Limitations of `orca computer` on COSMIC Wayland

1. **AT-SPI Visibility (`list apps`, `window list`, `snapshot`)**:
   - `orca-computer-use-linux` discovers applications via AT-SPI (`Atspi.get_desktop(0)`). Note: the subcommands are `orca computer list apps` and `orca computer window list` (`list windows` is not a valid subcommand).
   - Native GTK/Qt apps register automatically, but Electron/Chromium apps (especially AppImages running inside `appimage-run` / `bwrap`, or browsers running natively on Wayland without accessibility flags) frequently do not appear on the AT-SPI bus unless launched with `--force-renderer-accessibility` or `ACCESSIBILITY_ENABLED=1`.
2. **Screenshots (`orca computer screenshot`)**:
   - Built-in screenshot commands in `orca-computer-use-linux` rely on X11 `Gdk.pixbuf_get_from_window()` and fail on Wayland.
3. **X11 Input Tools (`xdotool`)**:
   - `xdotool` only sees Xwayland windows and cannot move the global Wayland cursor or send input to native Wayland clients.

---

## 2. Capturing Screenshots (Non-Interactive)

Calling `org.freedesktop.portal.Screenshot` through the generic `xdg-desktop-portal` frontend can block waiting for interactive confirmation. Calling the **COSMIC portal backend** (`org.freedesktop.impl.portal.desktop.cosmic`) directly over D-Bus captures the entire `4480x1440` desktop immediately with no prompt:

```bash
timeout 5 busctl --user call \
  org.freedesktop.impl.portal.desktop.cosmic \
  /org/freedesktop/portal/desktop \
  org.freedesktop.impl.portal.Screenshot \
  Screenshot ossa{sv} \
  "/org/freedesktop/portal/desktop/request/1/req1" "" "" \
  2 "interactive" b false "modal" b false
```

This returns a `file:////tmp/screenshot-XXXXXX.png` URI (`4480x1440`).

### Cropping Per Monitor with `GdkPixbuf`

```bash
/nix/store/z81av5a19scxkg2jfp7rzz275lkc3xdk-python3-3.14.8-env/bin/python3.14 -c '
import gi
gi.require_version("GdkPixbuf", "2.0")
from gi.repository import GdkPixbuf

pb = GdkPixbuf.Pixbuf.new_from_file("/tmp/screenshot-XXXXXX.png")
# Left monitor (2560x1440)
pb.new_subpixbuf(0, 0, 2560, 1440).savev("/tmp/left-monitor.png", "png", [], [])
# Right monitor (1920x1440)
pb.new_subpixbuf(2560, 0, 1920, 1440).savev("/tmp/right-monitor.png", "png", [], [])
'
```

---

## 3. Injecting Mouse & Keyboard Input via `/dev/uinput`

`cosmic-comp` uses `libinput` for physical and virtual input devices. `/dev/uinput` is accessible without `sudo`, but `libinput` will silently ignore a virtual device unless `udevd`'s `input_id` builtin classifies it as a valid mouse (`ID_INPUT_MOUSE=1`) or keyboard (`ID_INPUT_KEYBOARD=1`).

### Critical `udev` & `libinput` Rules

1. **Never mix `EV_ABS` and keyboard keys on one device**:
   - A hybrid device with `ABS_X`/`ABS_Y` (`PROP=0`) and only a handful of keyboard keys is tagged with **neither** `ID_INPUT_MOUSE=1` nor `ID_INPUT_KEYBOARD=1` by `udev`, causing `cosmic-comp` to ignore all events from it.
   - Always create **separate** `/dev/uinput` file descriptors for relative mouse, absolute mouse, and keyboard.
2. **Required capability bits per device**:
   - **Relative Mouse (`ID_INPUT_MOUSE=1`)**:
     - `EV_SYN | EV_KEY | EV_REL`
     - Keys: `BTN_LEFT..BTN_TASK` (`0x110..0x114`)
     - Relative axes: `REL_X` (`0x00`), `REL_Y` (`0x01`)
   - **Absolute Mouse (`ID_INPUT_MOUSE=1`)**:
     - `EV_SYN | EV_KEY | EV_ABS`
     - Property bit: `UI_SET_PROPBIT` set to `INPUT_PROP_DIRECT` (`0x01`)
     - Keys: `BTN_LEFT..BTN_TASK` (`0x110..0x114`) only (no keyboard keys)
     - Absolute axes: `ABS_X` (`0..width`), `ABS_Y` (`0..height`)
   - **Keyboard (`ID_INPUT_KEYBOARD=1`)**:
     - `EV_SYN | EV_KEY | EV_REP`
     - Keys: enable all standard keycodes `1..248` (`input_id` requires a full keyboard bitmask of at least 32 standard keys to set `ID_INPUT_KEYBOARD=1`).
3. **Wait for `udev` and `cosmic-comp` registration**:
   - After calling `ioctl(fd, UI_DEV_CREATE)`, run `udevadm settle` and sleep `~0.8–1.0s` before writing events. Emitting events immediately after `UI_DEV_CREATE` drops them before `cosmic-comp` opens the `/dev/input/event*` node.
   - Verify classification if needed with `udevadm info -q property -n /dev/input/eventX`.

### Multi-Monitor Coordinate Mapping in `cosmic-comp`

`cosmic-comp` maps `PointerMotionAbsoluteEvent` (`EV_ABS`) to the **currently active output** (`geo.loc + event.position_transformed(geo.size)`), not the full `4480x1440` desktop:

1. Use the **relative mouse** (`EV_REL`) to push the cursor onto the target monitor so it becomes the active output:
   - Left monitor (`2560x1440`): send repeated `REL_X = -150` events.
   - Right monitor (`1920x1440`): send repeated `REL_X = +150` events.
2. Configure the **absolute mouse** (`EV_ABS`) with `absmax` matching that monitor's dimensions (`2560x1440` for left, `1920x1440` for right).
3. Send `ABS_X = x`, `ABS_Y = y` in that monitor's local pixel coordinates (`0..width`, `0..height`).

### Reusable Python `/dev/uinput` Template

```python
import os, fcntl, struct, time, subprocess

UI_SET_EVBIT   = 0x40045564
UI_SET_KEYBIT  = 0x40045565
UI_SET_RELBIT  = 0x40045566
UI_SET_ABSBIT  = 0x40045567
UI_SET_PROPBIT = 0x4004556e
UI_DEV_SETUP   = 0x405c5503
UI_ABS_SETUP   = 0x401c5504
UI_DEV_CREATE  = 0x5501
UI_DEV_DESTROY = 0x5502

EV_SYN, EV_KEY, EV_REL, EV_ABS, EV_REP = 0x00, 0x01, 0x02, 0x03, 0x14
SYN_REPORT = 0
REL_X, REL_Y = 0x00, 0x01
ABS_X, ABS_Y = 0x00, 0x01
INPUT_PROP_DIRECT = 0x01
BTN_LEFT = 0x110

def emit(fd, ev_type, code, val):
    now = time.time()
    sec = int(now)
    usec = int((now - sec) * 1_000_000)
    os.write(fd, struct.pack("llHHi", sec, usec, ev_type, code, val))

def syn(fd):
    emit(fd, EV_SYN, SYN_REPORT, 0)

def tap_key(fd, key):
    emit(fd, EV_KEY, key, 1); syn(fd); time.sleep(0.03)
    emit(fd, EV_KEY, key, 0); syn(fd); time.sleep(0.04)

def create_devices(mon_w=1920, mon_h=1440):
    # 1. Relative mouse
    fd_rel = os.open("/dev/uinput", os.O_WRONLY | os.O_NONBLOCK)
    for ev in (EV_SYN, EV_KEY, EV_REL):
        fcntl.ioctl(fd_rel, UI_SET_EVBIT, ev)
    for btn in range(0x110, 0x115):
        fcntl.ioctl(fd_rel, UI_SET_KEYBIT, btn)
    for rel in (REL_X, REL_Y):
        fcntl.ioctl(fd_rel, UI_SET_RELBIT, rel)
    fcntl.ioctl(fd_rel, UI_DEV_SETUP, struct.pack("HHHH80sI", 0x03, 0xbeef, 0xdead, 1, b"virt-rel-mouse", 0))
    fcntl.ioctl(fd_rel, UI_DEV_CREATE)

    # 2. Direct absolute mouse (for the target monitor dimensions)
    fd_abs = os.open("/dev/uinput", os.O_WRONLY | os.O_NONBLOCK)
    for ev in (EV_SYN, EV_KEY, EV_ABS):
        fcntl.ioctl(fd_abs, UI_SET_EVBIT, ev)
    for btn in range(0x110, 0x115):
        fcntl.ioctl(fd_abs, UI_SET_KEYBIT, btn)
    for axis, max_v in ((ABS_X, mon_w), (ABS_Y, mon_h)):
        fcntl.ioctl(fd_abs, UI_SET_ABSBIT, axis)
        fcntl.ioctl(fd_abs, UI_ABS_SETUP, struct.pack("Hxxiiiiii", axis, 0, 0, max_v, 0, 0, 0))
    fcntl.ioctl(fd_abs, UI_SET_PROPBIT, INPUT_PROP_DIRECT)
    fcntl.ioctl(fd_abs, UI_DEV_SETUP, struct.pack("HHHH80sI", 0x03, 0xbeef, 0xdeae, 1, b"virt-abs-mouse", 0))
    fcntl.ioctl(fd_abs, UI_DEV_CREATE)

    # 3. Full keyboard (keys 1..248 so udev tags ID_INPUT_KEYBOARD=1)
    fd_kbd = os.open("/dev/uinput", os.O_WRONLY | os.O_NONBLOCK)
    for ev in (EV_SYN, EV_KEY, EV_REP):
        fcntl.ioctl(fd_kbd, UI_SET_EVBIT, ev)
    for k in range(1, 249):
        fcntl.ioctl(fd_kbd, UI_SET_KEYBIT, k)
    fcntl.ioctl(fd_kbd, UI_DEV_SETUP, struct.pack("HHHH80sI", 0x03, 0xbeef, 0xdeaf, 1, b"virt-keyboard", 0))
    fcntl.ioctl(fd_kbd, UI_DEV_CREATE)

    subprocess.run(["udevadm", "settle"], check=False)
    time.sleep(1.0)
    return fd_rel, fd_abs, fd_kbd
```

---

## 4. Raising & Focusing Windows on COSMIC Wayland

Because Wayland prevents background clients from stealing focus without a compositor activation token (`xdg_activation_v1`):

- **AT-SPI apps**: Use `orca computer focus --app "<AppName>"` if the app appears in `orca computer list apps`.
- **Any app on the COSMIC top panel**: Both monitors render the COSMIC top bar (`y = 0..36`) with the `cosmic-app-list` dock icons centered around `y = 18`. Clicking an app's icon in the top panel invokes `zcosmic_toplevel_manager_v1` inside `cosmic-panel` to raise that window.
- **Cross-monitor activation caveat**:
  - Clicking an app's icon in the top panel on one monitor raises the window on **whichever monitor that window already lives on** (for example, clicking an icon in the right monitor's top panel may raise the window on the left monitor `2560x1440`).
  - After clicking the top-panel icon, always check both monitors (`0..2560` and `2560..4480`) in a screenshot to see where the window surfaced, then move the relative mouse (`EV_REL`) onto that monitor, set the absolute mouse `absmax` to that monitor's resolution (`2560x1440` or `1920x1440`), and click inside the window before sending keyboard shortcuts (`Ctrl+T`, typing, etc.) so Wayland keyboard focus is bound to that window.
- **Finding top-bar icon `x` coordinates**:
  - The dock icons in `cosmic-app-list` sit along `y = 18` starting around `x = 215` with `~40px` spacing between icon centers (e.g., `x = 226`, `266`, `308`, `350`, `390`, `430`, ...).
  - You can inspect exact icon bounds along `y = 18` from any cropped monitor screenshot using `GdkPixbuf` pixel sampling.
