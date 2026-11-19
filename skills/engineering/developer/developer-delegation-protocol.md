# Developer Delegation Protocol

> Templates and supporting structures for `developer` v2.
> Imported by `SKILL.md` in the Mentoring, Fragmentation and Supervision sections.

---

## Requirement gap check (before planning)

Before any plan, the Developer identifies what the person left out and that changes the result. A request such as "a login screen" has many valid implementations, so the gaps come first.

Categories to check (skip those that do not apply):

| Category | Questions the Developer must answer or ask |
| --- | --- |
| Goal | What must the screen achieve? How is success measured? |
| Security | Authentication method, session lifetime, password policy, rate limiting, brute-force protection, MFA, transport and storage of sensitive data |
| Data | Validation rules, required fields, empty / loading / error states |
| Performance | Lazy loading, pagination, caching, expected volume, latency target |
| Stack | Framework that fits the existing project; a recommendation with reasons when the project is empty |
| Accessibility and responsiveness | Target devices, keyboard use, screen reader support |
| Operations | Logging, observability, deploy target, environments |
| Tests | Coverage expected before QA |

Rules:

- Ask all the gaps that change behavior, cost or data exposure in **one batch**.
- For each gap, propose a default with a one-line reason; the person accepts the defaults with one word.
- Do not invent answers to gaps that change behavior, cost or data exposure.
- Record each decision in `DEVELOPER-ROADMAP.md` or in an ADR.

The same check applies to the design skills (`architect`, `grill-feature-with-docs`, `scaffold-mvp`) before they produce any artifact.

---

## Parallel work authorization (subagents)

Subagents and parallel execution are **opt-in per task**. Token, plan and quota limits can stop a run in the middle, leaving work half-done, so the default is sequential.

Before spawning any subagent or dispatching tasks in parallel, ask once:

1. **Sequential** (default): one task at a time, in the main session.
2. **Parallel up to N workers**: the person sets N.
3. **Parallel without a limit**.

Rules:

- No answer means sequential.
- An authorization covers only the task it was given for; a new task asks again.
- Record the choice in `ESTADO_DEVELOPER.md` at the project root: `paralelismo: sequencial | paralelo (max N)`.
- Write each task's completion to the state file before starting the next, so a stopped run resumes at the next pending task.
- Re-check the `paralelismo:` field at every resume.
- When a limit stops the run, report in one short message: what is done, what is pending, how to resume.

---

## Delegation autonomy matrix

The Developer operates on **risk tiers**. Autonomy is granted according to the nature of the task:

### Tier 1: Direct route ("Fast Path" - minimal risk)

The Developer treats T1 tasks (cleanup, simple documentation that does not change logic, safe refactors, and tool/linter setup) as eligible for the **Fast Path**:

- **Process bypass**: skips the global strategic roadmap update/audit and the bureaucratic, extensive interrogation sessions through `grill-with-docs` or `grill-me`. The requirement gap check still applies when the task changes behavior.
- **Atomic execution**: the Developer plans and executes the task directly.
- **Mandatory quality guardrails**: the flow must still honor TDD strictly and invoke `qa-analyst` before any PR. If no PR skill is available, guide the Git flow manually and ask for human confirmation.
- **Action**: executes -> logs in `ESTADO_DEVELOPER.md` -> finishes the PR for the atomic change.

### Tier 2: Batch execution (medium risk)

- **Environment configuration**: installing linters and formatters, instrumenting test coverage, writing structural ADRs and localized performance improvements without breaking changes.
- **Reduced bureaucracy**: requires alignment with the active `roadmap` before running the batches, but allows commit aggregation.
- **Action**: executes the batch under the TDD guardrail -> logs in `ESTADO_DEVELOPER.md` -> reports at the end of the batch.

### Tier 3: Strategic governance (interactive, mandatory)

For decisions that affect the project's domain, autonomy is **suspended**. The Developer must pause, present the plan and wait for the human "Go".

