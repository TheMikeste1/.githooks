#!/usr/bin/env bash
# Git Hook for JIRA_TASK_ID
# Adds to the top of your commit message `JIRA_TASK_ID`, based on the prefix of the current branch `feature/AWG-562-add-linter`
# Example: `Add SwiftLint -> `AWG-562 Add SwiftLint
# Original source: https://github.com/aitemr/awesome-git-hooks/blob/master/prepare-commit-msg/prepare-commit-msg-jira
# shellcheck disable=SC2155

function extractJiraIssue {
    readonly JIRA_ID_REGEX="[A-Z0-9]{1,10}-[A-Z0-9]+"
    echo "$1" | grep -Eo "$JIRA_ID_REGEX" | head -1 # Only select the first valid match
}

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <commit_file>" >&2
    exit 1
fi

readonly current_branch="$(git branch --show-current)"
declare -ra BRANCHES_TO_SKIP="${BRANCHES_TO_SKIP:=("master" "main" "develop" "test")}"
for branch in "${BRANCHES_TO_SKIP[@]}"; do
    if [[ "$branch" = "$current_branch" ]]; then
        echo "Branch \`$branch\` is on ignored branches list; not checking issue number"
        exit 0
    fi
done

readonly commit_file="$1"
readonly commit_msg=$(cat "$1")

if [[ "$commit_msg" == "fixup"* ]]; then
    echo "Fixup commit; not checking issue number"
    exit 0
fi

# Extract the ID
readonly id_in_branch="$(extractJiraIssue "$current_branch")"
readonly first_line_in_msg="$(echo "$commit_msg" | head -1)"
readonly id_in_msg="$(extractJiraIssue "$first_line_in_msg")"

if [[ "$id_in_msg" == "" ]] && [[ "$id_in_branch" == "" ]]; then
    # No ID to match against
    exit 0
fi

if [[ "$id_in_branch" != "" ]]; then
    echo "JIRA ID '$id_in_branch', matched in current branch name, prepended to commit message."
    echo "$id_in_branch $commit_msg" > "$commit_file"
fi

if [[ "$id_in_msg" != "$id_in_branch" ]]; then
    echo "WARNING: Commit message JIRA_TASK_ID='$id_in_msg' is not equal to current branch JIRA_TASK_ID='$id_in_branch'" >&2
    printf "\tCommit message will contain both\n" >&2
    echo "$id_in_branch $commit_msg" > "$commit_file"
fi
