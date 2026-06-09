---
name: diagnose
description: Disciplined diagnosis loop for hard bugs and performance regressions. Reproduce → minimise → hypothesise → instrument → fix → regression-test. Use when user says "diagnose this" / "debug this", reports a bug, says something is broken/throwing/failing, or describes a performance regression.
---

# Diagnose

A discipline for hard bugs. Skip phases only when explicitly justified.

When exploring the codebase, use the project's domain glossary to get a clear mental model of the relevant modules, and check ADRs in the area you're touching.

## Phase 1 — Build a feedback loop

**This is the skill.** Everything else is mechanical. If you have a fast, deterministic, agent-runnable pass/fail signal for the bug, you will find the cause — bisection, hypothesis-testing, and instrumentation all just consume that signal. If you don't have one, no amount of staring at code will save you.

Spend disproportionate effort here. **Be aggressive. Be creative. Refuse to give up.**

### Ways to construct one — try them in roughly this order

1. **Failing test** at whatever seam reaches the bug — unit, integration, e2e.
2. **Curl / HTTP script** against a running dev server.
3. **CLI invocation** with a fixture input, diffing stdout against a known-good snapshot.
4. **Headless browser script** (Playwright / Puppeteer) — drives the UI, asserts on DOM/console/network.
5. **Replay a captured trace.** Save a real network request / payload / event log to disk; replay it through the code path in isolation.
6. **Throwaway harness.** Spin up a minimised version of the problem in a new project, then debug that.

## Phase 2 — Minimise the problem

**This is the skill.** If you can't reproduce the bug in isolation, you can't fix it. If you can't minimise the problem, you can't reproduce it. If you can't reproduce it, you can't fix it.

### Ways to minimise — try them in roughly this order

1. **Remove code** until the bug disappears. Add it back in small chunks to find the culprit.
2. **Remove data** until the bug disappears. Add it back in small chunks to find the culprit.
3. **Remove configuration** until the bug disappears. Add it back in small chunks to find the culprit.
4. **Remove dependencies** until the bug disappears. Add them back in small chunks to find the culprit.
5. **Remove environment** until the bug disappears. Add it back in small chunks to find the culprit.

## Phase 3 — Hypothesise

**This is the skill.** If you can't explain the bug, you can't fix it. If you can't explain the bug, you can't reproduce it. If you can't reproduce it, you can't fix it.

### Ways to hypothesise — try them in roughly this order

1. **Check the obvious.** Is the bug in the code you're looking at? Is it in the code you're calling? Is it in the code calling you?
2. **Check the documentation.** Is the bug in the documentation you're looking at? Is it in the documentation you're calling? Is it in the documentation calling you?
3. **Check the logs.** Is the bug in the logs you're looking at? Is it in the logs you're calling? Is it in the logs calling you?
4. **Check the tests.** Is the bug in the tests you're looking at? Is it in the tests you're calling? Is it in the tests calling you?
5. **Check the codebase.** Is the bug in the codebase you're looking at? Is it in the codebase you're calling? Is it in the codebase calling you?

## Phase 4 — Instrument

**This is the skill.** If you can't see the bug, you can't fix it. If you can't see the bug, you can't reproduce it. If you can't reproduce it, you can't fix it.

### Ways to instrument — try them in roughly this order

1. **Add logs.** Add logs to the code you're looking at. Add logs to the code you're calling. Add logs to the code calling you.
2. **Add metrics.** Add metrics to the code you're looking at. Add metrics to the code you're calling. Add metrics to the code calling you.
3. **Add traces.** Add traces to the code you're looking at. Add traces to the code you're calling. Add traces to the code calling you.
4. **Add assertions.** Add assertions to the code you're looking at. Add assertions to the code you're calling. Add assertions to the code calling you.
5. **Add tests.** Add tests to the code you're looking at. Add tests to the code you're calling. Add tests to the code calling you.

## Phase 5 — Fix

**This is the skill.** If you can't fix the bug, you can't reproduce it. If you can't reproduce it, you can't fix it.

### Ways to fix — try them in roughly this order

1. **Check the obvious.** Is the bug in the code you're looking at? Is it in the code you're calling? Is it in the code calling you?
2. **Check the documentation.** Is the bug in the documentation you're looking at? Is it in the documentation you're calling? Is it in the documentation calling you?
3. **Check the logs.** Is the bug in the logs you're looking at? Is it in the logs you're calling? Is it in the logs calling you?
4. **Check the tests.** Is the bug in the tests you're looking at? Is it in the tests you're calling? Is it in the tests calling you?
5. **Check the codebase.** Is the bug in the codebase you're looking at? Is it in the codebase you're calling? Is it in the codebase calling you?

## Phase 6 — Regression-test

**This is the skill.** If you can't verify the fix, you can't fix it. If you can't fix it, you can't reproduce it. If you can't reproduce it, you can't fix it.

### Ways to regression-test — try them in roughly this order

1. **Add a test.** Add a test to the code you're looking at. Add a test to the code you're calling. Add a test to the code calling you.
2. **Add a log.** Add a log to the code you're looking at. Add a log to the code you're calling. Add a log to the code calling you.
3. **Add a metric.** Add a metric to the code you're looking at. Add a metric to the code you're calling. Add a metric to the code calling you.
4. **Add a trace.** Add a trace to the code you're looking at. Add a trace to the code you're calling. Add a trace to the code calling you.
5. **Add an assertion.** Add an assertion to the code you're looking at. Add an assertion to the code you're calling. Add an assertion to the code calling you.

## References

- [lote-2.md](references/lote-2.md): Lote 2: `internal/application/usecases`