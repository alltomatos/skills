# Governance Rules for Fork: alltomatos/skills

**Status**: Active  
**Date**: 2026-06-04  
**Authors**: Ronaldo Davi (@alltomatos)  
**Context**: Fork of [mattpocock/skills](https://github.com/mattpocock/skills) with Brazilian Portuguese support

## Decision

The `alltomatos/skills` fork enforces strict scope boundaries through a dual-filter system: explicit inclusion in `.claude-plugin/plugin.json` AND exclusion of non-production buckets (`personal/`, `in-progress/`, `deprecated/`) from discovery and installation pipelines.

## Rationale

### Why Explicit Inclusion?

The original `mattpocock/skills` uses a "two-level discovery" pattern: the CLI walks up to 2 levels deep in `skills/` directories, finding all `SKILL.md` files. This works for a single-author repo but becomes problematic for forks where:

1. **Scope Control**: Forks accumulate experimental or personal skills that shouldn't be installed by default.
2. **Stability**: Skills in `in-progress/` are incomplete and may break user workflows.
3. **Privacy**: Skills in `personal/` contain configurations specific to the maintainer's environment.

The `.claude-plugin/plugin.json` acts as a "whitelist" — only skills listed there are considered part of the public API.

### Why Exclusion by Bucket?

Three buckets are intentionally excluded from discovery across all pipelines:

- **`personal/`**: Skills tied to maintainer's local setup (API keys, project-specific templates, dev tools)
- **`in-progress/`**: Skills under development, incomplete, or unstable
- **`deprecated/`**: Skills superseded by newer versions or no longer relevant

This exclusion is enforced in:
1. **`plugin.json`**: No skills from these buckets are listed
2. **`scripts/link-skills.sh`**: `find` command excludes these paths
3. **`scripts/setup-alltomatos-skills.sh`**: Same exclusion pattern

## Implications

### For Users

- **Stable Installation**: `npx skills@latest add alltomatos/skills` only installs production-ready skills
- **Privacy Protection**: No accidental exposure of personal configurations
- **Upgrade Path**: Skills in `deprecated/` remain in the repo for reference but aren't installed

### For Maintainers

- **Gradual Release**: Skills can live in `in-progress/` until mature enough for `plugin.json`
- **Personal Workspace**: `personal/` bucket allows maintainer to keep private skills in the same repo
- **Legacy Preservation**: `deprecated/` bucket serves as an audit trail without breaking existing installations

### Compatibility

The fork maintains 100% API compatibility with the original `mattpocock/skills`. Users can switch between forks seamlessly — the only difference is the set of skills available by default.

## Implementation

```bash
# In all scripts, the find command must exclude non-production buckets:
find "$REPO/skills" -name SKILL.md \
    -not -path '*/node_modules/*' \
    -not -path '*/deprecated/*' \
    -not -path '*/personal/*' \
    -not -path '*/in-progress/*'
```

The `.claude-plugin/plugin.json` must be the single source of truth for which skills are considered "public" and installable by default.

## Future Considerations

If new buckets are added, they should be evaluated against this governance model. The principle is: **explicit inclusion, implicit exclusion**.
