Never push; pushing is the human developer's responsibility.
Never merge; merging is the human developer's responsibility.
Format commit messages as <type>(<scope>): <description>.
Use one of these commit types: feat, fix, test, refactor, chore, docs.
Include a scope in every commit message identifying the affected area.
Write the commit description in imperative mood, lowercase, as a single line, in English, with no trailing period.
Do not add a commit body or footer.
A breaking change may include a footer.
Do not squash commits.
Ensure .gitignore excludes .env files, dependency directories, and build output directories.
Develop each feature in a worktree separate from the main branch.
An explicit user instruction may override the worktree requirement.
Stop and flag before committing if a hardcoded secret is found in the code.
Commit separately after each TDD step: writing the test, implementing the code, and refactoring.
Run the linter before every commit.
Run the automated test suite before every commit.
