# Security Testing Scenarios - Playwright Examples

This guide shows practical examples of how to write `*.spec.sec.ts` tests with Playwright to fight and validate the main vulnerabilities listed in the OWASP Top 10.

---

## 1. Cross-Site Scripting (XSS) - defensive input validation

The test tries to submit HTML tags and JavaScript payloads into form fields and checks whether the front end renders them sanitized or encoded, preventing arbitrary execution.

```typescript
import { test, expect } from '@playwright/test';

test.describe('Security Gate: Cross-Site Scripting (XSS) Prevention', () => {
  test('should escape and sanitize script payloads in comments', async ({ page }) => {
    await page.goto('/product/123');

    const commentInput = page.locator('textarea[name="comment"]');
    const submitBtn = page.getByRole('button', { name: /send/i });

    // Classic XSS payload
    const maliciousPayload = '<script>window.alert("xss")</script><img src="x" onerror="window.XSS_TRIGGERED=true">';

    await commentInput.fill(maliciousPayload);
    await submitBtn.click();

    // Reload the page to confirm persistence was sanitized
    await page.reload();

    // Assert the alert never fired and the tag never executed
    const isXSS = await page.evaluate(() => (window as any).XSS_TRIGGERED);
    expect(isXSS).toBeUndefined();

    // The text must render as plain text in the DOM, never as an active HTML element
    const renderedComment = page.locator('.comment-text').last();
    await expect(renderedComment).toHaveText(maliciousPayload);
  });
});
```

---

## 2. Insecure Direct Object References (IDOR / BOLA)

This scenario simulates a low-privilege user trying to access and manipulate another user's data by only changing numeric identifiers or UUIDs in the requests.

```typescript
import { test, expect } from '@playwright/test';

test.describe('Security Gate: Broken Object Level Authorization (BOLA)', () => {
  // Authenticate as a basic account (e.g. User ID 999)
  test.use({
    storageState: 'playwright/.auth/basic-user.json',
  });

  test('should forbid accessing invoice details of another user', async ({ page, request }) => {
    // Invoice ID that belongs to another user (e.g. User ID 111)
    const victimInvoiceId = 'invoice-111-secret';

    // 1. Validate security in E2E navigation
    await page.goto(`/dashboard/invoices/${victimInvoiceId}`);

    // It must redirect or show the proper error screen, never the details
    await expect(page).toHaveURL(/.*error|forbidden|unauthorized/);
    await expect(page.locator('text=/unauthorized|access denied/i')).toBeVisible();

    // 2. Validate security at the API data layer (front-end bypass prevention)
    const apiResponse = await request.get(`/api/invoices/${victimInvoiceId}`);
    expect(apiResponse.status()).toBe(403); // Or 401/404 to hide the resource
  });
});
```

---

## 3. Broken Authentication (access control bypass)

This scenario ensures that administrative requests sent to the backend through the Playwright context or direct navigation are summarily blocked when the user is logged out or lacks a valid token.

```typescript
import { test, expect } from '@playwright/test';

test.describe('Security Gate: Access Control Enforcement', () => {
  // Ensure a clean context, with no authorized cookies or tokens
  test.use({ storageState: { cookies: [], origins: [] } });

  test('should restrict administrative configuration pages to admins only', async ({ page }) => {
    await page.goto('/admin/settings');

    // It must redirect immediately to the login screen
    await expect(page).toHaveURL(/\/login/);

    // Hitting the API directly without a token must return Forbidden or Unauthorized
    const context = page.request;
    const response = await context.post('/api/admin/settings', {
      data: { maintenanceMode: true }
    });

    expect([401, 403]).toContain(response.status());
  });
});
```

---

## 4. SQL Injection (SQLi) - injection through forms/filters

Ensures that filter or search input containing SQL escape characters does not break the query runner or expose unmapped data.

```typescript
import { test, expect } from '@playwright/test';

test.describe('Security Gate: SQL Injection Protection', () => {
  test('should not leak data when query strings contain SQL escape characters', async ({ page }) => {
    await page.goto('/search');

    const searchInput = page.locator('input[type="search"]');

    // Classic SQL injection to extract every record
    const sqliPayload = "' OR '1'='1";
    await searchInput.fill(sqliPayload);
    await searchInput.press('Enter');

    // The system must handle it gracefully (e.g. show an empty-result message)
    // If it returns invoices or every product in the database, the gate fails.
    await expect(page.locator('.search-error-message')).not.toBeVisible();
    await expect(page.locator('.search-results')).toHaveCount(0);
  });
});
```

---

## 5. Rate limiting and brute force prevention

Ensures that sensitive routes such as login and password recovery block excessive requests with HTTP 429 Too Many Requests.

```typescript
import { test, expect } from '@playwright/test';

test.describe('Security Gate: Rate Limiting & Brute Force Prevention', () => {
  test('should block repeated invalid authentication attempts with HTTP 429', async ({ request }) => {
    const attempts = 10;
    let hitRateLimit = false;

    for (let i = 0; i < attempts; i++) {
      const response = await request.post('/api/auth/login', {
        data: {
          email: 'target-user@example.com',
          password: `wrong-password-${i}`,
        },
      });

      if (response.status() === 429) {
        hitRateLimit = true;
        break;
      }
    }

    expect(hitRateLimit).toBe(true);
  });
});
```

---

## 6. Open redirect prevention

Ensures that post-login redirect parameters (`?redirect=` or `?next=`) cannot be manipulated by attackers to send the user to malicious external domains (phishing).

```typescript
import { test, expect } from '@playwright/test';

test.describe('Security Gate: Open Redirect Protection', () => {
  test('should disallow redirecting to external malicious domains after authentication', async ({ page }) => {
    const evilUrl = 'https://attacker-controlled-site.com';
    await page.goto(`/login?redirect=${encodeURIComponent(evilUrl)}`);

    await page.fill('input[name="email"]', 'user@example.com');
    await page.fill('input[name="password"]', 'CorrectPassword123!');
    await page.click('button[type="submit"]');

    await page.waitForNavigation();

    // It must redirect to the internal home or dashboard, NEVER to the external domain
    const currentUrl = page.url();
    expect(currentUrl).not.toContain('attacker-controlled-site.com');
    expect(currentUrl).toMatch(/\/(dashboard|home|$)/);
  });
});
```

---

## 7. Sensitive data exposure and HTTP header validation

Validates that the application does not leak confidential data (PII, stack traces or encrypted passwords) in the API response and implements the essential defensive security headers.

```typescript
import { test, expect } from '@playwright/test';

test.describe('Security Gate: Sensitive Data Exposure & HTTP Security Headers', () => {
  test('should not leak password hashes or internal secrets in user profile responses', async ({ request }) => {
    const response = await request.get('/api/users/me', {
      headers: {
        Authorization: 'Bearer test-user-token',
      },
    });

    expect(response.ok()).toBe(true);
    const body = await response.json();

    // Forbidden response fields
    expect(body).not.toHaveProperty('password');
    expect(body).not.toHaveProperty('passwordHash');
    expect(body).not.toHaveProperty('salt');
    expect(body).not.toHaveProperty('secretKey');
  });

  test('should enforce strict HTTP security headers', async ({ page }) => {
    const response = await page.goto('/');
    expect(response).not.toBeNull();
    const headers = response!.headers();

    // Modern protection headers
    expect(headers['x-content-type-options']).toBe('nosniff');
    expect(headers['x-frame-options']).toMatch(/DENY|SAMEORIGIN/i);
  });
});
```
