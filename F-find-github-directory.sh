#!/bin/bash

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
	echo "GITHUB_DIR=$GITHUB_DIR" >github_dir.env
	# Add to .bashrc if not already added
	if ! grep -q "GITHUB_DIR=$GITHUB_DIR" ~/.bashrc; then
		echo "export GITHUB_DIR=$GITHUB_DIR" >>~/.bashrc
		echo "GITHUB_DIR added to ~/.bashrc"
	else
		echo "GITHUB_DIR is already set in ~/.bashrc"
	fi
fi
