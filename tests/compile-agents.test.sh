#!/usr/bin/env bash
# Tests scripts/compile-agents from throwaway consumer projects.
set -euo pipefail

KERNEL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
readonly KERNEL_DIR
# shellcheck source=SCRIPTDIR/lib.sh
source "$(dirname "$0")/lib.sh"

# A consumer project with the kernel at .agents, as a submodule would place it.
new_project() {
  local project_dir
  project_dir="$(new_temp_dir)"
  ln -s "$KERNEL_DIR" "$project_dir/.agents"
  echo "$project_dir"
}

compile_in() {
  local project_dir="$1"
  shift
  (cd "$project_dir" && .agents/scripts/compile-agents "$@")
}

agents_file_contains() {
  grep -qF -- "$2" "$1/AGENTS.md"
}

has_single_top_heading() {
  [[ "$(grep -c '^# ' "$1/AGENTS.md")" -eq 1 ]]
}

has_blank_line_after_header_comment() {
  [[ -z "$(sed -n 2p "$1/AGENTS.md")" ]]
}

has_no_consecutive_blank_lines() {
  ! awk 'previous_blank && /^$/ { found = 1 } { previous_blank = /^$/ } END { exit !found }' "$1/AGENTS.md"
}

project="$(new_project)"
mkdir -p "$project/rules/project"
printf '\nEach feature lives in its own crate.\n\n\n' >"$project/rules/project/architecture.md"

expect success "compile-agents writes AGENTS.md" \
  compile_in "$project"
expect success "AGENTS.md holds the kernel rules" \
  agents_file_contains "$project" "$(head -n 1 "$KERNEL_DIR/rules/always/git.md")"
expect success "AGENTS.md holds the project rules" \
  agents_file_contains "$project" "Each feature lives in its own crate."
expect success "AGENTS.md points to the roles" \
  agents_file_contains "$project" ".agents/skills/"
expect success "AGENTS.md has a single top-level heading" \
  has_single_top_heading "$project"
expect success "AGENTS.md states that kernel rules win unless an exception names them" \
  agents_file_contains "$project" "names it as an exception"
expect success "AGENTS.md has a blank line after its header comment" \
  has_blank_line_after_header_comment "$project"
expect success "AGENTS.md has no consecutive blank lines" \
  has_no_consecutive_blank_lines "$project"
expect success "--check passes on an up-to-date AGENTS.md" \
  compile_in "$project" --check

echo "A feature crate depends on no other feature crate." >>"$project/rules/project/architecture.md"
expect failure "--check fails once a rule changed" \
  compile_in "$project" --check

expect success "compile-agents works without project rules" \
  compile_in "$(new_project)"
expect failure "--check fails when AGENTS.md is missing" \
  compile_in "$(new_project)" --check
expect failure "compile-agents refuses an absolute kernel path" \
  bash -c "cd '$project' && '$KERNEL_DIR/scripts/compile-agents'"

finish
