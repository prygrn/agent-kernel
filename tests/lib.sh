# shellcheck shell=bash
# Shared assertions for the kernel's shell tests.

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
