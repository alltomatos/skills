---
name: setup-skills
description: Provisions the project's documentation governance and validates GitHub as the mandatory tracker before the engineering skills are used. Use when starting work in a project that is not yet set up for the closed-loop flow.
---

# Setup Skills

## Process

### 1. Explore

Check `git status`, `git remote -v`, `AGENTS.md` or `CLAUDE.md`, `CONTEXT.md`, `docs/adr/` and `docs/agents/`.

### 2. GitHub governance

This framework uses GitHub as the source of Issues, traceability and review.

- If there is no Git, guide local initialization.
- If there is no GitHub remote, guide repository creation and `origin` configuration.
- Validate access with `gh repo view` or an equivalent tool.
- Never configure a local tracker as a silent fallback.

### 3. Project choices

Ask only what cannot be discovered yet:

- triage vocabulary, using `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human` and `wontfix` as defaults;
- domain layout: `CONTEXT.md` + `docs/adr/` or `CONTEXT-MAP.md`;
- branch, test and deploy conventions.

### 4. Artifacts

Create or update, without deleting existing content:

- `AGENTS.md` or `CLAUDE.md` with the `## Agent skills` section;
- `CONTEXT.md` or `CONTEXT-MAP.md`;
- `docs/agents/issue-tracker.md`;
- `docs/agents/triage-labels.md`;
- `docs/agents/domain.md`;
- `docs/adr/` when there are architectural decisions.

Record the GitHub remote and the choices made. Skills arrive through the framework's repository link and that should not be assumed inside this project.

### 5. Completion

Report the files created, the GitHub URL, the configured tracker and the next steps. If the GitHub precondition fails, close with unblocking instructions.
