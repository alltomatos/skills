# Skill Governance

This repository distributes skills for agent-assisted software development. The repository is the source of the framework and is consumed through its own GitHub link, with no installer.

## Language

Skill instructions are written in **English**, and that is the only copy — there are no per-language duplicates.

The language of the **output** is a separate thing and follows the person using the skill:

- Reply, and write every artifact the skill produces (PRD, ADR, QA report, mockups, commit messages when they are human-facing), in the language the user writes in.
- Default to Brazilian Portuguese when the user writes Portuguese, and to English when they write English.
- A consuming project can pin this by declaring `output_language` in its own `AGENTS.md`. That is the per-project switch; no code path in this repository reads it — the agent does.
- Never translate code, identifiers, file paths, skill names or commands.

So "use the skills in Portuguese" means instructions are read in English and everything that reaches the human comes back in Portuguese. It does not mean a second copy of the skills.

## Requirement gaps first

The person usually describes the goal, not every decision behind it. Before planning or implementing any request, the agent identifies what the person did not say and that changes the outcome. Example: "a login screen" has many valid versions, so the agent checks the gaps before writing code.

Check these categories, and only ask about the ones that apply to the request:

- **Goal**: what the screen or feature must achieve, and how success is measured;
- **Security**: authentication method, session lifetime, password policy, rate limiting, brute-force protection, MFA, data in transit and at rest;
- **Data**: validation rules, required fields, empty, loading and error states;
- **Performance**: lazy loading, pagination, caching, expected volume and latency;
- **Stack**: the framework that fits the existing project, or a recommendation when the project is empty;
- **Accessibility and responsiveness**: target devices, keyboard use, screen readers;
- **Operations**: logging, observability, deploy target, environments;
- **Tests**: what must be covered before QA.

Rules:

- Ask all the gaps that matter in one batch, not one at a time.
- For each gap, propose a default with a one-line reason. The person accepts the defaults with one word.
- Record the decisions in `DEVELOPER-ROADMAP.md` or in an ADR, so they survive the session.
- Do not invent answers to gaps that change behavior, cost or data exposure.

## Autonomy and parallel work

Subagents and parallel execution are **opt-in per task**. Parallel work spends more tokens, can exhaust the person's plan or quota in the middle of a task, and leaves work half-done. Token and plan limits are the constraint, not capability.

Rules:

- Before spawning any subagent or running tasks in parallel, the agent asks the person once for that task, with the options: **sequential** (default), **parallel up to N workers**, or **parallel with no limit**.
- Without an answer, the agent works sequentially, alone.
- An authorization covers only the task it was given for. A new task asks again.
- The answer is recorded in `ESTADO_DEVELOPER.md` as `paralelismo: sequencial | paralelo (max N) | paralelo sem limite`.
- Every task completion is written to the state file before the next one starts, so a run stopped by a limit resumes at the next pending task and does not repeat finished work.
- When a limit stops the run, the agent reports what is done, what is pending and how to resume, in one short message.

## Buckets

Skills live under `skills/`:

- `engineering/` - day-to-day code work;
- `productivity/` - general workflow;
- `misc/` - maintained but rarely used utilities;
- `personal/` - personal setup, not distributed;
- `in-progress/` - drafts, not distributed;
- `deprecated/` - retired skills, not distributed.

Distributed skills must have a `SKILL.md` and be listed in `.claude-plugin/plugin.json`, which is the single source of truth for what ships.

## Harness neutrality

Skill content must not name mechanisms exclusive to one harness (for example the `Agent` tool, `subagent_type=Explore` or the `Task` tool). Describe the shape of the delegation ("run subagents, only when the person has authorized parallel work") and leave the mechanism to whichever harness is running.

A skill is referenced by name in backticks, without a slash: `tdd`, `architect`, `qa-analyst`. The slash was dropped on purpose — it only exists in harnesses with slash commands, and in Claude Code installed as a plugin the command becomes `/alltomatos-skills:<name>`. To run the referenced skill, load its `SKILL.md`, whose path is in `SKILLS.md`.

