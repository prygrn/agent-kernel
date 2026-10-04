#!/usr/bin/env bash
# Tests templates/githook, the wrapper a consumer copies into its own hooks directory.
set -euo pipefail

KERNEL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
readonly KERNEL_DIR
# shellcheck source=SCRIPTDIR/lib.sh
source "$(dirname "$0")/lib.sh"

# A consumer repository whose tracked .githooks/ wraps the kernel hooks at .agents.
new_consumer() {
  local repository_dir
  repository_dir="$(new_temp_dir)"
  git -C "$repository_dir" init -q -b feature
  git -C "$repository_dir" config user.email test@example.com
  git -C "$repository_dir" config user.name test
  git -C "$repository_dir" config core.hooksPath .githooks
  mkdir "$repository_dir/.githooks"
  cp "$KERNEL_DIR/templates/githook" "$repository_dir/.githooks/commit-msg"
  ln -s "$KERNEL_DIR" "$repository_dir/.agents"
  printf 'quality: ; @true\ntest: ; @true\n' >"$repository_dir/Makefile"
  echo "$repository_dir"
}

commit_in() {
  local repository_dir="$1"
  shift
  date +%s%N >>"$repository_dir/change"
  git -C "$repository_dir" add -A
  git -C "$repository_dir" commit -q "$@"
}

consumer="$(new_consumer)"
expect success "the wrapper lets a valid commit through the kernel hook" \
  commit_in "$consumer" -m "feat(core): add receipt total"
expect failure "the wrapper applies the kernel hook to an invalid commit" \
  commit_in "$consumer" -m "Add receipt total"

consumer_without_kernel="$(new_consumer)"
rm "$consumer_without_kernel/.agents"
expect failure "the wrapper blocks the commit when the kernel hook is missing" \
  commit_in "$consumer_without_kernel" -m "feat(core): add receipt total"

finish
