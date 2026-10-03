# Review description — template

Every review (pull request, merge request) states the task and its solution. In light
methodology it also carries the mode line and the task description that tests are judged
against, so no extra document is needed.

---

```
Mode: light            <- light methodology only; omit in full methodology

## Task
What the change must do, as observable behavior. In light methodology this is the
reference for what the tests must cover, once the human has validated it.
In full methodology, link the feature contract instead: docs/contracts/<feature>.md

## Solution
How the change does it, in a few lines.

## Decisions
Light methodology only: the non-trivial decisions taken during the work, and why.
In full methodology they go to docs/journal.md.
```
