---
name: to-issues
description: Turns plans, specs, PRDs and Epics into traceable GitHub Issues using stable IDs, direct links, vertical slices, dependencies and verifiable acceptance criteria. Use when work must be sliced into GitHub Issues.
---

# To Issues

Use GitHub as the mandatory tracker. If the remote or access is not configured, stop and guide the setup of the GitHub repository.

## Epic traceability contract

Every Epic in `DEVELOPER-ROADMAP.md` must have:

1. a stable identifier in the `E10`, `E11`, `E12` format;
2. a corresponding GitHub Issue;
3. a direct link to that Issue in the roadmap title or main line;
4. description, state and success criteria synced with the Issue.

Required format in the roadmap:

```markdown
## Epics

- [**[E10] Product foundation**](https://github.com/OWNER/REPO/issues/101) - `in_progress`
- [**[E11] Notification flow**](https://github.com/OWNER/REPO/issues/102) - `todo`
```

The `E##` identifier cannot be reused, even after an Epic is done. The GitHub Issue number does not replace the Epic identifier: `E10` stays stable even if the Issue is edited.

## Process

1. Read `DEVELOPER-ROADMAP.md`, the context, the ADRs, the requirements and the parent Issue comments, when there are any.
2. List every existing Epic and extract its IDs, states and links.
3. For each Epic without an ID, assign the next available ID without renumbering existing Epics.
4. For each Epic without a link, locate the corresponding Issue by title, labels and body; if it does not exist, create an Issue on GitHub.
5. Update the roadmap with the direct link in the `[**[E10] Title**](URL)` format.
6. Verify that no Epic is left without an ID, an Issue or a link.
7. Break the approved Epic into complete, small and verifiable vertical slices.
8. Mark each slice as HITL or AFK and define dependencies.
9. Present the proposal to the user when there is a decision about granularity, risk or architecture.
10. Publish the Issues in dependency order and use real IDs in the `Blocked by` field.
11. Update the Epic Issue with links to its child slices and keep the roadmap in sync.
12. Never close or change a parent Issue without explicit authorization.

## Mandatory validation

Before finishing, confirm:

```text
[ ] Every Epic has an E## identifier
[ ] Every Epic has a GitHub Issue
[ ] Every Epic has a direct link in the roadmap
[ ] Every link points to /issues/<number>
[ ] No Epic ID is duplicated
[ ] The Epic Issue references its child slices
[ ] Roadmap and GitHub states agree
```

If the roadmap is missing, report that there are no local Epics to map and do not invent Epics. If GitHub is unavailable, stop before publishing or declaring an Epic as tracked.

## Epic Issue template

```markdown
## Epic

E10 - Epic name

## Objective

Expected business or technical outcome.

## Success criteria

- [ ] Verifiable criterion 1
- [ ] Verifiable criterion 2

## Slices

- [ ] #123 - Vertical slice 1
- [ ] #124 - Vertical slice 2

## State

todo | in_progress | done
```

## Slice Issue template

```markdown
## Parent

Epic: E10 - [link to the Epic Issue]

## What to build

Concise description of the slice's complete behavior.

## Acceptance criteria

- [ ] Verifiable criterion 1
- [ ] Verifiable criterion 2

## Blocked by

- #123

## Verification

Commands, tests or expected evidence.
```
