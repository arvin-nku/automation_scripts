#!/bin/bash

########## adding automation_scripts to path for the scripts to be executable
# Function to search for the GITHUB directory
find_github_directory() {
	find ~ /mnt/c/Users -type d -name "GITHUB" -exec sh -c '
        for dir; do
            if [ -f "$dir/git" ]; then
                echo "$dir"
                exit 0
            fi
        done
        exit 1
    ' sh {} +
}

# Find the GITHUB directory
GITHUB_DIR=$(find_github_directory)

if [ -z "$GITHUB_DIR" ]; then
	echo "GITHUB directory with git not found. Exiting."
	exit 1
else
	echo "GITHUB directory found at $GITHUB_DIR"
fi

# Ensure the automation_scripts directory exists
SCRIPTS_DIR="$GITHUB_DIR/automation_scripts"

if [ ! -d "$SCRIPTS_DIR" ]; then
	echo "automation_scripts directory does not exist. Running git-refresh.sh to create it..."
	./git-refresh.sh
fi

if [ ! -d "$SCRIPTS_DIR" ]; then
	echo "Failed to create automation_scripts directory. Exiting."
	exit 1
fi

# Add the automation_scripts directory to PATH and make scripts executable
export PATH="$SCRIPTS_DIR:$PATH"

for script in "$SCRIPTS_DIR"/*.sh; do
	[ -f "$script" ] && chmod +x "$script"
done

echo "automation_scripts directory has been added to PATH and scripts made executable."
