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
