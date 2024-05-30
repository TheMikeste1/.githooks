#!/usr/bin/env bash

REPO_ROOT="$(
  cd "$(git rev-parse --show-toplevel)" >/dev/null 2>&1 || exit
  pwd -P
)"
readonly REPO_ROOT

HOOKS_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
readonly HOOKS_ROOT
export HOOKS_ROOT

MERGE_HASH=$(git rev-parse -q --verify MERGE_HEAD 2>/dev/null)
readonly MERGE_HASH
if [ "$MERGE_HASH" != "" ]; then
  # Merge commit
  echo "Merge commit; skipping hooks"
  exit 0
fi

REBASE_APPLY_PATH="${REPO_ROOT}/.git/rebase-apply"
REBASE_MERGE_PATH="${REPO_ROOT}/.git/rebase-merge"
IS_AMEND=$(ps -ocommand= -p "$PPID" | grep -e '--amend')
export IS_AMEND

if [ -e "$REBASE_APPLY_PATH" ] || [ -e "$REBASE_MERGE_PATH" ]; then
  # Rebase commit
  echo "Rebase commit; skipping hooks"
  exit 0
fi

# Normal commit

# Stash unstaged changes
git stash -q --keep-index

# Get the files that have changed
git_dir=$(git rev-parse --show-toplevel)/
export git_dir

find "$HOOKS_ROOT/scripts/precommit/" -maxdepth 1 -type f -print0 | while IFS= read -r -d $'\0' file; do
  "$file" || exit $?
done

return_code=$?  # We have to grab the return code from the loop
if [ "$return_code" == 0 ]; then
  echo "Success! Committing. . ."
fi

# Unstash the unstaged changes
git stash pop -q
exit "$return_code"