- **Domain changes**: defining data models, new features, macro architecture changes (for example moving from a monolith to microservices).
- **Roadmap**: any change to strategic direction, Epic prioritization or deadline setting.
- **Business rules**: any modification that changes application behavior relative to the user's rule.
- **Action**: stops the flow -> presents PRD/Roadmap -> waits for user approval.

---

## Risk approval trigger

- **Tier 1 (Fast Path):** execution without human interruption, validating the local TDD and semantic commits in the Git flow.
- **Tier 2 (Batchable):** batch execution. The Developer groups the result, requires a roadmap check, and reports when the block finishes or when TDD fails.
- **Tier 3 (High risk):** requires explicit prior approval of the overall task plan. Tasks inside an approved plan proceed only if the full test suite passes and static type analysis reports no contract break; otherwise the run stops and asks for intervention. Each such decision is logged in `ESTADO_DEVELOPER.md` as "DECISÃO AUTÔNOMA" with the reason.

---

## Fragmentation rules (DAG & atomization)

The Developer fragments the macro plan into atomic tasks and identifies the dependencies between them.

### Sequential by default

Tasks run one at a time, in dependency order, unless the person has authorized parallel work (see the authorization section above).

### Parallel execution (only when authorized)

When the person authorized parallelism:

1. **DAG parallelism**: run concurrently only tasks whose dependencies are resolved, and never more than the authorized number of workers.
2. **Isolation**: each parallel worker runs in its own Git worktree, so the active branch is not touched by parallel changes.
3. **Heavy single tasks** (schema migration, infrastructure refactor, a new module, or more than ~10 minutes of work) run in a dedicated worktree even when there is no parallelism.
4. **Merge**: when workers finish, the Developer collects the branches, resolves conflicts, and validates the whole build before continuing.

### Parallelism scope

Parallelism applies only inside Phase 4, across tasks whose dependencies are already resolved. The phases themselves stay sequential, and each phase waits for the previous skill's confirmation before the next one starts.

### DAG declaration structure (dependency graph)

The Developer persists the model in `ESTADO_DEVELOPER.md` at the project root:

```markdown
### Tasks
- [ ] T1: Configure environment and base scripts (Tier 1) | depends_on: []
- [ ] T2: Implement the domain validator (Tier 2) | depends_on: [T1]
- [ ] T3: Critical schema change (Tier 3) | depends_on: [T2]
```

---

## Sequential queue protocol and state management

The Developer **never** manages tasks only in short-term memory. Persisted state is king.

### Quick delegation guide

The Developer must consult this table before dispatching any delegation:

| Problem | Skill |
| --- | --- |
| Governance & orchestration | `developer` |
| Versioning & PRs | Git flow available in the environment, with human confirmation |
| Missing domain language | `grill-with-docs` |
| Degraded architecture | `improve-codebase-architecture` |
| Hard bug or regression | `diagnose` |
| Code without tests | `tdd` |
| Post-development QA analysis (mandatory before the PR) | `qa-analyst` |
| Missing context | `zoom-out` |
| Unmapped bottleneck | `write-a-skill` |
| Alignment before a change | `grill-me` |
| Handoff to another agent | `handoff` |

---

### Operations manager execution cycle

1. **Update state**: read and write `ESTADO_DEVELOPER.md` at the project root after every completed task.
2. **Check blockers**: identify the next task whose dependencies are already finished.
3. **Delegation and return**: dispatch the task to the associated skill; wait for completion; record the result.
4. **Sanity checkpoint (every 3-5 completions)**:
   ```checklist
   [ ] Are the project's original premises still valid?
   [ ] Was there a technical deviation that requires replanning the DAG?
   [ ] Did new dependencies or P1-criticality GAPs appear during execution?
   ```
   *If it fails*: recalculate routes, edit the DAG in the state file and restart execution in a controlled way.

---

## Operating protocol: quality and validation

