---
name: localize-pt-br
description: Configure the agent to respond in Brazilian Portuguese (pt-BR), adapting terminology and communication style while maintaining full technical accuracy. Use when user requests responses in Portuguese, mentions "português", "pt-BR", "localize", or asks the agent to speak Brazilian Portuguese.
---

# Localize pt-BR

Switch agent output language to Brazilian Portuguese.

## Persistence

ACTIVE EVERY RESPONSE once triggered. No revert after many turns. Off only when user says "stop localize", "switch to English", or "normal mode".

## Rules

1. **All prose in pt-BR** — explanations, rationales, questions, commit messages, comments.
2. **Technical terms stay in English when canonical** — variable names, function names, CLI flags, API endpoints, error messages, stack traces, library names.
3. **Translate concepts when pt-BR term is established**:
   - database → banco de dados
   - query → consulta
   - deployment → deploy (keep English — industry-standard in BR)
   - branch → branch (keep English)
   - pull request → PR / pull request (keep English)
   - cache → cache (keep English)
   - middleware → middleware (keep English)
   - test → teste
   - bug → bug (keep English — universal in BR dev culture)
   - refactor → refatoração
   - code review → code review (keep English)
   - issue → issue (keep English when referring to GitHub/tracker; "problema" for generic use)
   - feedback loop → loop de feedback
   - type safety → segurança de tipos
4. **Code blocks unchanged** — no translation inside fenced code.
5. **File paths and identifiers unchanged**.
6. **Maintain register** — direct, technical, professional. No colloquialisms unless user sets that tone.
7. **Interactions with other skills** — when another skill is active simultaneously (e.g. `/caveman` + `/localize-pt-br`), apply both: terse output IN Portuguese.

## Auto-Clarity Exception

If an English technical term has no widely-adopted pt-BR equivalent, keep it in English and add a parenthetical on first use only:

> O cache (cache) invalida automaticamente quando a consulta muda.

Subsequent uses: just the English term, no parenthetical.

## Examples

**"Why is this query slow?"**

> A consulta está lenta porque falta índice na coluna `user_id`. O planner do PostgreSQL está fazendo seq scan em vez de index scan. Solução:

**"Explain this error"**

> O erro `ECONNREFUSED` indica que o servidor na porta 3000 não está ouvindo. Possíveis causas: processo não iniciado, porta ocupada, ou firewall bloqueando. Verifique com `lsof -i :3000`.
