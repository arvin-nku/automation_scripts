#!/bin/bash

# Ensure GITHUB_DIR is set
if [ -z "$GITHUB_DIR" ]; then
    echo "GITHUB_DIR is not set. Please run find-github-dir.sh first and source ~/.bashrc."
    exit 1
fi

# Define the .gitignore content
GITIGNORE_CONTENT=$(cat <<EOF
# Ignore environment files
.env
*.env

# Ignore log files
*.log

# Ignore text files
*.txt

# Ignore all log directories
logs/

# Ignore specific files in config directory
config/*.env

# Ignore all log files except app.log
*.log
!app.log
EOF
)

# Function to add or update .gitignore in a repository
add_gitignore_to_repo() {
    local repo_dir="$1"
    echo "$GITIGNORE_CONTENT" > "$repo_dir/.gitignore"
    cd "$repo_dir" || exit
    git add .gitignore
    git commit -m "Add .gitignore file"
    cd - > /dev/null || exit
}

# Iterate over each repository in the GITHUB_DIR
for repo_dir in "$GITHUB_DIR"/*/; do
    if [ -d "$repo_dir/.git" ]; then
        add_gitignore_to_repo "$repo_dir"
        echo ".gitignore added to $repo_dir"
    fi
done

echo "All repositories have been updated with .gitignore."

