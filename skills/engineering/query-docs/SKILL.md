---
name: query-docs
description: Resolves library documentation and fetches authoritative code snippets using Context7. Ensures correct API usage and prevents code hallucination when integrating third-party frameworks. Use when interacting with external libraries (Redis, Next.js, shadcn, database SDKs) or resolving build errors caused by library API changes.
---

# query-docs

Evitar alucinações de API e assinaturas obsoletas em dependências externas (Next.js, Tailwind, Prisma, Upstash). 

## FLUXO COM MCP CONTEXT7

1. **Resolva ID (Resolve ID)**:
   Procurar `libraryId` correto via `mcp_context7_resolve_library_id`.
   ```typescript
   mcp_context7_resolve_library_id({ libraryName: "Prisma", query: "..." })
   ```
2. **Consulte Docs (Query Docs)**:
   Rodar busca com ID encontrado via `mcp_context7_query_docs`.
   ```typescript
   mcp_context7_query_docs({ libraryId: "/prisma/prisma", query: "Como criar transação..." })
   ```
3. **Mapeamento local**:
   Salvar dependências em `.claude/context7.json` na raiz:
   ```json
   {
     "dependencies": {
       "redis": "/upstash/redis",
       "prisma": "/prisma/prisma"
     }
   }
   ```

## FALLBACK LOCAL (OFFLINE / BLOCKED MODE)
Context7 indisponível (HTTP 429, rede caída, sem internet) -> NÃO ABORTE FLUXO. 
1. Buscar arquivo de tipagem local (`*.d.ts`, interfaces Go, declaration files) dentro de `node_modules/` ou vendor local.
2. Inspecionar assinaturas diretamente do tipo para extrair parâmetros, tipos e métodos corretos e compatíveis com a versão instalada.

## INTEGRAÇÃO SKILLS
* **`/scaffold-mvp`**: Gerar manifesto `.claude/context7.json` base com ids da stack ativa.
* **`/tdd` e `/diagnose`**: Erro compilação/tipagem -> rodar `/query-docs` antes de tentar correção ad-hoc.
* **`/setup-skills`**: Criar diretório `.claude/` e manifesto `context7.json` vazio se ausente.
