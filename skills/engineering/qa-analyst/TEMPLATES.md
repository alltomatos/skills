# QA Templates

## Test case

```md
### TC-<area>-<number> - <short title>

- **Priority**: P0 (critical) | P1 (high) | P2 (medium) | P3 (low)
- **Type**: functional | error | unexpected | security | regression
- **Preconditions**: state required before the test (logged-in user, existing record X...)
- **Steps**:
  1. ...
  2. ...
- **Expected result**: observable, verifiable behavior
- **Actual result**: (fill in during execution) ✅ passed | ❌ failed → BUG-<id>
```

## Bug report

```md
### BUG-<number> - <title: observable symptom, not presumed cause>

- **Severity**: S1 (blocks use) | S2 (broken function, with workaround) | S3 (degradation) | S4 (cosmetic)
- **Priority**: P0-P3 (fix urgency - may differ from severity)
- **Environment**: OS, browser/version, branch/commit, data used
- **Reproduction steps** (minimal):
  1. ...
  2. ...
- **Expected result**: ...
- **Observed result**: ... (paste the literal error message / HTTP status)
- **Evidence**: screenshot, log, response body
- **Frequency**: always | intermittent (X of Y attempts)
- **Related test case**: TC-...
```

## Test plan

```md
# Test Plan - <feature>

## Scope
- **In**: ...
- **Out** (with justification): ...

## Prioritized risks
| # | Risk | Impact | Planned coverage |
|---|------|--------|------------------|

## Strategy per layer
| Layer | Tool | What it covers |
|-------|------|----------------|
| Unit | ... | ... |
| Integration/API | ... | ... |
| E2E | Playwright | ... |
| Exploratory manual | - | ... |

## Exit criteria
- All P0/P1 cases executed and passing
- No open S1/S2 bug
```

## Root cause analysis (post-cycle)

```md
### RCA - BUG-<number>

- **Root cause** (five whys, summarized): ...
- **Why it was not detected earlier**: gap in <layer/process>
- **Concrete preventive action**: <lint rule | contract test | checklist item | CI gate>
- **Regression test created**: <test path> | pending
```
