<p>
<a href="https://www.aihero.dev/s/skills-newsletter">
<picture>
<source media="(prefers-color-scheme: dark)" srcset="https://res.cloudinary.com/total-typescript/image/upload/v1777382277/skills-repo-dark_2x.png">
<source media="(prefers-color-scheme: light)" srcset="https://res.cloudinary.com/total-typescript/image/upload/v1777382277/skill-repo-light_2x.png">
<img alt="Skills" src="https://res.cloudinary.com/total-typescript/image/upload/v1777382277/skill-repo-light_2x.png" width="369">
</picture>
</a>

# Skills for Real Engineers (Fork)

[English](README.md) | [Português (Brasil)](README.pt-BR.md)

[![skills.sh](https://skills.sh/b/alltomatos/skills)](https://skills.sh/alltomatos/skills)

This repository is a fork of [mattpocock/skills](https://github.com/mattpocock/skills). All credit for the original design and architecture goes to **Matt Pocock** and the contributors of the original project.

This fork adds GitHub-driven governance, persistent documentation, planning by Issues, automatic framework verification, skill re-deploy and a mandatory QA gate. The idea is to make agent-assisted development fast without losing traceability, feedback and human control.

The skills are small, composable and adaptable. They work across models and agent CLIs. Hack them, adapt them, make them yours.

## Use it (no install)

The repository is the source. Paste the link and ask for the skills you want: there is no installer, no permanent clone and no environment variable.

```text
https://github.com/alltomatos/skills
```

| Where you are | What to do |
| --- | --- |
| Claude Code | `/plugin marketplace add alltomatos/skills` then `/plugin install alltomatos-skills@alltomatos-skills` |
| Codex, OpenCode, Cursor, Gemini, Copilot and other CLIs | `npx skills add alltomatos/skills` |
| Any agent, no CLI | Ask: "use the skills from https://github.com/alltomatos/skills - read SKILLS.md and load only the ones I ask for" |

`SKILLS.md` is the full catalog (name, when to use it, path, raw URL and support files). `llms.txt` is the compact index agents read first. Both are generated from `.claude-plugin/plugin.json`, which is the single source of truth for which skills ship.

### Language

Skill instructions are written in **English**, and there is a single copy of each skill. The language of the output is a separate matter and follows whoever is using the skill: reply in Portuguese and everything that comes back — PRDs, ADRs, QA reports, mockups — is in Portuguese. Set `output_language` in your project's `AGENTS.md` to pin it. The full contract is in `AGENTS.md`.

### Adding or changing a skill

1. Create the folder under `skills/<bucket>/<name>/` with the `SKILL.md` and its support files beside it.
2. Add the path to `skills` in `.claude-plugin/plugin.json`.
3. Run `node scripts/build-catalog.mjs` to regenerate `SKILLS.md` and `llms.txt`.

Skills under `skills/personal/` are not distributed and do not appear in the manifest.

## First run

With the skills loaded, open a project in your agent and run the architect to drive scope alignment, design system and technical architecture:

```text
architect
```

*(The `architect` skill covers discovery, active questioning, mockup/ADD generation and preparation of the architectural artifacts before handing off to execution.)*

The consuming project must be versioned in Git and have a remote repository on GitHub. In a new project:

```bash
git init
git add .
git commit -m "chore: initialize repository"
gh repo create <name> --source . --remote origin --push
```

If the environment is empty, without Git or without a GitHub remote, the architect/developer must stop and guide that process before implementing anything.

## Workflow: closed-loop engineering

1. **Framework update**: checks the repository (local clone, when present, or GitHub) and reports new commits. No installer: update by re-adding the marketplace or running `npx skills add` again.
2. **Governance and Scope**: validates Git, GitHub remote, authentication and project state.
3. **Architecture and Design (`architect`)**: runs active questioning, designs the solution (ADD/SAD, C4, ADRs, DER schemas), defines design tokens and screen mockups (`MASTER.md` + overrides), User Guides, and obtains the mandatory HITL approval from the user.
4. **Slicing into Issues (`to-issues`)**: cuts the Epics and approved specifications into vertical slices on GitHub with verifiable acceptance criteria and `Blocked by` dependencies.
5. **Orchestration (`developer`)**: coordinates the task queue and the per-Issue development loop, managing branches/worktrees.
6. **Test-Driven Development (`tdd`)**: applies a strict Red-Green-Refactor cycle to each issue (with support from `query-docs`, `expo-expert`, `diagnose`).
7. **Functional Quality Assurance (`qa-analyst`)**: mandatory pre-security gate; confronts requirements, edge cases, functional tests and acceptance criteria.
8. **E2E Audit and Security (`secure-e2e`)**: mandatory pre-PR gate; code audit (OWASP) and offensive/negative tests against browser and API (`*.spec.sec.ts`).
9. **Delivery (PR)**: only after QA and Security are green, runs the Pull Request flow with human confirmation.

GitHub is the persistent source of Issues, scope, acceptance criteria, dependencies, review and history. `ESTADO_DEVELOPER.md` is only the operational view of the DAG.

## The Developer

`developer` is the master skill of this fork (renamed from `orchestrator`), a concept that does not exist in the original repository. It evaluates, documents, delegates, supervises and expands the engineering flow.

`orchestrator` keeps working as a compatibility shortcut — it calls exactly the same skill, so installations made before the rename do not break.

### Golden rule

The developer does not do heavy work directly. It identifies the problem and delegates to the right skill. If no skill covers the bottleneck, it invokes `write-a-skill` to create one.

### Risk tiers

| Tier | Use | Behavior |
| --- | --- | --- |
| T1 | typo, lint, simple documentation | atomic execution and local verification |
| T2 | tests, small ADRs, limited changes | validates the roadmap and reports evidence |
| T3 | schema, authentication, data or public API | pauses and requires human approval |

## Why these skills exist

### 1. The agent did not do what I wanted

The most common failure mode is misalignment. `grill-me`, `grill-with-docs` and `grill-feature-with-docs` run a question session that turns intent into requirements, domain language and recorded decisions.

### 2. The agent is too verbose

A shared language reduces ambiguity, improves file and function names and makes the codebase easier to navigate. `grill-with-docs` records that language in `CONTEXT.md` and ADRs. See also the [`CONTEXT.md`](https://github.com/mattpocock/course-video-manager/blob/076a5a7a182db0fe1e62971dd7a68bcadf010f1c/CONTEXT.md) example from the original `course-video-manager` repository.

### 3. The code does not work

The agent needs feedback loops: types, browser, automated tests and minimal reproductions. `tdd` applies red-green-refactor and `diagnose` runs the cycle reproduce, minimise, hypothesise, instrument, fix and regression-test.

### 4. We built a ball of mud

Agents speed up coding and can speed up entropy too. `improve-codebase-architecture` promotes continuous design, clear boundaries and a more testable, navigable base.

### 5. The risk of autonomous development

Roadmap, GitHub Issues, documentation, worktrees and QA form a governance loop that limits scope drift and makes decisions auditable.

## Delegation table

| Problem | Skill |
| --- | --- |
| Governance and orchestration | [`developer`](./skills/engineering/developer/SKILL.md) |
| System architecture, ADD/SAD, C4, Mockups/UI and ADRs | [`architect`](./skills/engineering/architect/SKILL.md) |
| Roadmap and Epics | [`roadmap`](./skills/engineering/roadmap/SKILL.md) |
| Triage and issue management | [`triage`](./skills/engineering/triage/SKILL.md) |
| Domain language and ADRs | [`grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md) |
| A specific module or feature | [`grill-feature-with-docs`](./skills/engineering/grill-feature-with-docs/SKILL.md) |
| Slicing into GitHub Issues | [`to-issues`](./skills/engineering/to-issues/SKILL.md) |
| PRD | [`to-prd`](./skills/engineering/to-prd/SKILL.md) |
| Hard bug or regression | [`diagnose`](./skills/engineering/diagnose/SKILL.md) |
| Code without tests | [`tdd`](./skills/engineering/tdd/SKILL.md) |
| Third-party APIs | [`query-docs`](./skills/engineering/query-docs/SKILL.md) |
| Expo/React Native apps (EAS, Router, config plugins, upgrade) | [`expo-expert`](./skills/engineering/expo-expert/SKILL.md) |
| E2E and security | [`secure-e2e`](./skills/engineering/secure-e2e/SKILL.md) |
| Quality analysis | [`qa-analyst`](./skills/engineering/qa-analyst/SKILL.md) |
| Degraded architecture | [`improve-codebase-architecture`](./skills/engineering/improve-codebase-architecture/SKILL.md) |
| Throwaway prototype | [`prototype`](./skills/engineering/prototype/SKILL.md) |
| MVP bootstrap | [`scaffold-mvp`](./skills/engineering/scaffold-mvp/SKILL.md) |
| Missing context | [`zoom-out`](./skills/engineering/zoom-out/SKILL.md) |
| MCP servers | [`mcp-builder`](./skills/engineering/mcp-builder/SKILL.md) |
| SuperKuma deploy and monitoring | [`superkuma-monitoring`](./skills/engineering/superkuma-monitoring/SKILL.md) |
| Pre-commit hooks with Husky/Prettier | [`setup-pre-commit`](./skills/misc/setup-pre-commit/SKILL.md) |
| Git safety guards in the agent | [`git-guardrails-claude-code`](./skills/misc/git-guardrails-claude-code/SKILL.md) |
| Creating, evaluating and optimizing skills | [`skill-creator`](./skills/productivity/skill-creator/SKILL.md) |
| Ultra-compressed communication (token savings) | [`caveman`](./skills/productivity/caveman/SKILL.md) |
| Unmapped bottleneck | [`write-a-skill`](./skills/productivity/write-a-skill/SKILL.md) |
| Plan alignment | [`grill-me`](./skills/productivity/grill-me/SKILL.md) |
| Handoff | [`handoff`](./skills/productivity/handoff/SKILL.md) |

## Skills reference

### Engineering

Skills for daily code work: `architect`, `diagnose`, `grill-with-docs`, `grill-feature-with-docs`, `triage`, `improve-codebase-architecture`, `tdd`, `to-issues`, `to-prd`, `zoom-out`, `scaffold-mvp`, `prototype`, `roadmap`, `secure-e2e`, `qa-analyst`, `query-docs`, `expo-expert`, `mcp-builder`, `superkuma-monitoring` and `developer`.

`architect` acts as a senior Software, Solutions and Engineering Architect: designs systems for corporate level (production-readiness), runs scope alignment through active questioning, defines design tokens and screen mockups (MASTER+Overrides pattern) to guide developers, enforces engineering rigor (Clean Architecture, DDD, no N+1, OWASP, zero regression) and produces the key artifacts (ADD/SAD, C4 Model in Mermaid, ADRs, DER/MER schemas, OpenAPI/gRPC contracts and cloud/infrastructure topologies).

`orchestrator` is a compatibility shortcut: the same skill as `developer` (old name, kept so existing installations do not break).

`expo-expert` is stack-specific knowledge (Expo/React Native): CNG and config plugins, Expo Modules API, EAS Build/Submit/Update/Workflows, Expo Router, New Architecture, animation (Reanimated/Skia), Native UI, DOM components, data fetching and SDK upgrades. It teaches the agent to consult the living Expo documentation (`llms.txt` + `.md`) instead of trusting outdated training knowledge.

`mcp-builder` is a guide for building high-quality MCP (Model Context Protocol) servers in Python (FastMCP) and Node/TypeScript, with strict schemas, agent-oriented error handling and evaluation/benchmark scripts.

`superkuma-monitoring` covers the full SuperKuma monitoring cycle: deploying a new instance (Proxmox VM, Docker Compose + MariaDB), updating/upgrading an existing one, and operating the SuperKuma MCP server to discover a site's infrastructure (AD, Proxmox, VMware, Linux, pfSense, Mikrotik, switches, UniFi, TrueNAS, cameras) and turn it into monitors, tags, notifications and status pages.

### Productivity

General workflow skills: `caveman`, `grill-me`, `handoff`, `write-a-skill` and `skill-creator`.

`skill-creator` is a meta-skill for creating, testing, evaluating (qualitatively and quantitatively with evals/HTML viewer) and optimizing the trigger accuracy of new skill descriptions.

### Misc

Skills kept for specific cases: `git-guardrails-claude-code`, `migrate-to-shoehorn`, `scaffold-exercises` and `setup-pre-commit`.

Skills under `personal/`, `in-progress/` and `deprecated/` are not distributed.

## Documentation governance

The consuming project should keep `AGENTS.md` or `CLAUDE.md`, `CONTEXT.md` or `CONTEXT-MAP.md`, `DEVELOPER-ROADMAP.md`, `docs/agents/issue-tracker.md`, `docs/agents/triage-labels.md`, `docs/agents/domain.md` and `docs/adr/` when there are relevant decisions.

## Credits and origin

This project is a fork of [mattpocock/skills](https://github.com/mattpocock/skills). The original architecture, the inspiration and much of the skills came from Matt Pocock. See also the [skills newsletter](https://www.aihero.dev/s/skills-newsletter) to follow the original work.
