---
name: secure-e2e
description: E2E and offensive/defensive security test suite with Playwright plus code audit. Performs static and dynamic vulnerability auditing (OWASP), thinks like an attacker to find gaps, generates security regression tests (*.spec.sec.ts) and guides the code remediation. Use when you need to audit code for flaws, create security tests, validate authentication/permissions or prevent regressions.
---

# Secure E2E & Offensive/Defensive Audit and Security Protocol

> **Credit**: original architecture inspired by Matt Pocock ([mattpocock/skills](https://github.com/mattpocock/skills)). Expanded to bring a full Security-by-Design culture, code auditing and defensive negative testing into the `alltomatos/skills` framework.

Most end-to-end (E2E) tests validate only the "happy path". This skill enables the agent to **think like a security auditor/analyst (white hat)**: investigate attack surfaces in the source code, discover failure vectors, prove the vulnerability through automated negative security tests (`*.spec.sec.ts`) and apply the definitive fix in the code.

---

## 1. Philosophy: attacker mindset and defense in depth

1. **Audit before executing**: analyze controllers, routes, authentication middlewares, data parsers and database queries before writing tests.
2. **Test the unhappy path (negative testing)**: if a route requires an admin profile, the test must try to bypass it with multiple profiles and forged tokens, ensuring the server actively rejects (HTTP 401/403).
3. **Do not trust the client**: the interface can hide buttons, but real security lives in the APIs. Every test must validate the front end by manipulating the DOM/local storage and, at the same time, fire direct requests through the API context (`request`).
4. **Full cycle: discover -> prove -> fix -> harden**:
   - finds the vulnerability in the code or architecture;
   - writes the negative test that reproduces it and fails while the gap exists (red);
   - fixes the vulnerability in the application (green);
   - keeps the test in the permanent security regression suite (refactor/shield).

---

## 2. The two fronts of this skill

### Front A: code audit and threat modeling

While inspecting the application source code, the agent audits:

- **Authentication & sessions**: token storage (`HttpOnly; Secure; SameSite` cookies vs `localStorage`), expiration and logout flow.
- **Authorization (RBAC/ABAC)**: presence of authorization middlewares on every sensitive route; no validation left to the front end only.
- **Input validation and typing**: strict schemas (Zod, Joi, Yup), HTML sanitization and injection prevention.
- **Data and secret exposure**: no secrets (`.env`, private keys, test passwords) hardcoded in the code or exposed on public endpoints.
- **Rate limiting**: protection on login, password recovery, token generation and message sending endpoints.

### Front B: automated Playwright tests (`*.spec.sec.ts`)

To distinguish the intent of tests in the project:

- `*.spec.ts` or `*.spec.func.ts` -> **functional tests**: real user flows and happy paths.
- `*.spec.sec.ts` -> **security tests**: automated attempts at bypass, injection, CSRF, IDOR/BOLA and flow abuse.

---

## 3. Execution flow with the Playwright CLI

```bash
# 1. Map sensitive forms and selectors (if needed)
npx playwright codegen http://localhost:3000

# 2. Run only the security tests
npx playwright test --grep "@security"

# 3. Diagnose failures or leaks through the Trace Viewer
npx playwright show-trace path/to/trace.zip
```

### Recommended script configuration (`package.json`)

```json
{
  "scripts": {
    "test:sec": "playwright test --grep \"@security\"",
    "test:sec:report": "playwright test --grep \"@security\" --reporter=html"
  }
}
```

---

## 4. Anti-patterns to avoid

- ❌ **Mocks in access validation**: never mock user permissions or authentication in security tests. The test must hit the real middlewares.
- ❌ **Visual validation only**: confirming that "the admin button disappeared from the screen" proves nothing about security. The underlying endpoint must return HTTP 403.
- ❌ **Hardcoded credentials**: do not use real credentials or static passwords in the repository. Use safe fixtures and environment variables (`process.env.TEST_USER_PASSWORD`).
- ❌ **Test database pollution**: ensure injection payloads and users created in negative tests are isolated or cleaned up at the end (teardown fixtures).
