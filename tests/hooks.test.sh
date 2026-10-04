#!/usr/bin/env bash
# Tests hooks/commit-msg and hooks/pre-push against throwaway repositories.
set -euo pipefail

KERNEL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
readonly KERNEL_DIR
# shellcheck source=SCRIPTDIR/lib.sh
source "$(dirname "$0")/lib.sh"

# A repository using the kernel hooks, whose make targets exit with
# $QUALITY_STATUS and $TEST_STATUS (0 when unset).
new_repository() {
  local repository_dir
  repository_dir="$(new_temp_dir)"
  git -C "$repository_dir" init -q -b feature
  git -C "$repository_dir" config user.email test@example.com
  git -C "$repository_dir" config user.name test
  git -C "$repository_dir" config core.hooksPath "$KERNEL_DIR/hooks"
  cat >"$repository_dir/Makefile" <<'MAKEFILE'
quality: ; @exit $${QUALITY_STATUS:-0}
test: ; @exit $${TEST_STATUS:-0}
MAKEFILE
  echo "$repository_dir"
}

# commit_in [VARIABLE=value...] <repository> <git commit arguments...>
# Stages a fresh change, then commits it with the given environment.
commit_in() {
  local assignments=()
  while [[ "$1" == *=* ]]; do
    assignments+=("$1")
    shift
  done
  local repository_dir="$1"
  shift
  date +%s%N >>"$repository_dir/change"
  git -C "$repository_dir" add -A
  env "${assignments[@]}" git -C "$repository_dir" commit -q "$@"
}

repository="$(new_repository)"

expect success "commit-msg accepts a well-formed message" \
  commit_in "$repository" -m "feat(core): add receipt total"

expect failure "commit-msg rejects a message without scope" \
  commit_in "$repository" -m "feat: add receipt total"
expect failure "commit-msg rejects an unknown type" \
  commit_in "$repository" -m "feature(core): add receipt total"
expect failure "commit-msg rejects an uppercase description" \
  commit_in "$repository" -m "feat(core): Add receipt total"
expect success "commit-msg accepts uppercase acronyms after a lowercase start" \
  commit_in "$repository" -m "feat(core): update AGENTS.md and the CI badge"
expect failure "commit-msg rejects a trailing period" \
  commit_in "$repository" -m "feat(core): add receipt total."
expect failure "commit-msg rejects a body" \
  commit_in "$repository" -m "feat(core): add receipt total" -m "Explains the change."
expect failure "commit-msg rejects a body next to a breaking change footer" \
  commit_in "$repository" -m "feat(core): add receipt total" -m "Explains the change." -m "BREAKING CHANGE: total is now in cents"
expect success "commit-msg accepts a breaking change footer" \
  commit_in "$repository" -m "feat(core): add receipt total" -m "BREAKING CHANGE: total is now in cents"

expect failure "commit-msg blocks the commit when make quality fails" \
  commit_in QUALITY_STATUS=1 "$repository" -m "feat(core): add receipt date"
expect failure "commit-msg blocks a feat commit when make test fails" \
  commit_in TEST_STATUS=1 "$repository" -m "feat(core): add receipt date"
expect success "commit-msg tolerates failing tests in a test commit" \
  commit_in TEST_STATUS=1 "$repository" -m "test(core): cover receipt date"

repository_without_targets="$(new_repository)"
rm "$repository_without_targets/Makefile"
expect failure "commit-msg blocks the commit when the project has no make targets" \
  commit_in "$repository_without_targets" -m "feat(core): add receipt total"

remote="$(new_temp_dir)"
git init -q --bare "$remote"
git -C "$repository" remote add origin "$remote"
expect success "pre-push accepts a push to a development branch" \
  git -C "$repository" push -q origin feature
expect failure "pre-push refuses a push to main" \
  git -C "$repository" push -q origin feature:main
expect failure "pre-push refuses a push to master" \
  git -C "$repository" push -q origin feature:master
git -C "$repository" tag v1
expect success "pre-push accepts a tag push" \
  git -C "$repository" push -q origin v1

finish
