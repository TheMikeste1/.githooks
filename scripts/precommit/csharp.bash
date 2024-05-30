#! /usr/bin/env bash

if [ "${git_dir+x}" = "" ];
then
  exit 1
fi;

changed_files=$(git diff --name-only --diff-filter=d --staged | grep -Ei "^.*\.cs$")
read -ra changed_files -d "\n" <<< "$changed_files"
changed_files=("${changed_files[@]/#/$git_dir}")

if [ ${#changed_files[@]} -eq 0 ];
then
  # Do nothing if nothing to do
  exit 0
fi

# Format
echo "Skipping dotnet format. . ."
# echo "Running dotnet format. . ."
# dotnet format --severity info --include "${changed_files[@]}"