1. **Wait-and-validate**: the Developer waits for the previous skill's full confirmation before the next delegation starts. Inside a phase, parallel DAG tasks run only when authorized.
2. **Quality in tiers**:
   - **Setup phase**: full interactivity. No command runs automated without positive feedback.
   - **Planning phase**: the gap check, `roadmap` and a plan are mandatory. No code delegation happens before the plan is approved in `DEVELOPER-ROADMAP.md`.
   - **Execution phase**: the focus is atomicity. If a complex task appears, it **must** be sliced before execution.
3. **Strategic patience**: it is better to spend 5 extra minutes in setup than to delete and rebuild files because of context failures.

---

## Template: test supervision (during and after the queue)

### 1. Queue checkpoint (after every task that changes code)

Before marking the task as `completed` in the state, the Developer must validate the test suite locally:

- Does the changed functionality have tests? (checked via `git diff` / reading the files)
- Is the local test runner (`npm test`, `pytest`, etc.) green?

If it fails: invoke `diagnose` immediately on the affected unit before moving to the next DAG task.

### 2. Post-queue supervision (overall completion)

After the last DAG task moves to `completed`, run the final aggregate supervision:

```checklist
[ ] The full test suite passes?
[ ] New test files (.test.* / .spec.*) were created or modified?
[ ] Did code coverage hold or increase against the baseline?
[ ] Was any flaky test (intermittent failure) introduced?
[ ] Was any credential or secret exposed in test files or fixtures?
```

- Optional: produce an impact summary of the changes.

### 3. QA gate (mandatory, pre-security)

For every task that results in a code change, the completion cycle does **not** advance without the `qa-analyst` analysis. This applies to **every tier**, including Fast Path (T1) - there is no bypass.

- [ ] Was `qa-analyst` invoked on the diff/code produced in this task?
- [ ] Were the original requirements confronted with the implementation (ambiguities? gaps?)
- [ ] Were error and unexpected-behavior test cases evaluated, not only the happy path?
- [ ] Were the bugs QA found recorded and fixed (or reopened as a new DAG task) before proceeding?

Failure at this gate -> **blocks** progress. The Developer reopens the DAG with the corrective tasks named by `qa-analyst` and proceeds only after a clean revalidation.

### 4. Security and E2E test gate (mandatory, pre-PR)

Once the increment is functionally approved by `qa-analyst`, the Developer must submit the code to the `secure-e2e` audit and offensive tests:

- [ ] Code security audit performed (OWASP, secure authentication, RBAC authorization, rate limit, sanitization)?
- [ ] Negative attack tests (`*.spec.sec.ts`) created or executed via Playwright CLI against critical routes and data?
- [ ] No breach or leak of confidential data (PII, tokens, passwords) detected?

Failure at this gate -> **blocks** progress to the PR. The Developer fixes the vulnerabilities and hardens the tests with `secure-e2e`.

### 5. PR protocol and cycle closure (mandatory)

Only after the formal approval of `qa-analyst` AND `secure-e2e` may the Developer start the PR flow available in the environment. Never invoke a PR skill that is not installed:

- [ ] Does the commit follow Conventional Commits?
- [ ] Did the branch follow the `type/issue-description` pattern?
- [ ] Was the PR template filled in?
- [ ] Was any credential or secret exposed?

---

## Quick reference: GAP -> Skill mapping

| Identified GAP | Delegated skill | Risk tier |
|----------------|-----------------|-----------|
| Missing requirement detail (security, data, performance, stack) | `grill-with-docs` (ask in one batch) | Auto |
| Missing or fragile tests | `tdd` | Batch |
| End of development - mandatory QA analysis | `qa-analyst` | Mandatory (all tiers) |
| Code audit and E2E security tests | `secure-e2e` | Mandatory (all tiers) |
| Degraded/coupled architecture | `improve-codebase-architecture` | Batch |
| Bug/regression | `diagnose` | Block |
| Misaligned domain language | `grill-with-docs` | Auto |
| Empty repository needs a technical base and frameworks for an agile MVP | `scaffold-mvp` | Block |
| No skill covers the bottleneck | `write-a-skill` | Block |
