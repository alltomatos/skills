# Guia de Especificação de UI/UX, Design Tokens e Mockups para Engenharia

Este documento serve como referência para o **Arquiteto de Software e Soluções** ao definir a camada de apresentação, arquitetura de design tokens e mockups funcionais para os desenvolvedores (`/developer`).

> 💡 **Consulta ao Repositório UI/UX Pro Max:**
> O Arquiteto pode e deve consultar a base de inteligência de design em **[nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)** (arquivos de dados em `src/ui-ux-pro-max/data/` como `styles.csv`, `palettes.csv`, `typography.csv`, `charts.csv`, `rules.json` e `stacks/`) para obter combinações precisas e atualizadas de paletas, fontes e anti-patterns recomendados para o nicho exato do projeto.

---

## 1. O Padrão "Master + Page Overrides" (Design System Persistente)

Para garantir consistência visual e velocidade de implementação sem ambiguidade:

1. **`design-system/MASTER.md` (Fonte da Verdade Global):**
   - **Cores & Paleta:** Primária, Secundária, Background, Card Background, Borda, Textos (Headings vs Body), Acentos e Estados de Alerta (Success/Warning/Destructive).
   - **Tipografia:** Fontes primárias (Headings) e secundárias (Body), escalas de tamanho (`text-xs` a `text-5xl`), line-heights e Google Fonts imports.
   - **Espaçamento e Grid:** Sistema de 4px/8px, container max-widths (`max-w-7xl`, etc.), gaps padronizados.
   - **Tokens de Componentes:** Variantes de botões (Primary, Secondary, Ghost, Destructive), Cards, Inputs, Badges e Chips.
   - **Sombras & Elevações:** `shadow-sm`, `shadow-md`, `shadow-xl`, bordas sutis (`border-border/40`).

2. **`design-system/pages/[page-name].md` (Overrides Específicos por Página):**
   - Regras que se aplicam **apenas** àquela tela ou fluxo (ex: layout de checkout, dashboard analítico específico, tela de login).

---

## 2. Padrões de Layout e Estilo (Inspirados no UI/UX Pro Max)

Ao orientar o desenvolvedor, o Arquiteto define a combinação ideal de:

| Categoria do Produto | Estilo Visual Recomendado | Humor da Paleta | Tipografia Sugerida | Anti-Patterns a Evitar |
| --- | --- | --- | --- | --- | --- |
| **SaaS B2B & Enterprise** | Clean Minimal / Bento Grid / Modern Neutral | Neutros slate/zinc com acento azul cobalto ou índigo | Inter / Plus Jakarta Sans | Gradientes neon agressivos, falta de contraste |
| **Fintech & Banking** | High-Trust Dark/Light Mode, Data Density | Slate escuro / Navy com acentos em Emerald ou Gold | Inter / Outfit | Animações lentas/pesadas, gradientes roxo/rosa "genéricos de IA" |
| **Dev Tools & Cloud** | Technical Dark Mode / Dense Bento | Monocromático escuro com sintaxe highlighting | JetBrains Mono / Geist | Espaçamentos excessivos que reduzem densidade de informação |
| **Health & Wellness** | Soft UI / Warm Minimal | Tons pastéis suaves (Sage Green, Warm White, Charcoal) | Cormorant Garamond / Montserrat | Cores vibrantes neon, contrastes agressivos |
| **E-Commerce & Retail** | Hero-Centric + High Contrast CTA | Neutros limpos com botão de conversão de alto impacto | Poppins / Inter | Esconder preço ou CTA abaixo da dobra |

---

## 3. Especificação de Mockups para o Desenvolvedor

O Arquiteto deve fornecer aos desenvolvedores mockups que eliminem adivinhações, seguindo a ordem de prioridade:

### Formato 1: Mockup Visual Vetorial de Alta Fidelidade (SVG Obrigatório)
- **Local Padrão:** `design-system/mockups/<page-name>-mockup.svg`
- **Dimensões Padrão:** `1440x900` (Widescreen Desktop) ou `390x844` (Mobile).
- **Conteúdo Obrigatório:** Sidebar real, Topbar com status, grid operacional, cards com dados de exemplo reais (sem "Lorem Ipsum"), estados de formulários, badges e painéis de fechamento/resumo.
- **Visualização Imediata:** Renderizável nativamente no GitHub, VS Code, Cursor e qualquer navegador.

