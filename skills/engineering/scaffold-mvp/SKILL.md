---
name: scaffold-mvp
description: Initialize a new project with an agile, high-productivity MVP stack. Focused on clean engineering boundaries, atomic configurations, and system stability without rush or architectural shortcuts. Use when starting a new project in an empty repository.
---

# Scaffold MVP

## Trigger
Activated **only** in new repositories, right after `grill-with-docs` runs (which establishes the shared language and the domain).

## Golden rule (inviolable)
**Building base UI components or infrastructure from scratch is expressly forbidden.**
Reusing shared components and mature libraries, focused on prototyping speed, is the top and non-negotiable priority.

## Stability and technical cadence (anti-rush)
The speed of an MVP cannot produce unstable code or structural pile-ups. The system's syntactic and architectural integrity is sovereign. The agent must discipline itself to:

1. **Incremental compilation check**: after installing any dependency or creating a base structural directory, run the local build or type-check command (e.g. `npx tsc --noEmit`, `go build`, `cargo check`). Never pile up changes without confirming the current build passes.
2. **Zero pseudocode**: escape comments such as `// ...` or `// rest of the code here` are expressly forbidden when creating routes or scaffold files. Every instantiated file must be self-contained and fully functional.
3. **Safe dependency setup**: pin library versions exactly. Always run the install explicitly to guarantee clean lockfile updates (`package-lock.json`, `go.sum`, `yarn.lock`).
4. **Bridges and contracts**: if the MVP depends on external services (such as a database or authentication), provide stubs/mocks usable locally in the scaffold. Do not let the app throw unhandled crashes on first boot.

## Workflow

### Phase 1: Context intake and technical proposal (aligned bootstrap)
You must not run "generic interrogations" about the business, because the domain was already established by the predecessor skill.

1. **Mandatorily read** `CONTEXT.md` and the `docs/adr/` folder.
2. **Requirement gap check** on the technical side, before proposing anything: authentication and security needs, data volume, performance (caching, lazy loading, pagination), accessibility and target devices, deploy target and observability. Ask the gaps that change the stack or the cost in **one batch**, each with a proposed default and a one-line reason.
3. Based on the discovered business domain and the answers, design a hyper-productive infrastructure. Take a consultative, opinionated stance in favor of speed.
4. If the context suggests a standard web application, categorically propose the proven ecosystem: **Next.js + Tailwind + shadcn/ui**. For another profile (e.g. CLI, worker, pure backend), propose the equivalent MVP stack in the respective language.
5. **Mandatory validation:** present the chosen stack and ask explicitly:
   > "Based on our domain context, I propose starting with [CHOSEN_STACK] for maximum productivity without reinventing the wheel. Do you agree with this stack, or is there an unmapped technical constraint?"

### Phase 2: Technical and structural execution
Proceed only after the user's explicit agreement. If the user suggests changes, adapt the bootstrap. Once approved:

1. **Project initialization (`package.json` / `go.mod` / `pyproject.toml`):** configure the ecosystem.
2. **Base stack installation:** (e.g. `npx shadcn-ui@latest init` when applicable).
3. **Agile directory structuring:** create the hierarchy focused on code reuse:
   - `/components/shared` (for reusable UI components injected through libraries)
   - `/lib` (utility functions and service integrations)
   - `/hooks` (custom state logic)
4. **Generate an agile README:** document the local run commands, the adopted architectural view and how rapid prototyping should be guided (focused on reuse).

## Return criteria
Finish by updating/recording the base stack and the decisions from the gap check in `CONTEXT.md` (under Technical Details) and hand the flow back to the Developer, reporting that the ground is ready for feature development.
