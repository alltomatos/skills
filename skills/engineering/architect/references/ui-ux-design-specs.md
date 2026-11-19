# UI/UX, Design Tokens and Mockup Specification Guide for Engineering

This document is the reference for the **Software and Solutions Architect** when defining the presentation layer, the design token architecture and functional mockups for the developers (`developer`).

> 💡 **Consulting the UI/UX Pro Max repository:**
> The Architect may and should consult the design intelligence base at **[nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)** (data files under `src/ui-ux-pro-max/data/` such as `styles.csv`, `palettes.csv`, `typography.csv`, `charts.csv`, `rules.json` and `stacks/`) to get precise, current combinations of palettes, fonts and anti-patterns recommended for the project's exact niche.

---

## 1. The "Master + Page Overrides" pattern (persistent design system)

To guarantee visual consistency and implementation speed without ambiguity:

1. **`design-system/MASTER.md` (global source of truth):**
   - **Colors & palette:** primary, secondary, background, card background, border, text (headings vs body), accents and alert states (success/warning/destructive).
   - **Typography:** primary fonts (headings) and secondary fonts (body), size scales (`text-xs` to `text-5xl`), line-heights and Google Fonts imports.
   - **Spacing and grid:** 4px/8px system, container max-widths (`max-w-7xl`, etc.), standardized gaps.
   - **Component tokens:** button variants (primary, secondary, ghost, destructive), cards, inputs, badges and chips.
   - **Shadows & elevations:** `shadow-sm`, `shadow-md`, `shadow-xl`, subtle borders (`border-border/40`).

2. **`design-system/pages/[page-name].md` (page-specific overrides):**
   - Rules that apply **only** to that screen or flow (e.g. checkout layout, a specific analytics dashboard, the login screen).

---

## 2. Layout and style patterns (inspired by UI/UX Pro Max)

When briefing the developer, the Architect defines the ideal combination of:

| Product category | Recommended visual style | Palette mood | Suggested typography | Anti-patterns to avoid |
| --- | --- | --- | --- | --- |
| **B2B SaaS & Enterprise** | Clean minimal / bento grid / modern neutral | Slate/zinc neutrals with cobalt blue or indigo accent | Inter / Plus Jakarta Sans | Aggressive neon gradients, poor contrast |
| **Fintech & Banking** | High-trust dark/light mode, data density | Dark slate / navy with emerald or gold accents | Inter / Outfit | Slow or heavy animations, generic AI purple/pink gradients |
| **Dev tools & Cloud** | Technical dark mode / dense bento | Dark monochrome with syntax highlighting | JetBrains Mono / Geist | Excessive spacing that reduces information density |
| **Health & Wellness** | Soft UI / warm minimal | Soft pastel tones (sage green, warm white, charcoal) | Cormorant Garamond / Montserrat | Vibrant neon colors, aggressive contrast |
| **E-commerce & Retail** | Hero-centric + high-contrast CTA | Clean neutrals with a high-impact conversion button | Poppins / Inter | Hiding price or CTA below the fold |

---

## 3. Mockup specification for the developer

The Architect must give developers mockups that remove guesswork, following this order of priority:

### Format 1: High-fidelity vector visual mockup (mandatory SVG)

- **Standard location:** `design-system/mockups/<page-name>-mockup.svg`
- **Standard dimensions:** `1440x900` (widescreen desktop) or `390x844` (mobile).
- **Mandatory content:** real sidebar, topbar with status, operational grid, cards with real sample data (no "Lorem Ipsum"), form states, badges and summary/closing panels.
- **Immediate visualization:** renders natively on GitHub, VS Code, Cursor and any browser.

### Format 2: Structural mockup in Markdown / ASCII (grid layout)

Useful for quick text documentation in `design-system/pages/<page-name>.md` and in the Issue body:

