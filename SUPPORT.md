# Hardware support matrix

This document is the source of truth for which hardware
configurations wired-dots officially supports. The installer
checks against this matrix at run time.

## Tier 1 — CI verified

Tested on every push and PR via GitHub Actions on Ubuntu runners
with mocked hardware detection.

- **CPU:** Intel 8th gen+, AMD Ryzen 1000+
- **GPU:** Intel Xe / Arc (modern integrated)
- **Bootloader:** systemd-boot UEFI
- **Audio:** PipeWire + WirePlumber
- **Display:** 1080p, 1440p single

## Tier 2 — Tested on maintainer's hardware

Manually validated on each minor release (`v1.x.0`).

- **GPU:** NVIDIA RTX 30 Mobile (Turing+), AMD RDNA (RX 6000)
- **Bootloader:** GRUB UEFI, rEFInd UEFI
- **Display:** dual monitor (DP + HDMI)
- **WiFi:** Realtek RTL8821CE (DKMS)

## Tier 3 — Best-effort

No automated test coverage. Issues triaged monthly, no SLA.

- NVIDIA Turing+ outside RTX 30 Mobile
- AMD GCN legacy (RX 400/500)
- Optimus hybrid laptops
- Triple+ monitor setups
- BTRFS / ZFS / LVM root

## ❌ Unsupported

The installer aborts with a clear message and a link to manual
setup docs.

- NVIDIA Maxwell / Pascal / Fermi / Kepler legacy
- GRUB legacy MBR / BIOS-only systems
- Wayland-incompatible NVIDIA versions
- Dual-boot Windows (untested)
- LUKS-encrypted root (untested)

## Reporting hardware issues

If you hit a problem on Tier 3 hardware, open a
[bug report](.github/ISSUE_TEMPLATE/bug-report.md) and include
the **Environment** section. Tier 3 issues get triaged once a
month, not on the response-time SLA.
