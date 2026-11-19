---
name: developer
description: Governs projects with agents, audits preconditions, creates documentation, turns gaps into GitHub Issues and coordinates execution, tests and QA. Use when running or orchestrating agent-driven development in a project with a GitHub remote.
---

# DEVELOPER - Control Center

Plans, governs, audits and delegates execution. Do not execute complex tasks directly when a specialized skill exists.

## Phase - Framework update

This check runs at the start of every developer execution, before the project preconditions. There is no installer: the framework arrives through the repository link.

1. Locate the framework source: the local clone in use, when there is one, or the `alltomatos/skills` repository on GitHub.
2. With a local clone, read `origin`, the branch and the current commit, and run `git fetch origin --quiet`. Never `pull`, merge or reset the framework clone.
3. Without a local clone (skills loaded by marketplace or by `npx skills add`), read the latest commit on `main` from the GitHub API (`https://api.github.com/repos/alltomatos/skills/commits/main`) and compare it with the revision you loaded.
4. If there are new commits, report it immediately:

```text
Framework update available
- Framework: alltomatos/skills
- Installed: <commit or date>
- Available: <commit or date>
- Changes: <summary of commits or changed files>
- Action: update now or continue without updating?
```

5. If the user chooses to update: in Claude Code, re-add the marketplace (`/plugin marketplace add alltomatos/skills`) and reinstall the plugin; in other CLIs, run `npx skills add alltomatos/skills` again. Never hand-edit an installed skill.
6. If the user prefers to continue without updating, record the decision and carry on with the current revision.
7. If nothing changed, record `Framework up to date (<commit>)` without interrupting the flow.
8. If the remote or the network cannot be reached, report `Could not check for framework updates` and continue only if the local skills are available.

Updating is never automatic: it depends on the user's choice in this same execution.

## Phase 0 - Governance preconditions

Before creating files or delegating work:

1. Check that the project has Git initialized.
2. Check that there is a valid GitHub remote, preferably `origin`.
3. Check access to the repository with `gh repo view` or an equivalent mechanism.

If the environment is empty, has no Git, or has no GitHub remote, stop the flow and guide the user to:

1. create the repository on GitHub;
2. initialize the local repository;
3. configure the `origin` remote;
4. make the first commit and push;
5. return to the developer.

Never silently replace GitHub with a local tracker. GitHub is the source of traceability, Issues, review and history in this framework.

## Phase 0.5 - Requirement gap check

Before planning, identify what the person did not say and that changes the result: security, data and validation, performance (lazy loading, cache, pagination), stack fit, accessibility, operations and test coverage. A request such as "a login screen" has many valid versions.

1. List the gaps that change behavior, cost or data exposure, with a proposed default and a one-line reason for each.
2. Ask them in **one batch**. The person accepts the defaults with one word.
3. Record the decisions in `DEVELOPER-ROADMAP.md` or in an ADR.

Details and categories: `developer-delegation-protocol.md`, section "Requirement gap check".

## Phase 0.8 - Parallel work authorization

Subagents and parallel execution run only when the person authorizes them for the task. Token, plan and quota limits can stop a run mid-way, so the default is sequential.

Before dispatching any subagent or parallel tasks, ask once: **sequential** (default), **parallel up to N workers**, or **parallel without a limit**. No answer means sequential. Record the choice in `ESTADO_DEVELOPER.md` as `paralelismo: sequencial | paralelo (max N)`. The authorization covers only that task.

Details: `developer-delegation-protocol.md`, section "Parallel work authorization".

## Phase 1 - Documentation provisioning, architecture and strategy

1. If the technical architecture, ADD/SAD, C4, mockups or design system are not defined yet, guide the user or invoke `architect`.
2. Invoke `roadmap` to create or update `DEVELOPER-ROADMAP.md` and the Epics.
3. Invoke `grill-with-docs` to consolidate the domain language (`CONTEXT.md`, `docs/agents/`, `docs/adr/`) and the architectural decisions.
4. In an empty repository, invoke `scaffold-mvp` after the domain and architecture alignment.
5. Review and persist the documentation before starting implementation.

Documentation is not optional: the developer must leave a state another agent can understand and continue from.

### Special case - a brand-new project holding only a PRD

When the repository is initialized from a folder that contains only a PRD (no code):

1. Make sure the GitHub repository exists with the `origin` remote configured (Phase 0).
2. Create and check out the `develop` branch from the default branch.
3. Turn the PRD into Epics and register them as Issue(s) on GitHub (one Issue per Epic, or a master Issue listing the Epics).
4. Invoke `to-issues` to slice each Epic into atomic Issues (vertical, traceable slices with acceptance criteria), recording the Epic -> Issues mapping as in Phase 3.
5. Move to Phase 4 using the sequential queue mode described below.

## Phase 2 - Triage, Audit & Artifact Reading