```text
+-----------------------------------------------------------------------------------+
| [Logo]  SaaS Platform             [Search...]      (Notifications)  [User Avatar] |
+-------------------+---------------------------------------------------------------+
| [Dashboard]       |  Key Metrics (Bento Grid, 4 Columns)                          |
| [Users]           |  +-----------+ +-----------+ +-----------+ +---------------+  |
| [Settings]        |  | MRR       | | Users     | | Churn Rate| | Latency p95   |  |
| [Integrations]    |  | $45,200   | | 1,842     | | 1.2%      | | 42ms          |  |
|                   |  +-----------+ +-----------+ +-----------+ +---------------+  |
|                   |                                                               |
|                   |  Recent Transactions Table                    [Export CSV]    |
|                   |  +---------------------------------------------------------+  |
|                   |  | ID    | Customer        | Amount    | Status   | Time   |  |
|                   |  | #1021 | Acme Corp       | $1,200    | [ Paid ] | 10:30  |  |
|                   |  | #1022 | Tech Solutions  | $3,450    | [Pend.]  | 11:15  |  |
|                   |  +---------------------------------------------------------+  |
+-------------------+---------------------------------------------------------------+
```

### Format 3: HTML prototype mockup + real PNG capture

The Architect generates a self-contained static HTML file at `docs/mockups/<page-name>.html` with the Tailwind CDN (`<script src="https://cdn.tailwindcss.com"></script>`), renders it in the built-in browser (`navigate`) and runs `screenshot` to save the real high-resolution `.png`:

```html
<!-- Example: docs/mockups/metric-card.html -->
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-slate-100 p-8">
  <div class="max-w-xs rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
    <div class="flex items-center justify-between">
      <p class="text-sm font-medium text-slate-500">Total MRR</p>
      <span class="text-xs text-slate-400">📊</span>
    </div>
    <div class="mt-2 flex items-baseline gap-2">
      <span class="text-2xl font-bold tracking-tight text-slate-900">$45,200</span>
      <span class="text-xs font-semibold text-emerald-600">+12%</span>
    </div>
  </div>
</body>
</html>
```

### Format 4: Component specification for the developer (React / Tailwind / shadcn/ui)

Along with the visual mockup, the Architect provides the React/TypeScript component spec ready for the developer to reuse without rework:

```tsx
// Example: component specification for the developer
export interface MetricCardProps {
  title: string;
  value: string;
  change: string;
  icon: React.ComponentType<{ className?: string }>;
}

export function MetricCard({ title, value, change, icon: Icon }: MetricCardProps) {
  return (
    <div className="rounded-xl border border-border/50 bg-card p-6 shadow-sm hover:shadow-md transition-all">
      <div className="flex items-center justify-between">
        <p className="text-sm font-medium text-muted-foreground">{title}</p>
        <Icon className="h-5 w-5 text-primary" />
      </div>
      <div className="mt-2 flex items-baseline gap-2">
        <span className="text-2xl font-bold tracking-tight text-foreground">{value}</span>
        <span className="text-xs font-semibold text-emerald-500">{change}</span>
      </div>
    </div>
  );
}
```

---

## 4. UI/UX pre-delivery checklist (pre-delivery gate)

The Architect includes this checklist in the technical specification for validation by `qa-analyst`:

- [ ] **Explicit user approval (HITL gate):** mockup SVG viewed and approved by the user in the chat before implementation.
- [ ] **Matching user guide:** a `docs/userguide/<page-name>.md` file created explaining the page's flow and features for end users and the product team.
- [ ] **No emojis as icons:** use an official vector library (Lucide Icons / Phosphor / Heroicons).
- [ ] **Accessibility & contrast:** minimum 4.5:1 contrast for text and badges (WCAG AA).
- [ ] **Interactive states:** explicitly define `hover`, `focus-visible`, `active`, `disabled` and `loading`.
- [ ] **Resilient layout:** text and labels must accommodate long translations and zoom without breaking the layout (`truncate` with tooltip, or workable wrapping).
- [ ] **Responsiveness:** behavior defined for 375px (mobile), 768px (tablet), 1024px (laptop) and 1440px+ (desktop).
- [ ] **Reduced motion support:** animations respect `prefers-reduced-motion`.
