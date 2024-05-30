#! /usr/bin/env bash

if [ "${git_dir+x}" = "" ];
then
  exit 1
fi;

changed_files=$(git diff --name-only --diff-filter=d --staged | grep -Ei "CMakeLists.txt$|\.cmake$")
read -ra changed_files -d "\n" <<< "$changed_files"
changed_files=("${changed_files[@]/#/$git_dir}")

if [ ${#changed_files[@]} -eq 0 ];
then
  # Do nothing if nothing to do
  exit 0
fi

# cmake-format
# Format the staged files
echo "Running cmake-format. . ."
cmake-format -i "${changed_files[@]}" -c "$HOOKS_ROOT/config/precommit/cmake-format.yaml"
git add "${changed_files[@]}"

# cmake-lint
echo "Running cmake-lint. . ."
cmake-lint --suppress-decorations "${changed_files[@]}" -c "$HOOKS_ROOT/config/precommit/cmake-format.yaml"