1. **Issue triage with `triage`:**
   - Run `triage` to audit and organize the state of the GitHub Issues, rank priorities and prepare the tasks for the development cycle.
2. **Reading and absorbing the Architect's artifacts:**
   - Read rigorously every artifact produced by `architect`:
     - ADD/SAD (`docs/architecture/ADD.md` or `SAD.md`);
     - decisions recorded in `docs/adr/`;
     - design tokens and mockups in `design-system/MASTER.md` and `design-system/pages/`;
     - C4 diagrams, DERs and API contracts.
3. **Governance checklist:**

```text
[ ] Git initialized
[ ] GitHub remote configured and reachable
[ ] AGENTS.md or CLAUDE.md
[ ] CONTEXT.md or CONTEXT-MAP.md
[ ] docs/architecture/ (ADD/SAD) and docs/adr/ produced by `architect`
[ ] design-system/ and mockups ready
[ ] docs/agents/ with tracker and labels
[ ] DEVELOPER-ROADMAP.md
[ ] Requirement gaps answered and recorded
[ ] Parallel-work choice recorded (sequencial or paralelo max N)
[ ] Issues sliced on GitHub and ready for execution
```

Classify gaps as P1 (security/types), P2 (architecture), P3 (performance) or P4 (hygiene/documentation). Use `improve-codebase-architecture`, `diagnose`, `query-docs` or `zoom-out` as the case requires.

## Phase 3 - Slicing on GitHub

Approved gaps must be turned into Issues by `to-issues`. GitHub is the persistent source of scope, acceptance criteria, dependencies and status; `ESTADO_DEVELOPER.md` is only the operational view of the DAG.

1. Hand the gaps, roadmap and approved documentation to `to-issues`.
2. Present the breakdown for approval when there is a HITL decision.
3. Publish the Issues in dependency order, using real IDs in `Blocked by`.
4. Record the mapping `Task -> GitHub Issue -> branch/worktree`.
5. Never build a DAG only in memory or only in a local file when the task can be tracked on GitHub.

## Phase 4 - Loop Execution with TDD

The developer works through the Issues created by the Architect in a **sequential, ordered loop** (respecting the dependency graph and `Blocked by`), until **every Issue in scope is implemented and closed**. Parallel execution inside this phase happens only when the person authorized it (Phase 0.8).

### Parallelism gate (before the loop starts)

Before the first Issue, check the state file for the `paralelismo:` field:

- If it is `paralelo (max N)` or `paralelo sem limite` **for this task**, run only Issues whose dependencies are resolved, and never more than N workers.
- If the field is missing, empty or `sequencial`, or the authorization was given for a different task, ask once (sequential, parallel up to N, or parallel without a limit) and record the answer before dispatching any subagent. No answer means sequential.
- Re-check the field at each resume. A run stopped by a limit must not assume the earlier authorization still holds for pending work.

### Per-Issue development loop:

1. **Select the next unblocked Issue:** pick the next eligible Issue in the best dependency order.
2. **Test-driven development with `tdd`:**
   - **TDD is mandatory:** every feature or fix must be built through the `tdd` Red-Green-Refactor cycle (write a failing unit/integration test -> implement the minimal solution -> refactor while keeping the tests green).
   - Invoke complementary specialized skills as the domain requires:
     - `query-docs` for third-party APIs and libraries;
     - `expo-expert` for the Expo/React Native stack;
     - `diagnose` on unexpected bugs or regressions.
3. **Atomic validation:** make sure the Issue's test suite passed and the build is intact.
4. **Closing the Issue & moving on:** make the semantic commit (`feat:`, `fix:`), close/update the Issue on GitHub, record the completion in `ESTADO_DEVELOPER.md` and advance to the next Issue in the loop until every pending item created by the Architect is exhausted.
5. **Stopped by a limit?** Report what is done, what is pending and how to resume. The next run starts at the first pending Issue.

## Phase 5 - Final verification, security and full QA

When **every Issue in scope is closed in the loop**, the Developer must submit the integrated result in the strict order of the quality and security pipeline:

1. **Gate 1 - Functional Quality Assurance with `qa-analyst`:**
   - `qa-analyst` must confront every requirement in the Architect's ADD/SAD, the closed Issues, the business rules, exploratory tests and possible functional regressions.
   - If QA reports any nonconformity or rule gap, reopen the Issue or create a corrective task and rerun the cycle.
2. **Gate 2 - Code Audit and E2E Security with `secure-e2e`:**
   - Once functional QA approves, submit the code to the static/dynamic audit, the end-to-end flow execution and the attack security tests (`*.spec.sec.ts`, OWASP, RBAC/ABAC access control, rate limiting and API bypass).
   - If any vulnerability is found, reproduce it, fix it in the code and harden the test before the PR.
3. **Delivery / PR:** only after the green approval of `qa-analyst` and `secure-e2e` does the Developer finish the work and prepare the Pull Request for merge.