Every distributed skill has an `agents/openai.yaml` next to its `SKILL.md`, with `interface.display_name` and `interface.short_description` for the Codex picker. Skills with `disable-model-invocation: true` in `SKILL.md`, or that are inherently harness-specific (such as `git-guardrails-claude-code`), mirror that with `policy.allow_implicit_invocation: false`.

## Distribution by link

There is no installer. The repository is distributed by its own address, and an agent that receives the link orients itself with these files:

- `AGENTS.md` (this file) - what the repository is and how it is organized;
- `SKILLS.md` - full catalog: name, when to use, path, raw URL and support files;
- `llms.txt` - compact index in the llms.txt format;
- `.claude-plugin/plugin.json` - single source of truth for which skills ship.

Ways to consume it, without a permanent clone:

| Where | Command |
| --- | --- |
| Claude Code | `/plugin marketplace add alltomatos/skills` then `/plugin install alltomatos-skills@alltomatos-skills` |
| CLIs with skill support | `npx skills add alltomatos/skills` |
| Any agent | read `SKILLS.md`, pick the skill, fetch its `SKILL.md` from the raw URL together with the listed support files |

### How each harness finds this repository

| Harness | File it reads on its own | Fallback |
| --- | --- | --- |
| Claude Code (plugin) | `.claude-plugin/marketplace.json`, `.claude-plugin/plugin.json` | `AGENTS.md` |
| Codex | `AGENTS.md`, each skill's `agents/openai.yaml` | `SKILLS.md` |
| Gemini CLI | `GEMINI.md` | `AGENTS.md` |
| Cursor | `.cursor/rules/alltomatos-skills.mdc` | `AGENTS.md` |
| GitHub Copilot | `.github/copilot-instructions.md` | `AGENTS.md` |
| OpenCode, Cline, Windsurf and others | `AGENTS.md` | `SKILLS.md` |
| Agent that cannot read a repository | receives the link and is told to fetch `SKILLS.md` | each `SKILL.md` raw URL |

When adding or changing a skill, run `node scripts/build-catalog.mjs` to regenerate `SKILLS.md` and `llms.txt`. Never edit those two by hand.

## The Developer contract

`developer` must:

1. check at the start whether the framework has updates on the GitHub remote;
2. locate the source clone through the installed skills, even when the consuming project has no clone of the framework;
3. report new commits and point to the update path (re-add the marketplace or run `npx skills add` again);
4. verify the consuming project's local Git and GitHub remote;
5. block the implementation flow when no GitHub repository is configured;
6. run the requirement gap check (see above) before planning;
7. create or update documentation before implementation;
8. use `roadmap` and `grill-with-docs` to establish strategy, domain language and governance;
9. ask for parallel-work authorization before any subagent runs (see above);
10. slice approved work with `to-issues` on GitHub;
11. keep `ESTADO_DEVELOPER.md` as the operational view, never as a replacement for GitHub Issues;
12. run verification, require `qa-analyst` before any PR, and reopen tasks when QA finds gaps.

The developer must not execute complex work directly when a specialized skill can be delegated.

## Consumer project governance

Before implementation, the project must have:

- Git initialized;
- an accessible GitHub remote;
- `AGENTS.md` or `CLAUDE.md`;
- `CONTEXT.md` or `CONTEXT-MAP.md`;
- `DEVELOPER-ROADMAP.md`;
- `docs/agents/issue-tracker.md`;
- `docs/agents/triage-labels.md`;
- `docs/agents/domain.md`;
- `docs/adr/` when there are relevant decisions.

GitHub is the source of Issues, traceability, review and history. Never fall back to a local tracker silently.

## Quality flow

The standard cycle is:

```text
Architect (`architect`) -> Issues (`to-issues`) -> Developer (`developer`) -> TDD (`tdd`) -> QA (`qa-analyst`) -> Security E2E (`secure-e2e`) -> PR
```

TDD, diagnosis, functional tests, QA analysis and the security E2E audit must run in that strict order before any PR. The QA (`qa-analyst`) and Security (`secure-e2e`) gates are mandatory at every risk tier.
