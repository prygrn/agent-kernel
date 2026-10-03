Never install a new package or library without explicit user approval.
Check for an existing package or library that already provides the needed capability before proposing a new one.
Prefer stable released versions over pre-release versions when adding a dependency.
Configure a linter for every repository.
Fix simple linter issues automatically.
Warn the user when a linter issue cannot be fixed simply.
When uncertain how a rule applies, stop and ask before proceeding.
Rank sources of truth in this order: product specs, technical specs, mockups, documents, code.
In light methodology, rank the feature's tests above code as a source of truth.
Do not modify a higher-ranked source of truth to accommodate a lower-ranked one.
When sources of truth conflict, ask the user to decide.
Flag any undecided product or architecture question instead of deciding it.
Verify external contracts against their real source, not from memory.
Each project and each feature runs in either full or light methodology.
Only the human chooses the methodology of a project or a feature.
Keep the product spec at docs/product-spec.md, the journal at docs/journal.md, and each feature contract at docs/contracts/<feature>.md.
When docs/product-spec.md exists, the project runs in full methodology.
When the project rules declare light methodology, the project runs in light methodology.
When docs/contracts/<feature>.md exists, the feature runs in full methodology.
When the feature's review description contains the line "Mode: light", the feature runs in light methodology.
When the current project or feature has no recorded methodology, ask the human to choose one before starting.
When a product spec or a journal exists, read the product spec, then the journal, before acting.
In full methodology, the feature contract is the reference for implementation, review, QA, and integration.
In full methodology, log every non-trivial decision in the journal.
In full methodology, product decisions and implementation happen in separate sessions.
In light methodology, the feature's tests are its contract.
In light methodology, the task description in the review, validated by the human, is the reference for what the tests must cover.
In light methodology, log every non-trivial decision in the review description.
