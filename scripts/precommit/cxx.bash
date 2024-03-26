#! /usr/bin/env bash

if [ -z ${git_dir+x} ];
then
  exit 1
fi;

changed_files=$(git diff --name-only --diff-filter=d --staged | grep -Ei "^.*\.[hc](pp|xx)?$")
read -ra changed_files -d "\n" <<< "$changed_files"
changed_files=("${changed_files[@]/#/$git_dir}")

if [ ${#changed_files[@]} -eq 0 ];
then
  # Do nothing if nothing to do
  exit 0
fi

# clang-format
# Format the staged files
echo "Running clang-format. . ."
clang-format -style=file -i "${changed_files[@]}"
git add "${changed_files[@]}"

# cppcheck
echo "Running cppcheck. . ."
if ! cppcheck --error-exitcode=1 --force --library=googletest "${changed_files[@]}";
then
    echo "Unable to commit!"
    exit 1
fi
