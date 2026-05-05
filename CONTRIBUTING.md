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
