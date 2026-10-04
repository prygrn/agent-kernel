# agent-kernel

**A versioned, tool-agnostic rule system for AI coding agents — built to stop agent output from drifting as a project grows.**

Invariant, cross-project rules and roles that every project inherits as a git submodule.
Project-specific rules live in a separate `agent-modules` catalogue.

---

## Why this exists

Working with coding agents, one problem shows up on every project: **the further you get, the harder it is to keep agents coherent.** Context fills with history, stale decisions, and noise; quality that was sharp at feature 1 quietly erodes by feature 8. The agent didn't get worse — its context got polluted.

This repo tries to be the answer to that decay. It treats agent guidance as a system with a single source of truth, loaded selectively, versioned, and improved in one place so every project benefits at once. The design goal throughout is **low drift**: keep the intent stable, keep the context clean, and make each agent load only what its task needs.

The principles it's built on:

- **Context entropy is the real enemy.** Agents don't tire; their context degrades. Everything here fights that.
- **Normative memory outranks narrative memory.** Specs and rules ("what must be") win over logs ("what happened"). When they conflict, the spec wins and the code is the bug.
- **Least privilege for agents.** Each role declares what it may read and write, and never does another role's job. What a tool can enforce — git hooks, branch protection — is enforced, not requested.
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

- One sentence, unambiguous, verifiable, written in English.
- No "but" / "except when": an exception is its own rule, naming the rule it restricts.
- A conditional rule states its condition first.
- Never restates what an agent already does unprompted.
- Enforced by a tool when a tool can enforce it.
- Invariant across all projects.

See `rules/always/meta.md` for the full standard applied to every rule.

## Role permissions (least privilege)

Each role's `SKILL.md` declares its access to generic resources (source code, tests,
feature contract, specs, journal, review) at three levels: **R** (read), **W** (write),
**PROPOSE** (recommend without applying). Write access to specs and contracts is
forbidden by default; the general form of that rule lives in `always/methodology.md`.

Be clear about what holds these lines:
- **Declared** — role permissions are instructions. The agent follows them; nothing
  technically stops it from overstepping.
- **Enforced** — the git hooks (commit format, quality and tests before every commit,
  no push to `main`/`master`) and the hosting platform's branch protection (only an
  approved review reaches `main`). Running agents under their own account (see below)
  is what makes that approval mean something.

## Layout

```
agent-kernel/
  README.md
  rules/
    always/             # rules — loaded by all agents, always
      meta.md           # the standard every rule must meet
      git.md
      methodology.md    # dependencies, linter, sources of truth, optional contract
      conventions.md    # code and naming conventions
      testing.md
  skills/               # skills (Agent Skills format) — one loaded at a time, on demand
    reviewer/SKILL.md
    qa/SKILL.md
    implementer/SKILL.md
    integrator/SKILL.md
    product-owner/SKILL.md
  templates/            # product spec and feature contract, used when the human wants them;
                        #   githook, the hook wrapper a consumer copies
  scripts/
    compile-agents      # builds a consumer's AGENTS.md
  hooks/                # git hooks a consumer points core.hooksPath at
  tests/                # tests of the scripts and hooks (make test)
  Makefile              # make quality (shellcheck) and make test
```

### Project rules

A consuming project keeps the rules true for it alone in its own repository, under
`rules/project/`. The kernel never holds project content.

## Requirements

The scripts and hooks are shell, so the kernel assumes a Unix-like platform.

To use the kernel in a project:
- `bash`
- `git` 2.9 or later (`core.hooksPath`)
- `make` — the hooks call `make quality` and `make test`, a stable entry point that
  works whatever the project's stack; each project wires its own tools behind them
- `sed`, `grep`, `awk`, `cmp` (POSIX)

To work on the kernel itself, add:
- `bash` 4.4 or later and GNU `date` (tests)
- `git` 2.28 or later (tests)
- `shellcheck` (`make quality`)

## Getting started

### Install

Wire the kernel in a single commit: the hooks check the working tree, so one commit
avoids ordering traps between the steps.

