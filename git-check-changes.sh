#!/bin/bash

# Ensure GITHUB_DIR is set
if [ -z "$GITHUB_DIR" ]; then
	echo "GITHUB_DIR is not set. Please run find-github-dir.sh first and source ~/.bashrc."
	exit 1
fi

# Output file for repositories with changes
OUTPUT_FILE="$GITHUB_DIR/repositories_with_changes.log"

# Function to check for changes in a repository
check_changes_in_repo() {
	local repo_dir="$1"
	cd "$repo_dir" || exit
	# Check for uncommitted changes
	if [ -n "$(git status --porcelain)" ]; then
		echo "$repo_dir has uncommitted changes." >>"$OUTPUT_FILE"
	else
		# Check for changes that need to be pulled or pushed
		git fetch
		LOCAL=$(git rev-parse @)
		REMOTE=$(git rev-parse "@{u}")
		BASE=$(git merge-base @ "@{u}")

		if [ "$LOCAL" != "$REMOTE" ]; then
			echo "$repo_dir has changes that need to be pulled or pushed." >>"$OUTPUT_FILE"
		fi
	fi
	cd - >/dev/null || exit
}

# Clear the output file
: >"$OUTPUT_FILE"

# Iterate over each repository in the GITHUB_DIR
for repo_dir in "$GITHUB_DIR"/*/; do
	if [ -d "$repo_dir/.git" ]; then
		check_changes_in_repo "$repo_dir"
	fi
done

# Check if the output file is not empty
if [ -s "$OUTPUT_FILE" ]; then
	echo "REPOSITORIES with changes:"
	cat "$OUTPUT_FILE"
else
	echo "No repositories with changes."
fi
