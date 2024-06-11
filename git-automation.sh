#!/bin/bash

# Ensure F-find-github-directory.sh and setup-environment.sh are executable
if [ ! -x "F-find-github-directory.sh" ]; then
	chmod +x F-find-github-directory.sh
fi

if [ ! -x "setup-environment.sh" ]; then
	chmod +x setup-environment.sh
fi

# Run the F-find-github-directory script
./F-find-github-directory.sh
if [ $? -ne 0 ]; then
	echo "Error: F-find-github-directory.sh failed."
	exit 1
fi

# Run the setup-environment script
if [ $? -ne 0 ]; then
	echo "Error: setup-environment.sh failed."
	exit 1
fi

# Refresh the repositories
./git-refresh.sh
if [ $? -ne 0 ]; then
	echo "Error: git-refreshed.sh failed."
	exit 1
fi

# Setup environment
./setup-environment.sh
if [ $? -ne 0 ]; then
	echo "Error: setup-environment.sh failed."
	exit 1
fi

# Source the .bashrc file to ensure environment variables are updated
source ~/.bashrc

# Add .gitignore files to each repository
./git-add-gitignore.sh
if [ $? -ne 0 ]; then
	echo "Error: git-add-gitignore.sh failed."
	exit 1
fi

# Add the git-check-changes script to run on login
if ! grep -q "bash $GITHUB_DIR/automation-scripts/git-check-changes.sh" ~/.bashrc; then
	echo "bash $GITHUB_DIR/automation-scripts/git-check-changes.sh" >>~/.bashrc
	echo "git-check-changes.sh has been added to run on login."
else
	echo "git-check-changes.sh is already set to run on login."
fi

echo "All scripts executed successfully."
