# Journal — template

The journal is the chronology of non-trivial decisions in full methodology. It lives at
`docs/journal.md`. It records what was decided and why; it does not define what must be.
When it conflicts with the product spec or a feature contract, those win.

Append only. Never rewrite a past entry: a reversed decision gets a new entry that names
the one it replaces.

---

## Entry format

### YYYY-MM-DD — <decision in one line>
- **Context**: the situation that forced a choice.
- **Decision**: what was chosen.
- **Why**: the reason, including the alternatives rejected.
- **Decided by**: the human, or the role that proposed it and the human who validated it.
- **Replaces**: the earlier entry this one reverses, if any.
