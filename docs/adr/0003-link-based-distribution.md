# Distribution by link, no installer

**Status**: Active
**Date**: 2026-11-19
**Author**: Ronaldo Davi (@alltomatos)
**Supersedes**: the installation pipeline described in ADR-0002

## Context

ADR-0002 made `plugin.json` the single source of truth and defined two scripts as the distribution
pipeline: `scripts/setup-alltomatos-skills.sh` and `scripts/link-skills.sh`. In practice that pipeline
accumulated problems that no point fix solved:

- the bootstrap path (`curl ... | bash`) downloaded the framework into `mktemp -d`, armed a
  `trap ... EXIT` and then ran `exec bash`; `exec` discards the trap, the temp directory is left behind
  and the installed skills are symlinks into it - when `/tmp` is cleaned, they all break;
- the installation only worked in bash with `ln -sfn`, which does not cover Windows and is not the same
  as a native symlink;
- the script scanned the disk to decide what to install, while `plugin.json` was the declared source -
  two criteria that already diverged (`devsetup` and `setup-skills`).

At the same time, harnesses started consuming repositories directly: marketplaces by URL in Claude Code
and `npx skills add owner/repo` in the other CLIs. A custom installer became an extra step that only
adds failure surface.

## Decision

1. **There is no installer.** Remove `scripts/setup-alltomatos-skills.sh` and `scripts/link-skills.sh`.
2. **`.claude-plugin/plugin.json` is the single source** of which skills are distributed. `personal/`,
   `in-progress/` and `deprecated/` stay out because they are not in the manifest.
3. **`.claude-plugin/marketplace.json`** publishes the repository as a Claude Code marketplace
   (`/plugin marketplace add alltomatos/skills`).
4. **`SKILLS.md` and `llms.txt` are generated artifacts** from `scripts/build-catalog.mjs`, built from
   `plugin.json` plus each `SKILL.md` frontmatter. They are never edited by hand.
5. **`AGENTS.md` is the entry point** for anyone arriving through the link: it tells the agent to read
   the catalog and fetch only what the task needs.

## Consequences

- Installing becomes: paste the link and ask for the skills, run `npx skills add alltomatos/skills`, or
  `/plugin marketplace add`. No permanent clone, no symlink, no accumulated backups.
- Updating no longer has a script: re-add the marketplace or repeat `npx skills add`. `developer` only
  reports the commit difference and never runs anything on its own.
- The catalog can go stale if someone forgets to run `build-catalog.mjs`. Generation is cheap and the
  diff is big enough to show up in review.
- A skill outside `plugin.json` is invisible to all three channels. That is the desired behavior: before,
  it was installed by one criterion and ignored by another.
- `devsetup` was later removed from the framework (2026-11-19). The reasoning above still holds: the
  manifest, not the disk scan, decides what is distributed.
