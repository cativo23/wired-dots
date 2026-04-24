---
name: Bug report
about: Something's broken
title: "[bug] "
labels: bug
assignees: cativo23
---

## What happened

<!-- One sentence -->

## What should have happened

## Reproduction

<!-- Steps to trigger -->

## Environment

- Arch release: `uname -r`
- Hyprland version: `hyprctl version`
- wired-dots version: `cat ~/wired-dots/VERSION`
- Hardware:
  - CPU: `lscpu | head -15`
  - GPU: `lspci -k | grep -EA3 'VGA|3D'`
  - WiFi: `lspci | grep -i network`
- Bootloader: `bootctl status 2>/dev/null | head -5`
- Initramfs generator: `[ -f /etc/dracut.conf ] && echo dracut || echo mkinitcpio`

## Logs

Attach relevant log from `~/.cache/wired-dots/logs/`.

## Extras

<!-- Screenshots, additional context -->
