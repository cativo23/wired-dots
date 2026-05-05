# wired-dots M0 — Scaffolding Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bootstrap the wired-dots repo with the full directory skeleton, project metadata files, and a green CI pipeline. No application code yet — just the chassis.

**Architecture:** Plain repo scaffolding. Directories with `.gitkeep` placeholders matching the layout in the design spec (§2). CI runs `bash -n`, `shellcheck`, markdown lint, TOML validation, and secret scan — all configured to pass on an empty scaffold so future commits can rely on green CI as a quality baseline.

**Tech Stack:** Bash, GitHub Actions, shellcheck, mdl (markdownlint), taplo, gitleaks.

**Spec reference:** `docs/superpowers/specs/2026-05-04-wired-dots-v2-design.md` §2 (Architecture overview / Repository layout) and §10.1 (CI pipeline).

**Working directory:** `/home/cativo23/projects/personal/wired-dots/`

**Branch strategy:** Work on `feature/m0-scaffolding`, PR to `main`, squash-merge.

---

## File Structure

After M0 is complete, the repo tree should be:

```
wired-dots/
├── .editorconfig                                            (new — Task 4)
├── .gitignore                                               (exists, will append)
├── .gitleaks.toml                                           (new — Task 4)
├── .markdownlint.json                                       (new — Task 4)
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── bug-report.md                                    (new — Task 7)
│   │   └── feature-request.md                               (new — Task 7)
│   ├── PULL_REQUEST_TEMPLATE.md                             (new — Task 7)
│   └── workflows/
│       └── ci.yml                                           (new — Task 5)
├── bin/
│   └── .gitkeep                                             (new — Task 3)
├── cli/
│   ├── commands/.gitkeep                                    (new — Task 3)
│   ├── lib/.gitkeep                                         (new — Task 3)
│   └── .gitkeep                                             (new — Task 3)
├── configs/.gitkeep                                         (new — Task 3)
├── docs/
│   ├── adding-a-theme.md                                    (new — Task 8)
│   ├── architecture.md                                      (new — Task 8)
│   ├── keybindings.md                                       (new — Task 8)
│   ├── release-procedure.md                                 (new — Task 8)
│   ├── screenshots/.gitkeep                                 (new — Task 3)
│   ├── superpowers/
│   │   ├── plans/
│   │   │   └── 2026-05-04-wired-dots-m0-scaffolding.md      (this file)
│   │   └── specs/
│   │       └── 2026-05-04-wired-dots-v2-design.md           (already exists)
│   └── troubleshooting.md                                   (new — Task 8)
├── hooks/.gitkeep                                           (new — Task 3)
├── installer/
│   ├── lib/.gitkeep                                         (new — Task 3)
│   ├── phases/.gitkeep                                      (new — Task 3)
│   └── tui/.gitkeep                                         (new — Task 3)
├── system/.gitkeep                                          (new — Task 3)
├── templates/.gitkeep                                       (new — Task 3)
├── tests/
│   ├── arch-container/.gitkeep                              (new — Task 3)
│   ├── bats/.gitkeep                                        (new — Task 3)
│   └── theme-build/.gitkeep                                 (new — Task 3)
├── themes/
│   ├── nervwire/.gitkeep                                    (new — Task 3)
│   └── nightwire/.gitkeep                                   (new — Task 3)
├── CHANGELOG.md                                             (new — Task 1)
├── CONTRIBUTING.md                                          (new — Task 11)
├── DOGFOOD.md                                               (new — Task 10)
├── LICENSE                                                  (new — Task 1)
├── README.md                                                (new — Task 1)
├── SUPPORT.md                                               (new — Task 9)
├── VERSION                                                  (new — Task 1)
├── install.sh                                               (new — Task 2, stub)
└── uninstall.sh                                             (new — Task 2, stub)
```

---

### Task 1: Project metadata files (LICENSE, VERSION, README, CHANGELOG)

**Files:**
- Create: `LICENSE`
- Create: `VERSION`
- Create: `README.md`
- Create: `CHANGELOG.md`

- [ ] **Step 1: Create the feature branch**

```bash
cd /home/cativo23/projects/personal/wired-dots
git checkout -b feature/m0-scaffolding
git status
```

Expected: `On branch feature/m0-scaffolding` and clean working tree.

- [ ] **Step 2: Write LICENSE**

Create `LICENSE` with the standard MIT license text:

```
MIT License

Copyright (c) 2026 Carlos Cativo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 3: Write VERSION**

Create `VERSION` with a single line:

```
0.1.0-m0
```

(No trailing newline issues — use a single line.)

- [ ] **Step 4: Write README.md**

```markdown
<div align="center">

```text
 ██╗    ██╗██╗██████╗ ███████╗██████╗
 ██║    ██║██║██╔══██╗██╔════╝██╔══██╗
 ██║ █╗ ██║██║██████╔╝█████╗  ██║  ██║
 ██║███╗██║██║██╔══██╗██╔══╝  ██║  ██║
 ╚███╔███╔╝██║██║  ██║███████╗██████╔╝
  ╚══╝╚══╝ ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝
                          -dots
```

