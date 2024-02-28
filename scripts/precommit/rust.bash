#! /usr/bin/env bash

if [ -z ${git_dir+x} ]; then
  exit 1
fi

changed_files=$(git diff --name-only --diff-filter=d --staged | grep -Ei "\.rs$")
read -ra changed_files -d "\n" <<<"$changed_files"
changed_files=("${changed_files[@]/#/$git_dir}")

if [ ${#changed_files[@]} -eq 0 ]; then
  # Do nothing if nothing to do
  exit 0
fi

# Format the staged files
echo "Running rustfmt. . ."
rustfmt --edition 2021 "${changed_files[@]}"
git add "${changed_files[@]}"

echo "Running clippy. . ."
cargo clippy -- -D warnings || exit 1
