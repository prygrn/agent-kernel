# shellcheck shell=bash
# Shared assertions for the kernel's shell tests.

# Tests run from inside git hooks too, where git exports GIT_DIR and friends.
# Left set, they make every throwaway repository resolve to the hook's repository.
mapfile -t inherited_git_variables < <(git rev-parse --local-env-vars)
unset "${inherited_git_variables[@]}"

TEST_ROOT="$(mktemp -d)"
readonly TEST_ROOT
trap 'rm -rf "$TEST_ROOT"' EXIT

failure_count=0

new_temp_dir() {
  mktemp -d "$TEST_ROOT/XXXXXX"
}

# expect <success|failure> <description> <command...>
expect() {
  local expected="$1" description="$2" actual
  shift 2
  if "$@" >/dev/null 2>&1; then actual=success; else actual=failure; fi
  if [[ "$actual" == "$expected" ]]; then
    echo "ok   $description"
  else
    echo "FAIL $description (expected $expected, got $actual)"
    failure_count=$((failure_count + 1))
  fi
}

finish() {
  ((failure_count == 0))
}
