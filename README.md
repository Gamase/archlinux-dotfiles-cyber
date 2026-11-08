# archlinux-dotfiles-cyber

Personal dotfiles for an **Arch Linux + Hyprland** desktop with a dark-blue "cyber" theme.
Wayland-only setup tuned for a laptop with an **NVIDIA** GPU: a Waybar status bar with rofi menus for
WiFi, Bluetooth, volume and brightness, hyprlock/hypridle for locking, and automatic projector mirroring
over HDMI.

> [!IMPORTANT]
> The Hyprland config is written in **Lua** and requires **Hyprland 0.57 or newer**.
> Hyprland 0.57 dropped the old hyprlang (`hyprland.conf`) format. If you're on an older version,
> use the `hyprland.conf`-based config from commit `61d6415`.

## Contents

| Directory | Application | Notes |
| --- | --- | --- |
| [`hypr/`](hypr) | Hyprland, hyprlock, hypridle | Lua config split into modules, startup script, projector scripts, wallpaper |
| [`waybar/`](waybar) | Waybar | Bar layout, styles and custom modules/menus |
| [`rofi/`](rofi) | rofi | `waybar.rasi`: theme shared by every Waybar menu |
| [`wofi/`](wofi) | wofi | App launcher and clipboard picker |
| [`alacritty/`](alacritty) | Alacritty | Main terminal |
| [`kitty/`](kitty) | kitty | Secondary terminal (used for nvim and Claude Code windows) |
| [`dunst/`](dunst) | dunst | Notifications, with progress bars for volume/brightness |
| [`wlogout/`](wlogout) | wlogout | Power menu (layout, style, icons) |
| [`nvim/`](nvim) | Neovim | [NvChad](https://nvchad.com)-based config |
| [`btop/`](btop) | btop | Config and custom themes (`cyberpunk-blue`, `cyber-punk`, `red-dark`, …) |
| [`cava/`](cava) | cava | Audio visualizer config, themes and shaders |
| [`fastfetch/`](fastfetch) | fastfetch | System info with a custom skull logo |
| [`starship.toml`](starship.toml) | Starship | Two-line prompt |
| [`.zshrc`](.zshrc) | zsh | Shell config |

## Dependencies

All packages are in the official Arch repos unless marked **(AUR)**.

| Purpose | Packages |
| --- | --- |
| Compositor & session | `hyprland` (≥ 0.57) `hyprlock` `hypridle` `swaybg` `udiskie` |
| Bar & menus | `waybar` `rofi` `wofi` `wlogout` (AUR) `jq` `socat` `expect` `libnotify` |
| Notifications | `dunst` |
| Terminals & shell | `alacritty` `kitty` `zsh` `starship` `fastfetch` |
| Audio | `pipewire-pulse` (provides `pactl`) `pamixer` `playerctl` `pavucontrol` |
| Network & Bluetooth | `networkmanager` `bluez-utils` |
| Hardware | `brightnessctl` |
| Clipboard & screenshots | `wl-clipboard` `cliphist` `flameshot` |
| Theming | `qt6ct` `kvantum` `ttf-jetbrains-mono-nerd` |
| Tools | `neovim` `btop` `cava` |
| Apps opened at startup | `zen-browser-bin` (AUR) `pear-desktop-bin` (AUR, YouTube Music) `discord` `visual-studio-code-bin` (AUR) `virt-manager` |

```sh
sudo pacman -S --needed hyprland hyprlock hypridle swaybg udiskie waybar rofi wofi jq socat expect \
  libnotify dunst alacritty kitty zsh starship fastfetch pipewire-pulse pamixer playerctl pavucontrol \
  networkmanager bluez-utils brightnessctl wl-clipboard cliphist flameshot qt6ct kvantum \
  ttf-jetbrains-mono-nerd neovim btop cava
yay -S wlogout zen-browser-bin
```

## Installation

The repo holds plain copies of the files (no symlinks or dotfile manager). Back up your current
configs, then copy each directory into `~/.config`:

```sh
git clone git@github.com:Gamase/archlinux-dotfiles-cyber.git
cd archlinux-dotfiles-cyber

# Back up whatever is already there
backup=~/.config/dotfiles-backup-$(date +%F)
mkdir -p "$backup"
for d in alacritty btop cava dunst fastfetch hypr kitty nvim rofi waybar wlogout wofi; do
    [ -e ~/.config/$d ] && mv ~/.config/$d "$backup/"
done
[ -e ~/.zshrc ] && mv ~/.zshrc "$backup/"
[ -e ~/.config/starship.toml ] && mv ~/.config/starship.toml "$backup/"

# Install
cp -r alacritty btop cava dunst fastfetch hypr kitty nvim rofi waybar wlogout wofi ~/.config/
cp starship.toml ~/.config/
cp .zshrc ~/
```

Check the config before logging in:

```sh
Hyprland --verify-config -c ~/.config/hypr/hyprland.lua
```

### Things you'll probably want to change

- **Monitor**: [`hypr/monitors.lua`](hypr/monitors.lua) uses the preferred mode at scale 1 for every output.
- **Internal display name**: the projector scripts assume the laptop panel is `eDP-1`
  (`INTERNAL` in [`hypr/scripts/proyector-lib.sh`](hypr/scripts/proyector-lib.sh)).
- **NVIDIA variables**: [`hypr/env.lua`](hypr/env.lua) sets `LIBVA_DRIVER_NAME`, `GBM_BACKEND` and
  `__GLX_VENDOR_LIBRARY_NAME` for NVIDIA. Remove them on Intel/AMD-only machines.
- **Keyboard layouts**: `us,latam`, switched with `Alt + Shift` (`input` in [`hypr/hyprland.lua`](hypr/hyprland.lua)).
- **Startup apps**: [`hypr/startup.sh`](hypr/startup.sh) opens each app on its own workspace.
- **`.zshrc`** sources an optional, untracked `~/.config/zsh/homelab.zsh` for machine-specific settings.

## Hyprland

The Lua config is split into modules loaded from [`hypr/hyprland.lua`](hypr/hyprland.lua):

| File | Contents |
| --- | --- |
| `hyprland.lua` | Entry point: autostart, general/input/decoration options, animations |
| `env.lua` | Environment variables (Wayland session, NVIDIA, Qt/Kvantum) |
| `monitors.lua` | Monitor layout |
| `binds.lua` | Keybindings |
| `windows-rules.lua` | Window rules (opacity, floating windows, scratchpad, idle inhibit) |
| `hypridle.conf` | Lock after 5 min, screen off after 10 min |
| `hyprlock.conf` | Lock screen |
| `startup.sh` | Wallpaper, Waybar (auto-restarts if it crashes), clipboard history, hypridle, apps |
| `toggle-scratch.sh` | Scratchpad toggle (spawns a terminal if it's empty) |
| `scripts/` | Projector mirroring (see below) |

### Startup workspaces

| Workspace | App |
| --- | --- |
| 1 | Zen Browser |
| 2 | YouTube Music |
| 3 | Discord |
| 4 | VS Code |
| 5 | virt-manager |
| 6 | Neovim (kitty) |

Apps only land on these workspaces when launched by `startup.sh`. Apps opened later by hand open on
the current workspace.

### Keybindings

`Super` is the main modifier.

| Keys | Action |
| --- | --- |
| `Super + Enter` | Terminal (Alacritty) |
| `Super + D` | App launcher (wofi) |
| `Super + V` | Clipboard history |
| `Super + C` | Claude Code in kitty |
| `Super + P` | Screenshot (flameshot) |
| `Super + Q` | Close window |
| `Super + W` | Toggle floating |
| `Super + F` | Fullscreen |
| `Super + Space` | Toggle scratchpad terminal |
| `Super + Shift + Space` | Send window to the scratchpad |
| `Super + 1…8` | Go to workspace |
| `Super + Shift + 1…8` | Move window to workspace (and follow it) |
| `Super + ← / →` | Previous / next workspace |
| `Super + LMB / RMB drag` | Move / resize window |
| `Super + Alt + P` | Mirror the laptop screen to the external display |
| `Super + Alt + O` | Extend to the external display |
| `Super + Shift + M` | Exit Hyprland |
| Media keys | Volume, mute, play/pause, next/previous, brightness |

### Projector / external display

[`scripts/auto-mirror-projector.sh`](hypr/scripts/auto-mirror-projector.sh) runs as a daemon and listens
to Hyprland's event socket. When an external display is connected it **mirrors** the laptop screen
automatically, using the display's native mode. It re-applies the mode after a config reload. While
presenting it pauses hypridle so the screen doesn't lock mid-presentation, and resumes it when the
display is unplugged. `Super + Alt + P` / `Super + Alt + O` switch between mirror and extended mode by hand.

## Waybar

Layout: clock, power, WiFi and Bluetooth on the left; workspaces and the media player in the center;
tray, battery, volume and brightness on the right.

| Module | Click | Right click | Scroll |
| --- | --- | --- | --- |
| WiFi | Network menu | Rescan and open menu | — |
| Bluetooth | Connect / disconnect a paired device | Device management menu | — |
| Volume | Volume menu | Toggle pavucontrol | ±5% |
| Brightness | Brightness menu | — | ±5% |
| Media (mpris) | Play / pause | — | Next / previous |
| Power | wlogout | — | — |

All menus use rofi with [`rofi/waybar.rasi`](rofi/waybar.rasi), and every action sends a dunst notification.

- **WiFi** ([`wifi-menu.sh`](waybar/scripts/wifi-menu.sh)): networks sorted by signal, with a lock icon on
  secured ones. Asks for the password inside rofi, including WPA-Enterprise (802.1X) user + password.
  A wrong password doesn't leave a broken saved profile behind. Clicking the connected network gives
  disconnect / details / forget. Also supports hidden networks.
- **Bluetooth** ([`bluetooth-menu.sh`](waybar/scripts/bluetooth-menu.sh)): paired devices first, with battery
  level when available. Connecting retries a few times and switches the audio output to the device.
  New devices are only scanned for when you ask, and paired with [`bluetooth-pair.sh`](waybar/scripts/bluetooth-pair.sh).
- **Volume** ([`volume-menu.sh`](waybar/scripts/volume-menu.sh)): mute, quick levels, exact value, audio
  output switching (moves streams that are already playing), mic mute, pavucontrol.
- **Brightness** ([`brightness-menu.sh`](waybar/scripts/brightness-menu.sh)): quick levels or an exact value,
  never below 5%.

## Security notes

The WiFi and Bluetooth scripts handle names that anyone nearby can pick (SSIDs, device names), so they
treat them strictly as data:

- Menus are built with `printf`, never `echo -e`, so a crafted name can't inject fake menu entries.
- MAC addresses and monitor names are validated before being placed into `expect` (Tcl) or
  `hyprctl eval` (Lua) code.
- WiFi passwords reach `nmcli` through a file descriptor (`passwd-file`), never as command-line
  arguments, which any local user could read with `ps`. The only exception is WEP.
- When adding a WPA-Enterprise network, the menu asks for the RADIUS server domain so the server
  certificate can be verified. Leaving it empty connects without verification and shows a warning,
  because a rogue access point with the same name could capture the credentials.

No passwords, tokens or keys are stored in this repository.
