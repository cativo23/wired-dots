# Troubleshooting

> Each section below will be filled in as the corresponding installer phase lands. In M0 these are placeholders documenting the intended structure.

## SecureBoot enabled → boot fails after install

Symptom: boot loops or "secure boot violation" message after installer reboot.

Diagnosis: `bootctl status | grep "Secure Boot"`.

Fix: disable SecureBoot in firmware, OR sign DKMS modules with `sbctl` (see [SECURITY.md](SECURITY.md)).

## NVIDIA modeset failure → black screen / tty only

Symptom: no Wayland session starts, dmesg shows nvidia-drm errors.

Diagnosis: `journalctl -b 0 | grep -i nvidia`.

Fix (temporary): append `nvidia_drm.modeset=0` to kernel cmdline at boot (press `e` in GRUB / `e` in systemd-boot). This disables kmodeset; desktop will be slow but boots.

Fix (permanent): fall back to `linux-lts` kernel (`sudo pacman -S linux-lts linux-lts-headers`), re-run `./install.sh --only=04b_gpu_nvidia`.

## Realtek WiFi broken after kernel update

Symptom: WiFi disappears after `pacman -Syu`.

Diagnosis: `dmesg | grep -i rtl`.

Fix: boot into `linux-lts`, re-run installer without `--force-rtl-dkms`.

## GTK4 app hangs at 99% CPU (pavucontrol, nautilus)

Symptom: app doesn't open, CPU pegged on one core.

Diagnosis: check `gtk-4.0/gtk.css` for syntax errors: `gtk4-builder-tool validate ~/.config/gtk-4.0/gtk.css`.

Fix: if CSS is malformed, revert to the shipped `gtk.css` from the repo; re-run `./install.sh --only=07_theme`.

## pavucontrol won't open, pwvucontrol is fine

See GTK4 issue above. Alternative: use `pwvucontrol` (PipeWire-native), shipped by default.

## Volume silent after reboot

Symptom: no audio, `wpctl status` shows volume at 0.

Diagnosis: WirePlumber persisted a 0% state.

Fix:
```bash
wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.5
wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
```

The installer's `03c_audio.sh` already guards against this on install, but if you hit it post-install (e.g. after accidental mute spam), use the commands above.

## Fonts don't render in waybar (boxes everywhere)

Fix:
```bash
fc-cache -f
fc-list | grep -i "jetbrains\|nerd"
```

Verify JetBrainsMono NF is installed.

## Hyprland won't start from SDDM

Diagnosis: `ls /usr/share/wayland-sessions/ | grep -i hyprland`.

Fix: the SDDM session file must be `hyprland-uwsm.desktop` (shipped by the `uwsm` package). If missing, `sudo pacman -S uwsm`.

## Portals broken (screen share, file picker not working)

Diagnosis: `systemctl --user status xdg-desktop-portal*`.

Fix:
```bash
systemctl --user restart xdg-desktop-portal.service xdg-desktop-portal-hyprland.service xdg-desktop-portal-gtk.service
```

## Installer aborts with "dracut/booster detected"

v1.0 only supports `mkinitcpio`. Fix: switch your system to mkinitcpio OR wait for dracut support in v1.3+.
