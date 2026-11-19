# ESTADO_DEVELOPER

> This file is the brain of the Developer session. It persists progress between interactions and lets work resume if the session drops or the context runs out.
>
> **Rule**: the Developer must read this file when starting and write to it at the end of every phase.

---

## Session

- **iniciado_em**: `YYYY-MM-DD HH:MM:SS`
- **fase_atual**: `Phase 3` | `Phase 4` | `Phase 5`
- **repositorio**: `<repo-name>`
- **paralelismo**: `sequencial` | `paralelo (max N)` | `paralelo (sem limite)` — the person's answer to the parallel-work question for this task. Empty or missing means `sequencial`. Covers only this task.
- **limite_atingido**: `none` | `<date> - <what is done / pending / how to resume>` — filled when a token, plan or quota limit stops the run.

---

## Identified GAPs (Phase 3)

| # | ID | Dimension | Severity | Description | Risk Tier | Status |
|---|----|-----------|----------|-------------|-----------|--------|
| 1 | `GAP-001` | Security | P1 | ... | T3 Blocking | 🔴 open |
| 2 | `GAP-002` | Architecture | P2 | ... | T2 Batchable | 🟡 queued |
| 3 | `GAP-003` | Lint | P4 | ... | T1 Auto | 🟢 done |

---

## Tasks (Phase 4 - DAG queue)

### ID convention

- `TASK-<NNN>` - unique identifier.
- `depends_on: ["TASK-<MMM>", ...]` - list of predecessor task IDs.

Skill names are references, not commands: a name that does not appear in `SKILLS.md` means no skill covers that step yet.

### Pending tasks

```yaml
- id: TASK-001
  desc: "Extract email validation into validators/email.ts"
  skill: refactor
  gap_ref: GAP-002
  depends_on: []
  status: ready

- id: TASK-002
  desc: "Create tests for validators/email.ts"
  skill: `tdd`
  gap_ref: GAP-002
  depends_on: [TASK-001]
  status: blocked

- id: TASK-003
  desc: "Update the authentication ADR"
  skill: `grill-with-docs`
  gap_ref: GAP-002
  depends_on: []
  status: ready
```

### Completed tasks

```yaml
- id: TASK-000
  desc: "Example of a completed task"
  skill: `roadmap`
  gap_ref: GAP-000
  depends_on: []
  status: done
  concluido_em: "YYYY-MM-DD HH:MM:SS"
```

---

## Sanity checkpoints (Phase 4.5)

| # | After task | Date | Reassessment needed? | Action taken |
|---|------------|------|----------------------|--------------|
| 1 | TASK-003 | `...` | No | Continue the queue |
| 2 | TASK-006 | `...` | Yes - context changed | Rerun Phase 3 partially |

---

## Self-applied action log (Tier T1)

| # | Date | GAP | Action | Result |
|---|------|-----|--------|--------|
| 1 | `...` | GAP-003 | Fix typo in README.md | `git diff` clean |
| 2 | `...` | GAP-004 | Run prettier over `src/` | No lint errors |

---

## Execution batch (Tier T2)

> Batchable tasks awaiting batch approval at the end of the cycle.

| # | GAP | Task | Skill | Status |
|---|-----|------|-------|--------|
| 1 | GAP-002 | Create unit tests for `auth.ts` | `tdd` | 🟡 pending_approval |
