#!/usr/bin/env sh
# Run this when cloning
hook_dir="$(dirname "$(realpath "$0")")"
git config core.hooksPath "$hook_dir"
