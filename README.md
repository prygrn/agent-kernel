# agent-kernel

**A versioned, tool-agnostic rule system for AI coding agents — built to stop agent output from drifting as a project grows.**

Invariant, cross-project rules and roles that every project inherits as a git submodule.
Project-specific rules live in a separate `agent-modules` catalogue.

---

## Why this exists

Working with coding agents, one problem shows up on every project: **the further you get, the harder it is to keep agents coherent.** Context fills with history, stale decisions, and noise; quality that was sharp at feature 1 quietly erodes by feature 8. The agent didn't get worse — its context got polluted.

This repo try to be the answer to that decay. It treats agent guidance as a system with a single source of truth, loaded selectively, versioned, and improved in one place so every project benefits at once. The design goal throughout is **low drift**: keep the intent stable, keep the context clean, and make each agent load only what its task needs.

The principles it's built on:

- **Context entropy is the real enemy.** Agents don't tire; their context degrades. Everything here fights that.
- **Normative memory outranks narrative memory.** Specs and rules ("what must be") win over logs ("what happened"). When they conflict, the spec wins and the code is the bug.
- **Least privilege for agents.** A role can't overflow into work it has no capability for. Isolation is wired, not politely requested.
- **Sedimentation, not anticipation.** A rule enters only after it has proven itself on shipped code across projects — never speculatively.

---

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

- **Roles (`skills/`)** — encapsulated know-how (reviewer, QA, implementer, integrator). **One**
  is loaded at a time, activated by the role assigned to the agent. These follow the
  **Agent Skills** open format (<https://agentskills.io>): a folder with a `SKILL.md`,
  at the repo root as the spec requires. Progressive disclosure means only name+description
  sit in context until a task matches, keeping the footprint small.

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
      testing.md
  skills/               # skills (Agent Skills format) — one loaded at a time, on demand
    reviewer/SKILL.md
    qa/SKILL.md
    implementer/SKILL.md
    integrator/SKILL.md
    product-owner/SKILL.md
  templates/            # product spec and feature contract, used when the human wants them
  scripts/
    compile-agents      # builds a consumer's AGENTS.md
  hooks/                # git hooks a consumer points core.hooksPath at
  tests/                # tests of the scripts and hooks (make test)
  Makefile              # make quality (shellcheck) and make test
```

### Project rules

A consuming project keeps the rules true for it alone in its own repository, under
`rules/project/`. The kernel never holds project content.

## Using it in a project

Add the kernel as a submodule and wire it:

```bash
git submodule add <kernel-repo-url> .agents
.agents/scripts/compile-agents            # writes AGENTS.md from .agents/rules/always/ + rules/project/
git config core.hooksPath .agents/hooks   # once per clone: commit format, quality, tests, no push to main/master
```

The hooks call two make targets the project provides: `make quality` (its linters, plus
`.agents/scripts/compile-agents --check` so a stale `AGENTS.md` fails) and `make test`.
Commit `AGENTS.md`; re-run the script whenever a rule changes.

Pull the latest kernel improvements into a project:

```bash
git submodule update --remote .agents
.agents/scripts/compile-agents
git commit -am "chore(agents): update agent-kernel"
```

## Tool agnosticity

No tool name lives in the kernel's rules or skills. `AGENTS.md` holds every rule inline
and is read natively by most coding agents; for a tool that reads another file, make
that file point to it (for example a `CLAUDE.md` containing `@AGENTS.md`). Leaving a
tool means deleting that pointer. Rules are plain `.md`; skills target the portable core
of the Agent Skills format and load on demand from `.agents/skills/`.

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

|             | agent-kernel                                   | agent-modules                       |
| ----------- | ---------------------------------------------- | ----------------------------------- |
| Scope       | invariant, all projects                        | opt-in per project                  |
| Content     | rules, roles/skills, cross-cutting conventions | language / platform / art-direction |
| Consumed as | git submodule                                  | copy-paste                          |
| Changes     | propagate to all projects                      | isolated per project                |

## Principle

Content is added by **sedimentation, not anticipation**: something enters the kernel only
after it has proven itself on shipped code and shown it holds across projects.
