Never install a new package or library without explicit user approval.
Check for an existing package or library that already provides the needed capability before proposing a new one.
Prefer stable released versions over pre-release versions when adding a dependency.
Configure a linter for every repository.
Fix simple linter issues automatically.
Warn the user when a linter issue cannot be fixed simply.
When uncertain how a rule applies, stop and ask before proceeding.
Rank sources of truth in this order: product specs, technical specs, mockups, documents, code.
Do not modify a higher-ranked source of truth to accommodate a lower-ranked one.
When sources of truth conflict, ask the user to decide.
Flag any undecided product or architecture question instead of deciding it.
Verify external contracts against their real source, not from memory.
Keep the product spec at docs/product-spec.md, the journal at docs/journal.md, and each feature contract at docs/contracts/<feature>.md.
When a product spec or a journal exists, read the product spec, then the journal, before acting.
When a journal exists, log every non-trivial decision in it.
Before starting a feature, ask the human whether it needs a feature contract.
When a feature contract exists, it is the reference for implementation, review, and QA.
When no feature contract exists, the tests and the task description in the review are the reference.
Product decisions and implementation happen in separate sessions.
