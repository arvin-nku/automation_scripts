#!/bin/bash

# Ensure GITHUB_DIR is set
if [ -z "$GITHUB_DIR" ]; then
    echo "GITHUB_DIR is not set. Please run find-github-dir.sh first and source ~/.bashrc."
    exit 1
fi

# Function to check for changes in a repository
check_changes_in_repo() {
    local repo_dir="$1"
    cd "$repo_dir" || exit
    # Check for uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        echo "$repo_dir has uncommitted changes."
    else
        # Check for changes that need to be pulled or pushed
        git fetch
        LOCAL=$(git rev-parse @)
        REMOTE=$(git rev-parse "@{u}")
        BASE=$(git merge-base @ "@{u}")

        if [ "$LOCAL" != "$REMOTE" ]; then
            echo "$repo_dir has changes that need to be pulled or pushed."
        fi
    fi
    cd - > /dev/null || exit
}

# Iterate over each repository in the GITHUB_DIR
for repo_dir in "$GITHUB_DIR"/*/; do
    if [ -d "$repo_dir/.git" ]; then
        check_changes_in_repo "$repo_dir"
    fi
done

