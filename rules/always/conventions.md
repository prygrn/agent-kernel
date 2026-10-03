Validate all input at system boundaries.
Write the simplest code that satisfies the requirement.
Optimize only code that profiling identifies as a bottleneck.
Reuse existing code instead of duplicating it.
Extract logic shared by several places into a single implementation.
Give each file a single responsibility, stated by its name.
When an invalid state or input is detected, stop with an explicit error instead of continuing.
Do not use boolean flag parameters to change a function's behavior.
Include enough context in error messages to debug from them.
When code logs an error, attach an error code to it.
Write a comment only when it conveys non-obvious rationale the code can't express on its own; keep it concise.
Write code, identifiers, tests, and log messages in English.
Use consistent terminology for the same concept throughout the codebase.
Do not abbreviate identifiers.
As an exception to the no-abbreviation rule, loop counters may be single letters.
