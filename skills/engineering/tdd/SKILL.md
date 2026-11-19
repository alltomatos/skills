---
name: tdd
description: Test-driven development with red-green-refactor loop. Use when user wants to build features or fix bugs using TDD, mentions "red-green-refactor", wants integration tests, or asks for test-first development.
---

# TDD - Test Driven Development

## PRINCIPLE
Test behavior through public interfaces. Do not test implementation details. Tests must survive refactoring.

* **Good tests (integration)**: exercise flows through public APIs. They work as a living specification.
* **Bad tests**: coupled to private methods or internal mocks. They break when internal code changes even without a behavior change.

*Examples in [tests.md](tests.md) and mock rules in [mocking.md](mocking.md).*

## ANTI-PATTERN: HORIZONTAL SLICES
Writing all the tests at once before coding is forbidden.

* **Reason**: batch tests guess behavior, testing type/shape instead of business value.

## EXECUTION RITE: VERTICAL SLICES

### 1. Scope (alignment)
Map the critical behaviors with the user. Focus only on happy paths and the main rules.

### 2. Tracer bullet (first flow)
Write ONE test to confirm ONE end-to-end behavior:
```
RED:   Write the test for flow 1 -> the test fails
GREEN: Minimum code to pass   -> the test passes
```

### 3. Incremental loop
For the following behaviors:
```
RED:   New test -> fails
GREEN: Minimum code -> passes
```
* **Rules**: one test at a time. Code only to pass the current test. Do not anticipate the future.

### 4. Refactor
While GREEN (passing):
* Remove duplication.
* Hide complexity behind simple interfaces.
* Apply SOLID.
* **Golden rule**: refactoring while RED is forbidden.

```checklist
[ ] The test validates behavior through a public API
[ ] The test survives internal refactoring
[ ] The code is the minimum to pass the test
[ ] No speculative features
```

## MANDATORY CLOSURE
GREEN reached -> record the evidence and wait for the mandatory `qa-analyst` gate. Only after QA approval, guide the PR flow available in the environment:

* Semantic commit (`feat:`, `fix:`, `refactor:`).
* Organized branch.
* PR template filled in.
