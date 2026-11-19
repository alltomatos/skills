---
name: roadmap
description: Manages the project's strategic state and Epics, keeping stable IDs and direct links to GitHub Issues. Must be consulted by any planning skill. Use when the roadmap, the Epics or their status need creating, updating or validating.
---

# Roadmap

Manage `DEVELOPER-ROADMAP.md` as the project's strategic compass. The roadmap summarizes the plan; the Epic's GitHub Issue is the detailed source of context and traceability.

## Required structure

The file must contain:

1. **Epics**: large objectives, each with a stable `E##` ID and a linked GitHub Issue;
2. **Milestones**: deliverable markers composed of tasks;
3. **State**: `todo`, `in_progress`, `done`;
4. **Links**: always in the format `[**[E10] Title**](https://github.com/OWNER/REPO/issues/123)`.

## Flow

1. Read the current roadmap and list every Epic.
2. Preserve existing IDs and assign the next available ID to new Epics.
3. Validate the GitHub remote and locate or create each Epic's Issue.
4. Update each title to carry the identifier and the direct link.
5. Sync state, objective and success criteria between roadmap and Issue.
6. Check for duplicates and broken links before finishing.

## Integrity checklist

```text
[ ] Every Epic has an E## ID
[ ] IDs do not repeat
[ ] Every Epic has a GitHub Issue
[ ] Every Epic has a direct /issues/<number> link
[ ] No Epic was left without a link
[ ] Milestones point to existing Epics
[ ] States reflect the current reality
```

If `DEVELOPER-ROADMAP.md` does not exist, create it only after confirming GitHub and the project context. If there are no Epics, record that situation; never invent Epics.
