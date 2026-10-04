Push only to the development branch you are working on.
Only the human merges a development branch into the main branch.
An agent may merge the main branch into its own development branch.
An agent opens a review when its development starts.
The review description states the development task and its solution.
Format commit messages as <type>(<scope>): <description>, where the scope names the affected area.
Use one of these commit types: feat, fix, test, refactor, chore, docs.
Write the commit description in imperative mood, in English, with no trailing period.
Start the commit description with a lowercase letter.
Do not add a commit body or footer.
As an exception to the kernel rule "Do not add a commit body or footer.", a breaking change carries a BREAKING CHANGE footer.
Do not squash commits.
Keep secrets, dependency directories, and build output out of version control.
Develop each feature in a worktree separate from the main branch.
As an exception to the kernel rule "Develop each feature in a worktree separate from the main branch.", an explicit user instruction may let an agent work outside a worktree.
Stop and flag before committing when a hardcoded secret is found in the code.
Run the linter and the test suite before every commit.
Do not commit while the linter reports an issue.
Never bypass a git hook.
