#!/usr/bin/env bash

declare -r staged_files=( "$@" )

cmake-format --check -c "$HOME/.githooks/config/precommit/cmake-format.yaml" "${staged_files[@]}" || (cmake-format -i -c "$HOME/.githooks/config/precommit/cmake-format.yaml" "${staged_files[@]}" && false)
exit $?
