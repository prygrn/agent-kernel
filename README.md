# agent-kernel

Invariant, cross-project rules and roles for AI coding agents.
Consumed as a git submodule; project-specific rules live in `agent-modules`.

## What this is

The canonical, always-true rule set that every one of my projects inherits.
Something belongs here only if it holds for **all** projects and stacks. Anything
tied to a language, platform, or art direction lives in `agent-modules`, not here.

Single source of truth for agent behavior. Versioned. Improving something here
improves it everywhere on the next pull.

## Two kinds of content (do not confuse them)

The kernel holds two natures of file, loaded differently:

- **Rules (`rules/always/`)** — background invariants (git, methodology, cross-cutting
  conventions). Loaded by **every** agent, **at all times**, regardless of the task.
  These are NOT skills: an invariant is not conditional. Plain neutral Markdown.

- **Roles (`rules/roles/`)** — encapsulated know-how (reviewer, QA, implementer). **One**
  is loaded at a time, activated by the role assigned to the agent. These follow the
  **Agent Skills** open format (https://agentskills.io): a folder with a `SKILL.md`.
  Progressive disclosure means only name+description sit in context until a task matches,
  keeping the footprint small.

A role declares its dependency on the `always/` rules it needs — it never duplicates them.

## What a rule is

- One sentence.
- Unambiguous and verifiable.
- No "but" / "except when" (that means it's two rules).
- Written in English.
- Invariant across all projects.

See `rules/always/meta.md` for the full standard applied to every rule.

## Role permissions (least privilege)

Each role's `SKILL.md` declares its access to generic resources (source code, tests,
feature contract, specs, journal, PR/diff) at three levels: **R** (read), **W** (write),
**PROPOSE** (recommend without applying). A capability that is absent cannot overflow —
isolation is wired, not requested. Write access to specs/contract is forbidden by default;
the general form of that rule lives in `always/methodology.md`.

## Layout

```
agent-kernel/
  README.md
  rules/
    always/             # rules — loaded by all agents, always
      meta.md           # the standard every rule must meet
      git.md
      methodology.md    # feature contract, review vs contract, semantic integration,
                        #   normative hierarchy, "write-specs forbidden by default"
      conventions.md    # cross-cutting conventions (money in cents, null handling, auth…)
    roles/              # skills (Agent Skills format) — one loaded at a time, on demand
      reviewer/SKILL.md
      qa/SKILL.md
      implementer/SKILL.md
```

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

## Tool agnosticity

No tool name lives in this repo. Each consuming project adds one **slim** exposure file
per tool, redirecting to the kernel — nothing important depends on any tool:

```
Read all rules under .agents/kernel/rules/ before acting.
```

Put that line in `CLAUDE.md`, `.cursor/rules`, or whatever your agent reads. Leaving a
tool means deleting a three-line file. Rules are kept as plain `.md` (no proprietary
frontmatter); skills target the portable core of the Agent Skills format.

## Skills, rules, and MCP — where things go

- **Skill** (know-how / procedure / role): Agent Skills format. Invariant → kernel.
  Techno- or platform-specific → `agent-modules`.
- **Rule** (background invariant): neutral Markdown, not a skill. Kernel or module by scope.
- **MCP** (service connection, credentials): neither kernel nor module. Project config,
  **secrets never committed**. A skill that needs an MCP declares the dependency; the
  project supplies it.

Sorting test, in order: contains a secret / service connection? → project config, out of git.
Otherwise, true for all projects? → kernel. Otherwise → module.

## Relationship to agent-modules

| | agent-kernel | agent-modules |
|---|---|---|
| Scope | invariant, all projects | opt-in per project |
| Content | rules, roles/skills, cross-cutting conventions | language / platform / art-direction |
| Consumed as | git submodule | copy-paste |
| Changes | propagate to all projects | isolated per project |

## Principle

Content is added by **sedimentation, not anticipation**: something enters the kernel only
after it has proven itself on shipped code and shown it holds across projects.