1. Add the kernel as a submodule: `git submodule add <kernel-repo-url> .agents`.
2. Copy the modules the project needs from `agent-modules` into `rules/project/` — every
   language the project uses, not only the main one.
3. Provide `make quality` (the project's linters, plus
   `.agents/scripts/compile-agents --check` so a stale `AGENTS.md` fails) and `make test`.
4. Run `.agents/scripts/compile-agents` to write `AGENTS.md`. Commit it, and exclude it
   from formatters like any generated file: its output is stable under prettier's
   defaults, but options such as `proseWrap: always` would still rewrite it.
5. Install the hooks through tracked wrappers:

   ```bash
   mkdir -p .githooks
   for hook in commit-msg pre-push; do cp .agents/templates/githook ".githooks/$hook"; done
   git config core.hooksPath .githooks   # once per clone
   ```

   `core.hooksPath` is shared by every worktree of a clone. The wrappers make each
   worktree run the hooks of its own `.agents` checkout, and block loudly when that
   checkout has none instead of silently skipping them. `core.hooksPath` then never
   changes when the kernel is upgraded.

A project rule overrides a kernel rule only when it names it as an exception, opening
with `As an exception to the kernel rule "<rule quoted word for word>"` (`rules/always/meta.md`).
`AGENTS.md` states it for the agent, and `compile-agents` fails when a quoted rule no
longer exists, so a kernel upgrade that rewords a rule cannot leave an exception dangling.

### Upgrade

Upgrade by tag (see Versions) and read the tag message first: it lists what changes for
consumers.

```bash
git -C .agents fetch --tags
git -C .agents checkout vX.Y.Z
# apply the consumer steps listed in the tag message
.agents/scripts/compile-agents
git add .agents AGENTS.md          # plus any file those steps created, e.g. .githooks/
git commit -m "chore(agents): update agent-kernel to vX.Y.Z"
```

A project installed with v0.2.0 still points `core.hooksPath` at `.agents/hooks`:
upgrading past it means installing the hook wrappers (Install, step 5).

After the upgrade reaches them, other worktrees run `git submodule update`.

### How work flows

One flow for every feature:

1. **Task** — the human states what the change must do. The agent asks whether the
   feature needs a feature contract (`templates/feature-contract.md`); the human decides.
   A product can also have a product spec (`templates/product-spec.md`), drafted with
   the Product Owner role in a session without code access.
2. **Tests first** — the implementer commits failing tests in a `test` commit, then the
   code that makes them pass in a `feat` or `fix` commit.
3. **Review** — the reviewer reads the tests before the code, against the contract when
   one exists, otherwise against the task description and the tests.
4. **QA** — verifies each expected behavior in real conditions; a behavior no test covers
   is a finding, even when everything is green.
5. **Integration** — when work ran in parallel, the integrator reconciles it before merge.
6. **Merge** — the agent opens the review; only the human merges.

Behind it:
- Sources of truth are ranked: spec above code. When they disagree, the code is the bug.
- Undecided product or architecture questions are flagged, never settled by an agent.
- Reviewer and QA report; they never fix.

### Agents under their own account

Give agents their own account on the code hosting platform — a machine account added as
a collaborator with write access — and its own token, set only in the agents'
environment, never in a committed file. Set the git author and committer to that account
too. Reviews the agent opens can then be approved by the human (platforms forbid
approving your own), and history shows who wrote what.

### Personal preferences

Preferences that follow a person rather than a project, such as the language to talk
in, belong in neither the kernel nor the project. Keep them in one personal file (for
example `~/.agents/personal.md`) and point each tool's user-level instructions at it;
switching tools then means moving a pointer. Rules about what goes into the repository,
such as the language of comments and documentation, are project rules, in
`rules/project/`.

### Versions

A consumer pins the kernel through its submodule commit. A change meant to reach
consumers gets an annotated tag (`vX.Y.Z`) whose message says what changes for them;
consumers update deliberately, by tag.

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
