#!/usr/bin/env bash

declare -r staged_files=( "$@" )

cmake-lint --suppress-decorations "${staged_files[@]}" -c "$HOME/.githooks/config/precommit/cmake-format.yaml"
exit $?
