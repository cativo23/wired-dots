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
