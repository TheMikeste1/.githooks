#!/usr/bin/env bash

# Git Hook for JIRA_TASK_ID
# Adds to the top of your commit message `JIRA_TASK_ID`, based on the prefix of the current branch `feature/AWG-562-add-linter`
# Example: `Add SwiftLint -> `AWG-562 Add SwiftLint
# Original source: https://github.com/aitemr/awesome-git-hooks/blob/master/prepare-commit-msg/prepare-commit-msg-jira

if [ "$#" -lt 1 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

if [[ "$BRANCHES_TO_SKIP" = "" ]]; then
    BRANCHES_TO_SKIP='develop test'
fi

CURRENT_BRANCH=$(git branch --show-current)
for BRANCH in "${BRANCHES_TO_SKIP[@]}"; do
    if [[ "$BRANCH" = "$CURRENT_BRANCH" ]]; then
        exit 0
    fi
done

COMMIT_FILE=$1
COMMIT_MSG=$(cat "$1")
JIRA_ID_REGEX="^[A-Z0-9]{1,10}-?[A-Z0-9]+"
JIRA_ID_IN_CURRENT_BRANCH_NAME=$(echo "$CURRENT_BRANCH" | { grep -Eo "$JIRA_ID_REGEX" | tr '\n' ' ' | sed 's/ *$//' || true; })
JIRA_ID_IN_COMMIT_MESSAGE=$(echo "$COMMIT_MSG" | { grep -Eo "$JIRA_ID_REGEX" | tr '\n' ' ' | sed 's/ *$//' || true; })

if [[ "$JIRA_ID_IN_COMMIT_MESSAGE" != "" ]] && [[ "$JIRA_ID_IN_CURRENT_BRANCH_NAME" != "" ]]; then
    if [[ "$JIRA_ID_IN_COMMIT_MESSAGE" != "$JIRA_ID_IN_CURRENT_BRANCH_NAME" ]]; then
        echo "ERROR: Commit message JIRA_TASK_ID='$JIRA_ID_IN_COMMIT_MESSAGE' is not equal to current branch JIRA_TASK_ID='$JIRA_ID_IN_CURRENT_BRANCH_NAME'"
        exit 1
    fi
elif [[ "$JIRA_ID_IN_CURRENT_BRANCH_NAME" != "" ]]; then
    echo "$JIRA_ID_IN_CURRENT_BRANCH_NAME $COMMIT_MSG" > "$COMMIT_FILE"
    echo "JIRA ID '$JIRA_ID_IN_CURRENT_BRANCH_NAME', matched in current branch name, prepended to commit message. (Use --no-verify to skip)"
fi