### Formato 2: Mockup Estrutural em Markdown / ASCII (Layout de Grid)
Útil para documentação textual rápida em `design-system/pages/<page-name>.md` e no corpo da Issue:

```text
+-----------------------------------------------------------------------------------+
| [Logo]  Plataforma SaaS           [Busca...]      (Notificações)  [Avatar Usuário]|
+-------------------+---------------------------------------------------------------+
| [Dashboard]       |  Métricas Principais (Bento Grid 4 Colunas)                   |
| [Usuários]        |  +-----------+ +-----------+ +-----------+ +---------------+  |
| [Configurações]   |  | MRR       | | Usuários  | | Churn Rate| | Latência p95  |  |
| [Integrações]     |  | R$ 45.200 | | 1.842     | | 1.2%      | | 42ms          |  |
|                   |  +-----------+ +-----------+ +-----------+ +---------------+  |
|                   |                                                               |
|                   |  Tabela de Transações Recentes               [Exportar CSV]   |
|                   |  +---------------------------------------------------------+  |
|                   |  | ID    | Cliente         | Valor     | Status   | Data   |  |
|                   |  | #1021 | Acme Corp       | R$ 1.200  | [ Pago ] | 10:30  |  |
|                   |  | #1022 | Tech Solutions  | R$ 3.450  | [Pend.]  | 11:15  |  |
|                   |  +---------------------------------------------------------+  |
+-------------------+---------------------------------------------------------------+
```

### Formato 3: Mockup Protótipo HTML + Captura PNG Real
O Arquiteto gera um arquivo HTML estático e autocontido em `docs/mockups/<page-name>.html` com Tailwind CDN (`<script src="https://cdn.tailwindcss.com"></script>`), renderiza no navegador embutido via ferramenta `browser` (ação `navigate`) e executa a ação `screenshot` para salvar o `.png` real de alta resolução:

```html
<!-- Exemplo: docs/mockups/metric-card.html -->
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-slate-100 p-8">
  <div class="max-w-xs rounded-xl border border-slate-200 bg-white p-6 shadow-sm">
    <div class="flex items-center justify-between">
      <p class="text-sm font-medium text-slate-500">MRR Total</p>
      <span class="text-xs text-slate-400">📊</span>
    </div>
    <div class="mt-2 flex items-baseline gap-2">
      <span class="text-2xl font-bold tracking-tight text-slate-900">R$ 45.200</span>
      <span class="text-xs font-semibold text-emerald-600">+12%</span>
    </div>
  </div>
</body>
</html>
```

### Formato 4: Especificação de Componentes para o Desenvolvedor (React / Tailwind / shadcn/ui)
Junto com o mockup visual, o Arquiteto fornece a especificação do componente em React/TypeScript pronta para o desenvolvedor reutilizar sem retrabalho:

```tsx
// Exemplo: Especificação de Componente para o Desenvolvedor
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

## 4. Checklist Pré-Entrega de UI/UX (Pre-Delivery Gate)

O Arquiteto inclui este checklist na especificação técnica para validação no `/qa-analyst`:

- [ ] **Aprovação Explícita do Usuário (HITL Gate):** Mockup SVG visualizado e aprovado pelo usuário no chat antes da implementação.
- [ ] **Sem Emojis como Ícones:** Usar biblioteca vetorial oficial (Lucide Icons / Phosphor / Heroicons).
- [ ] **Acessibilidade & Contraste:** Mínimo de 4.5:1 de contraste para textos e badges (WCAG AA).
- [ ] **Estados Interativos:** Definir explicitamente estados `hover`, `focus-visible`, `active`, `disabled` e `loading`.
- [ ] **Layout Resiliente:** Textos e labels devem acomodar traduções longas e zoom sem quebrar layout (`truncate` com tooltip ou wrapping operável).
- [ ] **Responsividade:** Comportamento definido para 375px (mobile), 768px (tablet), 1024px (laptop) e 1440px+ (desktop).
- [ ] **Suporte a Reduced Motion:** Animações respeitam `prefers-reduced-motion`.
