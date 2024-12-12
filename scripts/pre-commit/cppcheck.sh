#!/usr/bin/env bash

declare -r staged_files=( "$@" )

mkdir -p .cache/cppcheck || exit 1
cppcheck --enable=warning,performance,portability,information --disable=missingInclude --suppress=unknownMacro --suppress=checkersReport --suppress=normalCheckLevelMaxBranches --suppress=unmatchedSuppression --language=c++ --cppcheck-build-dir=.cache/cppcheck --error-exitcode=1 --inline-suppr --force --library=googletest -j 8 "${staged_files[@]}"
exit $?
