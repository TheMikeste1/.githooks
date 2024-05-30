#! /usr/bin/env bash

if [ "${git_dir+x}" = "" ];
then
  exit 1
fi;

changed_files=$(git diff --name-only --diff-filter=d --staged | grep -Ei "^.+\.pyi?$")
read -ra changed_files -d "\n" <<< "$changed_files"
changed_files=("${changed_files[@]/#/$git_dir}")

if [ ${#changed_files[@]} -eq 0 ];
then
  # Do nothing if nothing to do
  exit 0
fi

echo "# Running Python isort"
python3 -m isort --atomic "${changed_files[@]}"

echo "# Running Python Black"
python3 -m black "${changed_files[@]}"

echo "# Running Python Prospector"
python3 -m prospector "${changed_files[@]}"

git add "${changed_files[@]}"
