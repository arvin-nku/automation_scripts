#!/bin/bash

#Configuration
GITHUB_USERNAME="arvin-nku"
GITHUB_TOKEN="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" # Use a Github token if your repos are private
GITHUB_DIR="$HOME/GITHUB"

# Debugging: Check if the variables are set correctly
echo "GITHUB_USERNAME: $GITHUB_USERNAME"
echo "GITHUB_TOKEN: $GITHUB_TOKEN"

# Exit if variables are not set
if [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_TOKEN" ]; then
	echo "GITHUB_USERNAME and GITHUB_TOKEN must be set. Exiting."
	exit 1
fi

# Create GITHUB directory if it doesn't exist
mkdir -p "$GITHUB_DIR"

# Function to clone or update a repository
clone_or_update_repo() {
	local repo_name="$1"
	local repo_url="https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$repo_name.git"
	local repo_dir="$GITHUB_DIR/$repo_name"
	local status=""

	if [ -d "$repo_dir" ]; then
		cd "$repo_dir" || exit
		git fetch
		LOCAL=$(git rev-parse @)
		REMOTE=$(git rev-parse @{u})
		BASE=$(git merge-base @ @{u})

		if [ $LOCAL = $REMOTE ]; then
			status="up-to-date"
		elif [ $LOCAL = $BASE ]; then
			status="needs-pull"
			echo "Updating $repo_name..."
			git pull
		else
			status="needs-commit-or-push"
			echo "There are changes in $repo_name that need to be pushed to main."
		fi
		# change back to prev directory and handle errors
		# >/dev/null changes the standard output to /dev/null to silence any output
		cd - >/dev/null || exit
	else
		status="not-cloned"
		echo "Cloning $repo_name..."
		git clone "$repo_url" "$repo_dir"
	fi

	echo "$repo_name: $status"
	echo "$repo_name: $status" >>repo_status.log

}

# Get a list of all repositories for the user
repos=$(curl -s -u "$GITHUB_USERNAME:$GITHUB_TOKEN" "https://api.github.com/user/repos?per_page=100" | jq -r '.[].name')

# Debugging: Check if the repos variable is set correctly
if [ -z "$repos" ]; then
	echo "Failed to fetch repositories. Please check your GITHUB_USERNAME and GITHUB_TOKEN."
	exit 1
else
	echo "Repositories fetched successfully:"
	echo "$repos"
fi

# Clear the log file
>repo_status.log

# Iterate over each repository and clone or update it
for repo in $repos; do
	clone_or_update_repo "$repo"
done

# Check the log file for the status of repositories
echo "Summary of repository statuses:"
cat repo_status.log | grep -v "up-to-date"

if ! grep -q -v "up-to-date" repo_status.log; then
	echo "All repositories are up to date."
fi

echo "All repositories have been processed."
