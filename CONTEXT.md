# alltomatos/skills

A collection of agent skills (behaviors and workflows) consumed through the repository link by Claude Code, Codex, OpenCode and other agents. Skills are organized into buckets and shipped according to `.claude-plugin/plugin.json`.

Fork of [mattpocock/skills](https://github.com/mattpocock/skills) - original architecture by Matt Pocock.

## Language

**Issue tracker**:
The tool that hosts a repository's issues - GitHub Issues, Linear, a local markdown convention under `.scratch/`, or similar. Skills such as `to-issues`, `to-prd`, `triage` and `qa` read from and write to it.
_Avoid_: backlog manager, backlog backend, issue host

**Issue**:
A tracked unit of work inside an **Issue tracker** - a bug, task, PRD or slice produced by `to-issues`.
_Avoid_: ticket (use it only when quoting external systems that call them tickets)

**Triage role**:
A canonical state-machine label applied to an **Issue** during triage (e.g. `needs-triage`, `ready-for-afk`). Each role maps to a real label string in the **Issue tracker** through `docs/agents/triage-labels.md`.

**Skill**:
A composable unit of instruction that extends the agent's behavior. Defined by a directory containing a `SKILL.md` with YAML frontmatter. It can be persistent (e.g. `caveman`) or one-shot (e.g. `triage`, `diagnose`).

**Bucket**:
A skill organization category - `engineering/`, `productivity/`, `misc/`. Skills under `personal/`, `in-progress/` and `deprecated/` are excluded from the distribution pipeline.

## Relations

- An **Issue tracker** holds many **Issues**
- An **Issue** carries one **Triage role** at a time
- A **Skill** belongs to a **Bucket**
- **Skills** under `engineering/`, `productivity/`, `misc/` -> listed in `plugin.json` and `README.md`
- **Skills** under `personal/`, `in-progress/`, `deprecated/` -> excluded from `plugin.json` and `README.md`

## Flagged ambiguities

- "backlog" was used to mean both the *tool* that hosts issues and the *body of work* inside it - resolved: the tool is the **Issue tracker**; "backlog" is no longer used as a domain term.
- "backlog backend" / "backlog manager" - resolved: collapsed into **Issue tracker**.
- "skill" vs "plugin" - resolved: **Skill** is the atomic unit; `plugin.json` is the repository manifest, not a skill.