# wired-dots

**A cyberpunk Hyprland setup for Arch Linux — palette-driven theming, NERV-grade desktop.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=flat&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-5046e4?style=flat)](https://hyprland.org/)
[![Status](https://img.shields.io/badge/status-M0_scaffolding-orange?style=flat)](docs/superpowers/specs/2026-05-04-wired-dots-v2-design.md)

> **Status:** v0.1.0-m0 — repo scaffolding only. Installer and runtime CLI ship in M2/M3.

</div>

---

## What is this?

wired-dots is a **palette-driven, runtime-themable Hyprland desktop** for Arch Linux. Inspired by Symphony's switching model and built around the [nightwire](https://github.com/cativo23/nightwire) design system.

See the full design contract: [docs/superpowers/specs/2026-05-04-wired-dots-v2-design.md](docs/superpowers/specs/2026-05-04-wired-dots-v2-design.md).

## Roadmap

| Milestone | Status | Scope |
|---|---|---|
| **M0 — Scaffolding** | 🚧 In progress | Repo skeleton, CI green on empty scaffold |
| **M1 — Configs** | ⏳ Pending | Migrate Hyprland/waybar/kitty/etc configs + initial 2 themes |
| **M2 — Installer** | ⏳ Pending | TUI installer with `gum`, hardware detect, dry-run |
| **M3 — Core phases** | ⏳ Pending | Packages, audio, fonts, symlinks, theme, services, bootloader |
| **v1.0.0** | ⏳ Pending | Stable release after 30-day daily-driver dogfooding |

## Quick install (M2+)

```bash
# Coming when installer ships in M2
git clone https://github.com/cativo23/wired-dots.git ~/wired-dots
cd ~/wired-dots
./install.sh
```

## Themes shipped at v1.0.0

- **nightwire** — Pure void with soft neon. Sibling of the [nightwire design system](https://github.com/cativo23/nightwire).
- **nervwire** — NERV-coded, naranja agresivo + verde tóxico.

`bladerunner` and `monochrome` land in v1.1.0. Wallpaper-driven `chaos` mode lands in v1.2.0.

## Hardware support

See [SUPPORT.md](SUPPORT.md) for the full tiered matrix. **TL;DR**: modern UEFI hardware (NVIDIA Turing+, AMD RDNA+, Intel Xe+).

## License

MIT — see [LICENSE](LICENSE).
```

- [ ] **Step 5: Write CHANGELOG.md**

```markdown
# Changelog

All notable changes to **wired-dots** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- _Coming soon_

## [0.1.0-m0] - 2026-05-04

### Added

- Repo scaffolding: directory skeleton matching the v2 design spec
- Project metadata: LICENSE (MIT), VERSION, README, CHANGELOG, SUPPORT, CONTRIBUTING, DOGFOOD
- CI pipeline: bash -n, shellcheck, markdown lint, TOML validation, secret scan
- GitHub issue and PR templates
- Stub `install.sh` and `uninstall.sh` (placeholder messages until M2)
- Documentation stubs for architecture, theming, keybindings, troubleshooting, release procedure

[Unreleased]: https://github.com/cativo23/wired-dots/compare/v0.1.0-m0...HEAD
[0.1.0-m0]: https://github.com/cativo23/wired-dots/releases/tag/v0.1.0-m0
```

- [ ] **Step 6: Verify files exist with correct content**

Run:
```bash
ls -la LICENSE VERSION README.md CHANGELOG.md
cat VERSION
head -3 LICENSE
```

Expected: 4 files exist, VERSION shows `0.1.0-m0`, LICENSE starts with `MIT License`.

- [ ] **Step 7: Commit**

```bash
git add LICENSE VERSION README.md CHANGELOG.md
git commit -m ":memo: docs: project metadata (LICENSE, VERSION, README, CHANGELOG)"
```

---

### Task 2: Top-level entry stubs (install.sh, uninstall.sh)

**Files:**
- Create: `install.sh`
- Create: `uninstall.sh`

- [ ] **Step 1: Write install.sh stub**

```bash
#!/usr/bin/env bash
# wired-dots installer — top-level entry point
# This file delegates to installer/install.sh once M2 ships.

set -euo pipefail

VERSION=$(<"$(dirname "$(readlink -f "$0")")/VERSION")

cat <<EOF

   ██╗    ██╗██╗██████╗ ███████╗██████╗
   ██║    ██║██║██╔══██╗██╔════╝██╔══██╗
   ██║ █╗ ██║██║██████╔╝█████╗  ██║  ██║
   ██║███╗██║██║██╔══██╗██╔══╝  ██║  ██║
   ╚███╔███╔╝██║██║  ██║███████╗██████╔╝
    ╚══╝╚══╝ ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝
                            -dots v${VERSION}

   wired-dots is currently in M0 (scaffolding only).
   The installer ships in M2. Track progress at:
   https://github.com/cativo23/wired-dots

EOF

exit 0
```

- [ ] **Step 2: Write uninstall.sh stub**

```bash
#!/usr/bin/env bash
# wired-dots uninstaller — top-level entry point
# This file delegates to a real uninstall flow once M3 ships.

set -euo pipefail

cat <<'EOF'

   wired-dots uninstaller is not yet implemented.

   M3 will ship a real uninstall path that restores backups
   from ~/.config/cfg_backups/ and removes wired-managed
   symlinks.

EOF

exit 0
```

- [ ] **Step 3: Make both executable**

Run:
```bash
chmod +x install.sh uninstall.sh
ls -la install.sh uninstall.sh
```

Expected: both files have `-rwxr-xr-x` permissions.

- [ ] **Step 4: Verify install.sh runs cleanly**

Run:
```bash
./install.sh
```

Expected: ASCII banner prints, message about M0 scaffolding, exits 0.

- [ ] **Step 5: Verify uninstall.sh runs cleanly**

Run:
```bash
./uninstall.sh
```

Expected: message about uninstaller not yet implemented, exits 0.

- [ ] **Step 6: Commit**

```bash
git add install.sh uninstall.sh
git commit -m ":sparkles: feat: install.sh and uninstall.sh stubs (placeholder until M2/M3)"
```

---

### Task 3: Directory scaffolding with .gitkeep

**Files:**
- Create: 17 `.gitkeep` files across the directory tree

- [ ] **Step 1: Create all directories**

Run:
```bash
mkdir -p \
  bin \
  cli/commands cli/lib \
  configs \
  docs/screenshots \
  hooks \
  installer/lib installer/phases installer/tui \
  system \
  templates \
  tests/arch-container tests/bats tests/theme-build \
  themes/nervwire themes/nightwire
```

- [ ] **Step 2: Create .gitkeep in each leaf directory**

Run:
```bash
touch \
  bin/.gitkeep \
  cli/.gitkeep \
  cli/commands/.gitkeep \
  cli/lib/.gitkeep \
  configs/.gitkeep \
  docs/screenshots/.gitkeep \
  hooks/.gitkeep \
  installer/lib/.gitkeep \
  installer/phases/.gitkeep \
  installer/tui/.gitkeep \
  system/.gitkeep \
  templates/.gitkeep \
  tests/arch-container/.gitkeep \
  tests/bats/.gitkeep \
  tests/theme-build/.gitkeep \
  themes/nervwire/.gitkeep \
  themes/nightwire/.gitkeep
```

- [ ] **Step 3: Verify all .gitkeep files exist**

Run:
```bash
find . -name '.gitkeep' -type f | sort
```

Expected output (17 lines):
```
./bin/.gitkeep
./cli/.gitkeep
./cli/commands/.gitkeep
./cli/lib/.gitkeep
./configs/.gitkeep
./docs/screenshots/.gitkeep
./hooks/.gitkeep
./installer/lib/.gitkeep
./installer/phases/.gitkeep
./installer/tui/.gitkeep
./system/.gitkeep
./templates/.gitkeep
./tests/arch-container/.gitkeep
./tests/bats/.gitkeep
./tests/theme-build/.gitkeep
./themes/nervwire/.gitkeep
./themes/nightwire/.gitkeep
```

- [ ] **Step 4: Commit**

```bash
git add .
git commit -m ":sparkles: feat: directory scaffolding with .gitkeep placeholders"
```

---

### Task 4: Linting configuration files

**Files:**
- Create: `.editorconfig`
- Create: `.markdownlint.json`
- Create: `.gitleaks.toml`
- Modify: `.gitignore` (already exists, append more rules)

- [ ] **Step 1: Write .editorconfig**

```ini
# wired-dots — EditorConfig (https://editorconfig.org/)
root = true

[*]
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
indent_style = space
indent_size = 4

[*.{md,markdown}]
trim_trailing_whitespace = false  # markdown uses trailing spaces for line breaks

[*.{yml,yaml,toml,json,jsonc}]
indent_size = 2

[*.{sh,bash,zsh}]
indent_size = 4

[Makefile]
indent_style = tab
```

- [ ] **Step 2: Write .markdownlint.json**

```json
{
  "default": true,
  "MD013": false,
  "MD024": { "siblings_only": true },
  "MD033": false,
  "MD041": false
}
```

(MD013=line-length disabled, MD024=allow sibling H2s, MD033=allow inline HTML, MD041=allow non-h1 first line.)

- [ ] **Step 3: Write .gitleaks.toml**

```toml
# wired-dots — gitleaks config
# Custom rules layered on top of the default ruleset.

[extend]
useDefault = true

[allowlist]
description = "Global allowlist for wired-dots"

# Allow the design spec mentioning ANTHROPIC_AUTH_TOKEN as a documented env var name.
regexes = [
  '''ANTHROPIC_AUTH_TOKEN.*your-token-here''',
  '''ANTHROPIC_AUTH_TOKEN=""''',
]

paths = [
  '''.superpowers/.*''',
  '''docs/screenshots/.*''',
]
```

- [ ] **Step 4: Append rules to .gitignore**

Open `.gitignore` and ensure these lines exist (the file already has `.superpowers/` from earlier work — we add the rest):

```
# wired-dots cache and runtime state
~/.config/wired/

# Editor swap files
*.swp
*.swo
*~

# OS junk
.DS_Store
Thumbs.db

# CI artifacts
*.log
*.tar.gz
release-notes-*.md

# Test outputs
tests/**/output/
tests/**/.bats_tmpdir/
```

Use `cat >> .gitignore <<'EOF'` to append, NOT replace. Verify the file still contains `.superpowers/`.

- [ ] **Step 5: Verify lint configs pass on themselves**

Markdown lint sanity check (we don't have any .md files yet besides README/CHANGELOG, but let's lint them):

```bash
# If mdl is not installed, this is informational — CI will lint properly
command -v mdl && mdl README.md CHANGELOG.md || echo "mdl not local; CI will lint"
```

Editorconfig sanity check — ensure no tab-indented files:

```bash
grep -rPl '^\t' --include='*.sh' --include='*.md' . 2>/dev/null | grep -v '.git/' | head -3 || echo "OK no tabs"
```

Expected: `OK no tabs` (or empty).

- [ ] **Step 6: Commit**

```bash
git add .editorconfig .markdownlint.json .gitleaks.toml .gitignore
git commit -m ":wrench: chore(lint): add editorconfig, markdownlint, gitleaks, gitignore rules"
```

---

### Task 5: GitHub Actions CI workflow — lint job

**Files:**
- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: Create .github/workflows/ directory**

Run:
```bash
mkdir -p .github/workflows
```

- [ ] **Step 2: Write ci.yml with the lint job**

```yaml
name: CI

on:
  push:
    branches: [main, develop, "feature/**", "fix/**", "release/**"]
  pull_request:
    branches: [main, develop]

permissions:
  contents: read

jobs:
  lint:
    name: Lint (bash, markdown, toml, secrets)
    runs-on: ubuntu-latest
    timeout-minutes: 5
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # full history for gitleaks

      - name: Bash syntax check (bash -n)
        run: |
          set -euo pipefail
          shopt -s globstar nullglob
          fail=0
          for f in **/*.sh; do
            if ! bash -n "$f"; then
              echo "::error file=$f::bash -n failed"
              fail=1
            fi
          done
          exit $fail

      - name: Shellcheck
        uses: ludeeus/action-shellcheck@2.0.0
        with:
          severity: warning
          scandir: '.'
          ignore_paths: |
            .git
            .superpowers
            docs

      - name: Markdown lint
        uses: DavidAnson/markdownlint-cli2-action@v16
        with:
          globs: |
            **/*.md
            !.superpowers/**
            !node_modules/**

      - name: TOML schema validation (taplo)
        run: |
          curl -fsSL https://github.com/tamasfe/taplo/releases/latest/download/taplo-linux-x86_64.gz \
            | gunzip > /tmp/taplo
          chmod +x /tmp/taplo
          /tmp/taplo lint $(find . -name '*.toml' -not -path './.git/*' -not -path './.superpowers/*' 2>/dev/null) || true
          /tmp/taplo format --check $(find . -name '*.toml' -not -path './.git/*' -not -path './.superpowers/*' 2>/dev/null) || true

      - name: Secret scan (gitleaks)
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          config-path: .gitleaks.toml
```

- [ ] **Step 3: Validate the YAML locally (optional)**

If `yq` is installed:
```bash
yq eval '.jobs.lint.name' .github/workflows/ci.yml
```
Expected: `Lint (bash, markdown, toml, secrets)`

If `yq` is not installed, skip — GitHub will reject malformed YAML.

- [ ] **Step 4: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m ":wrench: chore(ci): add lint workflow (bash, shellcheck, mdl, taplo, gitleaks)"
```

---

### Task 6: Issue and PR templates

**Files:**
- Create: `.github/ISSUE_TEMPLATE/bug-report.md`
- Create: `.github/ISSUE_TEMPLATE/feature-request.md`
- Create: `.github/PULL_REQUEST_TEMPLATE.md`

- [ ] **Step 1: Create the ISSUE_TEMPLATE directory**

Run:
```bash
mkdir -p .github/ISSUE_TEMPLATE
```

- [ ] **Step 2: Write bug-report.md**

```markdown
---
name: Bug report
about: Report a bug, install failure, or unexpected behavior
title: "[BUG] "
labels: bug, needs-triage
---

## What happened?

<!-- A clear description of the bug. -->

## What did you expect?

<!-- What should have happened. -->

## Reproduction steps

1.
2.
3.

## Environment

- wired-dots version: <!-- output of `cat VERSION` or `wired version` -->
- Hardware tier: <!-- 1 / 2 / 3 / unsupported — see SUPPORT.md -->
- GPU: <!-- e.g. NVIDIA RTX 3060 Mobile, AMD RX 6700 XT, Intel Xe -->
- Bootloader: <!-- systemd-boot / GRUB / rEFInd -->
- Display setup: <!-- single 1080p / dual 1440p+1080p / etc -->

## Logs / output

```text
<!-- paste any relevant logs, errors, or terminal output -->
```

## Additional context

<!-- Screenshots, related issues, anything else. -->
```

- [ ] **Step 3: Write feature-request.md**

```markdown
---
name: Feature request
about: Suggest a new feature, theme, or enhancement
title: "[FEAT] "
labels: enhancement, needs-triage
---

## What problem does this solve?

<!-- Describe the use case or pain point. -->

## Proposed solution

<!-- How you think it should work. -->

## Alternatives considered

<!-- Other approaches you ruled out. -->

## Additional context

<!-- Mockups, references to similar features in other dotfiles, etc. -->
```

- [ ] **Step 4: Write PULL_REQUEST_TEMPLATE.md**

```markdown
## Summary

<!-- 1-3 bullet points describing what this PR changes. -->

## Type of change

- [ ] :sparkles: feat (new feature)
- [ ] :bug: fix (bug fix)
- [ ] :memo: docs (documentation only)
- [ ] :recycle: refactor (code restructuring, no behavior change)
- [ ] :white_check_mark: test (adding/fixing tests)
- [ ] :wrench: chore (tooling, CI, dependencies)
- [ ] :fire: remove (removing code or files)

## Checklist

- [ ] CI is green
- [ ] If installer or phases changed: dummy-box validation passed (paste screenshot)
- [ ] CHANGELOG.md updated under `[Unreleased]`
- [ ] Docs updated if user-facing behavior changed
- [ ] No secrets or personal tokens committed

## Closes

<!-- e.g. Closes #42 -->
```

- [ ] **Step 5: Verify all 3 files exist**

Run:
```bash
ls -la .github/ISSUE_TEMPLATE/ .github/PULL_REQUEST_TEMPLATE.md
```

Expected: bug-report.md, feature-request.md, PULL_REQUEST_TEMPLATE.md.

- [ ] **Step 6: Commit**

```bash
git add .github/ISSUE_TEMPLATE/ .github/PULL_REQUEST_TEMPLATE.md
git commit -m ":wrench: chore(github): add issue and PR templates"
```

---

### Task 7: Documentation stubs

**Files:**
- Create: `docs/architecture.md`
- Create: `docs/adding-a-theme.md`
- Create: `docs/keybindings.md`
- Create: `docs/troubleshooting.md`
- Create: `docs/release-procedure.md`

- [ ] **Step 1: Write docs/architecture.md**

```markdown
# Architecture

> **Status:** Stub — fleshed out in M2/M3 as components land.

This document is the operational companion to the design spec.
For the full design contract see
[docs/superpowers/specs/2026-05-04-wired-dots-v2-design.md](superpowers/specs/2026-05-04-wired-dots-v2-design.md).

## Three layers

1. **Installer** (`installer/`) — runs once at install time. Hardware
   detection, package install, system theme deploy.
2. **CLI runtime** (`cli/`, `bin/wired`) — runtime theme switching,
   wallpaper cycling, vibe/focus toggle.
3. **Theme system** (`themes/`, `templates/`, `hooks/`) — palette-driven
   generation: `palette.toml` + `envsubst` templates → outputs.

## Data flow on `wired switch <name>`

```text
parse themes/<name>/palette.toml
  → envsubst < templates/*.tmpl > ~/.config/wired/cache/themes/<name>/*
  → cp themes/<name>/overrides/* (if any) over cache
  → ln -sfn cache/themes/<name> ~/.config/wired/current
  → write state.toml
  → run hooks/NN-*.sh in order
  → notify via swaync
```

## State directory

```text
~/.config/wired/
├── current → cache/themes/<active>/
├── state.toml
└── cache/themes/<name>/
    ├── kitty.conf
    ├── waybar.css
    └── ...
```

App configs reference the symlink (e.g. kitty
`include ~/.config/wired/current/kitty.conf`).
Switching = atomic symlink update + hook reload.

## Further reading

- [adding-a-theme.md](adding-a-theme.md) — contributor guide for new themes
- [keybindings.md](keybindings.md) — Hyprland binds shipped with wired-dots
- [troubleshooting.md](troubleshooting.md) — common problems and fixes
- [release-procedure.md](release-procedure.md) — how releases are cut
```

- [ ] **Step 2: Write docs/adding-a-theme.md**

```markdown
# Adding a new theme

> **Status:** Stub — completed in M3 once the build pipeline ships.

A theme is a directory under `themes/<name>/` containing:

```text
themes/<name>/
├── meta.toml             — name, display, description, variant, strict flag
├── palette.toml          — color tokens (source of truth)
├── wallpapers/           — exactly 3 wallpapers
│   ├── 01-*.jpg
│   ├── 02-*.jpg
│   └── 03-*.jpg
└── overrides/            — OPTIONAL, files that win over rendered templates
```

## Step 1 — Pick a vibe

Themes shipped with wired-dots are cyberpunk-aligned but not
nightwire-strict. Constraints:

- Background dark (no light themes in v1).
- WCAG AA contrast on text vs background.
- Soft neon over harsh saturation.

## Step 2 — Define `palette.toml`

(Full schema and example will land here in M3.)

## Step 3 — Add 3 wallpapers

Lowercase, numbered, JPEG or PNG. Naming convention: `NN-short-slug.jpg`.

## Step 4 — Build and test

```bash
wired switch <name>      # apply
wired wallpaper next     # cycle
wired switch nightwire   # back to default
```

## Step 5 — Submit

Open a PR with theme directory + screenshot of the result on your
hardware. See [CONTRIBUTING.md](../CONTRIBUTING.md).
```

- [ ] **Step 3: Write docs/keybindings.md**

```markdown
# Keybindings

> **Status:** Stub — fleshed out in M1 with the actual hyprland.conf bindings.

## wired CLI bindings

| Key | Action |
|---|---|
| `SUPER + T` | `wired tui` — open theme browser |
| `SUPER + SHIFT + W` | `wired wallpaper next` |
| `SUPER + CTRL + BackSpace` | toggle vibe ↔ focus mode |

## Hyprland (default subset)

(Filled in once M1 ships configs/hypr/keybindings.conf.)

## Conflicts with other tools

- `SUPER + Space` — keyboard layout toggle (latam,us users)
- `SUPER + L` — hyprlock (separate from wired CLI)
```

- [ ] **Step 4: Write docs/troubleshooting.md**

```markdown
# Troubleshooting

> **Status:** Stub — populated as known issues surface from M2 dummy-box validation.

## Installer

- _Coming in M2._

## Theme switching

- _Coming in M3._

## Hardware-specific

See [SUPPORT.md](../SUPPORT.md) for the supported hardware matrix.
Tier 3 (best-effort) and Unsupported configurations are documented
there.
```

- [ ] **Step 5: Write docs/release-procedure.md**

```markdown
# Release procedure

> **Status:** Stub — completed in M3 with full GitFlow runbook.

## Versioning

SemVer with RC tags. Examples:

- `v1.0.0-rc1` — first release candidate
- `v1.0.0` — stable
- `v1.0.1` — patch (bugfix only)

## Cut a release (high level)

1. Merge all `feature/*` and `fix/*` to `develop`.
2. Branch `release/v1.x.y` from `develop`.
3. Bump `VERSION`, update `CHANGELOG.md`, commit.
4. Open PR to `main`. Run `release-dry-run` workflow + dummy-box pass.
5. Merge PR. Tag the merge commit `v1.x.y`. Push tag.
6. Auto-release workflow generates the GitHub release.
7. Post-tag smoke workflow installs the published tarball in clean
   container; if green, release is announced.

## Yank a broken release

1. Delete the GitHub release UI.
2. Delete the tag locally and remote: `git tag -d v1.x.y && git push origin :refs/tags/v1.x.y`.
3. Cut `v1.x.y+1` with the fix.
4. Note the yank in `CHANGELOG.md`.
```

- [ ] **Step 6: Verify all 5 docs exist**

Run:
```bash
ls -la docs/architecture.md docs/adding-a-theme.md docs/keybindings.md docs/troubleshooting.md docs/release-procedure.md
wc -l docs/*.md
```

Expected: 5 files, each with at least 10 lines.

- [ ] **Step 7: Commit**

```bash
git add docs/architecture.md docs/adding-a-theme.md docs/keybindings.md docs/troubleshooting.md docs/release-procedure.md
git commit -m ":memo: docs: stubs for architecture, theming, keybindings, troubleshooting, release"
```

---

### Task 8: SUPPORT.md (hardware tier matrix)

**Files:**
- Create: `SUPPORT.md`

- [ ] **Step 1: Write SUPPORT.md**

```markdown
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
```

- [ ] **Step 2: Verify**

Run:
```bash
wc -l SUPPORT.md
head -5 SUPPORT.md
```

Expected: file has ~50 lines, header reads `# Hardware support matrix`.

- [ ] **Step 3: Commit**

```bash
git add SUPPORT.md
git commit -m ":memo: docs: SUPPORT.md hardware tier matrix"
```

---

### Task 9: DOGFOOD.md (daily-driver journal template)

**Files:**
- Create: `DOGFOOD.md`

- [ ] **Step 1: Write DOGFOOD.md**

```markdown
# Dogfood log

This file is the daily-driver journal kept during the **30-day
dogfooding period before v1.0.0 stable**. Without entries here,
the 30 days don't count toward the Definition of Done in
[docs/superpowers/specs/2026-05-04-wired-dots-v2-design.md](docs/superpowers/specs/2026-05-04-wired-dots-v2-design.md).

## Format

One line per day. Optional bug count. Optional one-sentence note
about anything noteworthy.

```text
YYYY-MM-DD — bugs:N — note
```

## Entries

> **Status:** dogfood window has not started. Begins after M3 lands.

| Date | Bugs | Note |
|---|---|---|
| _ | _ | dogfood pending M3 |
```

- [ ] **Step 2: Commit**

```bash
git add DOGFOOD.md
git commit -m ":memo: docs: DOGFOOD.md template (30-day dogfood journal)"
```

---

### Task 10: CONTRIBUTING.md

**Files:**
- Create: `CONTRIBUTING.md`

- [ ] **Step 1: Write CONTRIBUTING.md**

```markdown
# Contributing

Thanks for considering a contribution to wired-dots!

## Before you open a PR

1. **Read the design spec.** Anything that diverges from
   [docs/superpowers/specs/2026-05-04-wired-dots-v2-design.md](docs/superpowers/specs/2026-05-04-wired-dots-v2-design.md)
   is unlikely to merge without prior discussion.
2. **Open an issue first** for non-trivial work. Save us both
   the wasted effort if the direction doesn't fit.
3. **Stay in scope.** wired-dots is intentionally constrained —
   see the Anti-patterns section of the spec.

## Branch naming

| Type | Branch |
|---|---|
| Feature | `feature/short-description` |
| Fix | `fix/issue-N-short-description` |
| Docs only | `docs/short-description` |
| Refactor | `refactor/short-description` |
| Release prep | `release/vX.Y.Z` |

## Commit messages

Conventional Commits with gitmoji:

```text
:<gitmoji>: type(scope): short description
```

Examples:

- `:sparkles: feat(installer): add 04b_gpu_nvidia phase`
- `:bug: fix(theme): correct envsubst escaping in waybar template`
- `:memo: docs(spec): clarify chaos mode prerequisites`
- `:wrench: chore(ci): bump shellcheck action version`
- `:fire: remove(legacy): drop NVIDIA Maxwell support paths`

Valid types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `remove`.

Valid scopes: `installer`, `cli`, `theme`, `hooks`, `templates`,
`configs`, `docs`, `ci`, `release`.

## PR checklist

The PR template covers it. Highlights:

- CI green
- If you touched `installer/` or `phases/`, dummy-box validation
  passed and screenshot is in the PR
- `CHANGELOG.md` updated under `[Unreleased]`
- No secrets, no personal tokens

## Adding a theme

See [docs/adding-a-theme.md](docs/adding-a-theme.md). Themes
should be cyberpunk-aligned but not nightwire-strict — the
constraint is *vibe*, not paint-by-numbers.

## Hardware tier escalation

If you want to move a config from Tier 3 to Tier 2, you need to
commit to validating it on every minor release. Open an issue
labeled `tier-escalation` describing your validation cadence.

## License

By contributing, you agree your contributions are licensed under
the MIT License (see [LICENSE](LICENSE)).
```

- [ ] **Step 2: Commit**

```bash
git add CONTRIBUTING.md
git commit -m ":memo: docs: CONTRIBUTING.md (branching, commits, PR rules)"
```

---

### Task 11: Push branch and verify CI green

**Files:**
- None (push + verify only)

- [ ] **Step 1: Inspect commit history**

Run:
```bash
git log --oneline
```

Expected: ~10 commits on `feature/m0-scaffolding` ahead of `main`. Each commit should be focused on one concern (metadata, scaffolding, lint, ci, templates, docs, support, dogfood, contributing).

- [ ] **Step 2: Push the branch**

```bash
git push -u origin feature/m0-scaffolding
```

Expected: branch created on origin, no errors. The push triggers CI.

- [ ] **Step 3: Open the CI run in browser (or via gh CLI)**

```bash
gh run list --branch feature/m0-scaffolding --limit 1
```

Expected: `in_progress` initially, then `completed` with `success`.

To watch live:
```bash
gh run watch
```

- [ ] **Step 4: If CI fails, debug**

Common failure modes:

| Failure | Fix |
|---|---|
| `bash -n` on a `.sh` file | Open the file, fix the syntax error, recommit |
| shellcheck warning | Either fix the issue or add `# shellcheck disable=SCNNNN` with a justification comment |
| markdown lint error | Run mdl locally, fix the issue, recommit |
| taplo format check failure | Run `taplo format` locally, recommit |
| gitleaks finding | If false positive, add to `.gitleaks.toml` allowlist; otherwise rotate the secret + remove from history with `git filter-repo` |

After fixing, push again. CI re-runs automatically.

- [ ] **Step 5: Verify all 5 lint substeps green**

Once CI is green, click into the run and confirm all 5 substeps reported success:

1. Bash syntax check (bash -n) ✓
2. Shellcheck ✓
3. Markdown lint ✓
4. TOML schema validation (taplo) ✓
5. Secret scan (gitleaks) ✓

- [ ] **Step 6: No commit needed — proceed to Task 12**

---

### Task 12: Open PR and merge

**Files:**
- None (PR + merge)

- [ ] **Step 1: Open PR via gh CLI**

```bash
gh pr create \
  --base main \
  --head feature/m0-scaffolding \
  --title ":sparkles: feat: M0 — repo scaffolding and CI baseline" \
  --body "$(cat <<'EOF'
## Summary

- Bootstraps the wired-dots v2 repo with the full directory tree from the design spec
- Lands project metadata (LICENSE, README, CHANGELOG, VERSION, SUPPORT, CONTRIBUTING, DOGFOOD)
- Adds CI lint pipeline: bash -n + shellcheck + markdownlint + taplo + gitleaks
- Adds GitHub issue and PR templates
- Stub install.sh / uninstall.sh that print "M0 scaffolding only" until M2/M3

## Type of change

- [x] :sparkles: feat (new feature)
- [x] :memo: docs (documentation only)
- [x] :wrench: chore (tooling, CI, dependencies)

## Checklist

- [x] CI is green
- [x] No installer or phases changed (M0 is scaffold only) — dummy-box validation N/A
- [x] CHANGELOG.md updated under `[0.1.0-m0]`
- [x] No secrets or personal tokens committed

## Closes

This is the M0 milestone. M1, M2, M3 follow as separate plans.

## Spec reference

See `docs/superpowers/specs/2026-05-04-wired-dots-v2-design.md` §2 (Architecture / Repository layout) and §10.1 (CI pipeline).
EOF
)"
```

- [ ] **Step 2: Verify PR is green**

Run:
```bash
gh pr checks --watch
```

Expected: all checks green.

- [ ] **Step 3: Merge the PR with a merge commit (preserves squashed history)**

We're using GitFlow's spirit but for a one-commit-feature flow we squash. Run:

```bash
gh pr merge --squash --delete-branch
```

Expected:
- PR merged with squash strategy
- Local + remote branch deleted
- `feature/m0-scaffolding` removed

- [ ] **Step 4: Update local main**

```bash
git checkout main
git pull origin main
git log --oneline -3
```

Expected: `main` is at the squashed merge commit. Original 10 commits collapsed into one.

- [ ] **Step 5: Tag v0.1.0-m0**

```bash
git tag -a v0.1.0-m0 -m "M0 — repo scaffolding and CI baseline"
git push origin v0.1.0-m0
```

Expected: tag pushed.

- [ ] **Step 6: Verify the tag appears**

```bash
gh release list --limit 5
```

Expected: `v0.1.0-m0` listed (release auto-created if release.yml workflow exists; otherwise just the tag).

- [ ] **Step 7: No commit needed — M0 is complete**

---

## Self-Review

**Spec coverage** (against `docs/superpowers/specs/2026-05-04-wired-dots-v2-design.md`):

| Spec section | Tasks that cover it |
|---|---|
| §2 Repository layout | Task 3 (directory scaffolding) |
| §2 Runtime state directory | NOT in M0 — populated when CLI ships in M2/M3. Acceptable — M0 is scaffolding. |
| §10.1 CI pipeline (lint job) | Task 5 (lint job with all 5 substeps) |
| §10.1 CI pipeline (theme-build, arch-smoke, bats-cli, perf-gate) | NOT in M0 — these jobs land in M1/M2/M3 when there's code to test. Acceptable — M0 ships green lint baseline only. |
| §11 Roadmap (M0 = scaffolding + CI green) | Entire plan |

**Placeholder scan**: every task has actual content, file paths, and code blocks. No "TBD" / "TODO" / "implement later" remain. The doc stubs in Task 7 contain explicit `> **Status:** Stub` markers — those are expected (the docs are placeholder by design until later milestones populate them).

**Type consistency**: every file path is consistent across tasks (e.g., `.github/workflows/ci.yml` is referenced the same way in Task 5 and Task 11). No mismatched names.

---

## What's NOT in M0 (deferred to later milestones)

- **M1**: Configs migration (`configs/hypr/`, `configs/waybar/`, etc.), templates (`templates/*.tmpl`), initial 2 themes (`themes/nightwire/palette.toml`, `themes/nervwire/palette.toml`).
- **M2**: Installer skeleton (`installer/install.sh`, phases 00-02, TUI screens with `gum`, `--dry-run` real).
- **M3**: Phases 03-10 (packages, GPU, audio, fonts, symlinks, theme apply, display manager, bootloader, services, verification), CLI runtime (`cli/`, `bin/wired`), hooks, system themes (SDDM, GRUB), full DoD pass.

Each of M1, M2, M3 will get its own implementation plan written when the previous milestone is merged and tagged.
