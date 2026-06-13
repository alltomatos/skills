# Security Testing Scenarios - Playwright Examples

Este guia mostra exemplos práticos de como escrever testes no formato `*.spec.sec.ts` usando o Playwright para combater e validar as principais vulnerabilidades listadas no OWASP Top 10.

---

## 1. Cross-Site Scripting (XSS) - Validação de Entrada Defensiva

O teste tenta submeter tags HTML e payloads Javascript em campos de formulário e valida se a renderização no front-end os exibe de forma sanitizada ou codificada, prevenindo execução arbitrária.

```typescript
import { test, expect } from '@playwright/test';

test.describe('Security Gate: Cross-Site Scripting (XSS) Prevention', () => {
  test('should escape and sanitize script payloads in comments', async ({ page }) => {
    await page.goto('/product/123');

    const commentInput = page.locator('textarea[name="comment"]');
    const submitBtn = page.getByRole('button', { name: /enviar/i });

    // Payload clássico de XSS
    const maliciousPayload = '<script>window.alert("xss")</script><img src="x" onerror="window.XSS_TRIGGERED=true">';

    await commentInput.fill(maliciousPayload);
    await submitBtn.click();

    // Recarregar a página para certificar que a persistência foi sanitizada
    await page.reload();

    // Valida que o alerta não disparou e que a tag não executou
    const isXSS = await page.evaluate(() => (window as any).XSS_TRIGGERED);
    expect(isXSS).toBeUndefined();

    // O texto deve ser renderizado como texto plano no DOM, nunca como elemento HTML ativo
    const renderedComment = page.locator('.comment-text').last();
    await expect(renderedComment).toHaveText(maliciousPayload);
  });
});
```

---

## 2. Insecure Direct Object References (IDOR / BOLA)

Este cenário simula um usuário de baixo privilégio tentando acessar e manipular dados de outros usuários apenas alterando identificadores numéricos ou UUIDs nas requisições.

```typescript
import { test, expect } from '@playwright/test';

test.describe('Security Gate: Broken Object Level Authorization (BOLA)', () => {
  // Configura um usuário autenticado com conta básica (ex: User ID 999)
  test.use({
    storageState: 'playwright/.auth/basic-user.json',
  });

  test('should forbid accessing invoice details of another user', async ({ page, request }) => {
    // ID da fatura que pertence a outro usuário (ex: User ID 111)
    const victimInvoiceId = 'invoice-111-secret';

    // 1. Validar segurança na navegação E2E
    await page.goto(`/dashboard/invoices/${victimInvoiceId}`);
    
    // Deve redirecionar ou exibir tela de erro apropriada, nunca os detalhes
    await expect(page).toHaveURL(/.*error|forbidden|unauthorized/);
    await expect(page.locator('text=/não autorizado|acesso negado/i')).toBeVisible();

    // 2. Validar segurança no transporte de dados da API (Prevenção de bypass de front-end)
    const apiResponse = await request.get(`/api/invoices/${victimInvoiceId}`);
    expect(apiResponse.status()).toBe(403); // Ou 401/404 para ocultação de recurso
  });
});
```

---

## 3. Broken Authentication (Quebra de Controle de Acesso)

Este cenário garante que requisições administrativas enviadas ao backend da API através do Playwright context ou via navegação direta sejam sumariamente bloqueadas se o usuário estiver deslogado ou não possuir a chave de token válida.

```typescript
import { test, expect } from '@playwright/test';

test.describe('Security Gate: Access Control Enforcement', () => {
  // Certifica contexto limpo, sem cookies ou tokens autorizados
  test.use({ storageState: { cookies: [], origins: [] } });

  test('should restrict administrative configuration pages to admins only', async ({ page }) => {
    await page.goto('/admin/settings');

    // Deve redirecionar imediatamente para a tela de login
    await expect(page).toHaveURL(/\/login/);
    
    // Tentar acessar a API diretamente sem token deve retornar Forbidden ou Unauthorized
    const context = page.request;
    const response = await context.post('/api/admin/settings', {
      data: { maintenanceMode: true }
    });

    expect([401, 403]).toContain(response.status());
  });
});
```

---

## 4. SQL Injection (SQLi) - Injeção via Formulários/Filtros

Garante que entradas de filtros ou buscas contendo caracteres de escape do SQL não quebrem o runner da query ou exponham dados não mapeados.

```typescript
import { test, expect } from '@playwright/test';

test.describe('Security Gate: SQL Injection Protection', () => {
  test('should not leak data when query strings contain SQL escape characters', async ({ page }) => {
    await page.goto('/search');

    const searchInput = page.locator('input[type="search"]');
    
    // Injeção de SQL clássica para extrair todos os registros
    const sqliPayload = "' OR '1'='1";
    await searchInput.fill(sqliPayload);
    await searchInput.press('Enter');

    // O sistema deve tratar amigavelmente (exibir mensagem de nenhum resultado)
    // Se retornar as faturas ou todos os produtos do banco, o gate falha.
    await expect(page.locator('.search-error-message')).not.toBeVisible();
    await expect(page.locator('.search-results')).toHaveCount(0);
  });
});
```
