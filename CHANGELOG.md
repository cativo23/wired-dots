# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0-dev] — 2026-04-24

### Added
- Phase 01: timestamped config backup before symlinking
- Phase 03a: idempotent pacman.conf patch (Color, ILoveCandy, ParallelDownloads) + NVIDIA pacman hook
- Phase 03b–03f: package installers for core, pipewire audio, fonts, bluez bluetooth, and AUR packages
- Phase 04a–04d: GPU detection and driver setup for NVIDIA (Turing+), AMD (RDNA), and Intel (Xe/Arc)
- Phase 05: WiFi driver handling (in-tree detection, RTL8821CE DKMS opt-in)
- Phase 06: full config deployment via symlink_safe (DRY_RUN + ON_CONFLICT aware)
- Phase 07: GTK + cursor theme via gsettings (Tokyonight-GTK-BL, phinger-cursors-dark)
- Phase 08: SDDM and greetd display manager setup with tuigreet/uwsm
- Phase 09: GRUB cmdline patching with GPU kernel params (idempotent)
- Phase 10a: system service enabling (NetworkManager, bluetooth, seatd, display manager)
- Phase 10b: XDG desktop portal restart after config deploy
- Phase 10c: post-install verification with summary box
- 118 bats unit tests covering all phase scripts and global helpers

### Changed
- VERSION bumped to 0.3.0-dev

### Added

- Initial repo scaffolding (M0): directory structure, docs skeletons, CI workflows, placeholder entry scripts.

[Unreleased]: https://github.com/cativo23/wired-dots/compare/HEAD
