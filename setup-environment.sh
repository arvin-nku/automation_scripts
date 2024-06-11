#!/bin/bash

# Load the GITHUB_DIR from the environment file
if [ -f github_dir.env ]; then
    source github_dir.env
else
    echo "Environment file github_dir.env not found. Please run find-github-dir.sh first."
    exit 1
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

# Add the automation_scripts directory to PATH and make .sh scripts executable
if ! grep -q "export PATH=\"$SCRIPTS_DIR:\$PATH\"" ~/.bashrc; then
    echo "export PATH=\"$SCRIPTS_DIR:\$PATH\"" >> ~/.bashrc
    echo "SCRIPTS_DIR has been added to PATH in ~/.bashrc"
else
    echo "SCRIPTS_DIR is already in PATH in ~/.bashrc"
fi

# Make only .sh scripts in the directory executable
for script in "$SCRIPTS_DIR"/*.sh; do
    if [ -f "$script" ]; then
        chmod +x "$script"
        echo "Made $script executable."
    fi
done

echo "All .sh scripts in $SCRIPTS_DIR have been made executable."

