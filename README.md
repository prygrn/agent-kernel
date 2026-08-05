# agent-kernel

Invariant, cross-project rules for AI coding agents.
Consumed as a git submodule; project-specific rules live in `agent-modules`.

## What this is

The canonical, always-true rule set that every one of my projects inherits.
A rule belongs here only if it holds for **all** projects and stacks. Anything
tied to a language, platform, or art direction lives in `agent-modules`, not here.

Single source of truth for agent behavior. Versioned. Improving a rule here
improves it everywhere on the next pull.

## What a rule is

- One sentence.
- Unambiguous and verifiable.
- No "but" / "except when" (that means it's two rules).
- Written in English.
- Invariant across all projects.

See `rules/meta.md` for the full standard applied to every rule.

## Using it in a project

Add the kernel as a submodule:

```bash
git submodule add <kernel-repo-url> .agents/kernel
git commit -m "add agent-kernel submodule"
```

Pull the latest kernel improvements into a project:

```bash
git submodule update --remote .agents/kernel
git commit -m "update agent-kernel"
```

Point your agent config (e.g. CLAUDE.md / .cursor/rules) at the files under
`.agents/kernel/`.

## Relationship to agent-modules

| | agent-kernel | agent-modules |
|---|---|---|
| Scope | invariant, all projects | opt-in per project |
| Content | roles, methodology, cross-cutting conventions | language / platform / art-direction rules |
| Consumed as | git submodule | copy-paste |
| Changes | propagate to all projects | isolated per project |

## Layout

```
rules/
  meta.md        # the standard every rule must meet
  ...            # the invariant rules themselves
README.md
```

## Principle

Rules are added by sedimentation, not anticipation: a rule enters the kernel only
after it has proven itself on shipped code and shown it holds across projects.
