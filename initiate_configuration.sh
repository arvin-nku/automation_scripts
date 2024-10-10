#!/bin/bash

# Function to detect the Operation System and set the appropriate configurations 
detect_os() {
    if grep -qEi "(Microsoft|WSL)" /proc/version &>/dev/null; then
        # Windows/WSL detected
        WIN_USER=$(cmd.exe /C echo %USERNAME% | tr -d '\r')
        WIN_DESKTOP_PATH=$(cmd.exe /C echo %USERPROFILE%\\Desktop | tr -d '\r' | sed 's|\\|/|g' | sed 's|C:|/mnt/c|')

        alias wdwd="cd $WIN_DESKTOP_PATH"
        DESKTOP_PATH="$WIN_DESKTOP_PATH"
        echo "Windows (WSL) detected. Setting Desktop path to $DESKTOP_PATH"
    else
        # Native Linux system detected
        LINUX_DESKTOP_PATH="$HOME/Desktop"
        alias wdwd="cd $LINUX_DESKTOP_PATH"
        DESKTOP_PATH="$LINUX_DESKTOP_PATH"
        echo "Linux detected. Setting Desktop path to $DESKTOP_PATH"
    fi
}

# Preperations 
preparations() {
    GITHUB_PATH="$HOME/GITHUB"
    REPO_URL="https://github.com/arvin-nku/automation_scripts" 
    
    # Check if it's symbolic lin
    if [ -L "$GITHUB_PATH" ]; then
        echo "$GITHUB_PATH is a symbolic link."
        # Navigate to the symbolic link's directory and clone the repository
        # FEATURE below is called -> short-circuit evaluation with the OR || operator
        #                        and inline command blocks using {}
        cd "$GITHUB_PATH" || { echo "Failed to access symbolic link directory."; exit 1; }
        git clone "$REPO_URL"

    # Check if it's a directory
    elif [ -d "$GITHUB_PATH" ]; then
        echo "$GITHUB_PATH is a directory."
        # Navigate to the directory and clone the repository
        cd "$GITHUB_PATH" || { echo "Failed to access directory."; exit 1; }
        git clone "$REPO_URL"
        

    # If GITHUB_PATH doesn't exist, create the directory
    else
        echo "$GITHUB_PATH does not exist. Creating it..."
        mkdir -p "$GITHUB_PATH" # Create the GITHUB directory
        cd "$GITHUB_PATH" || { echo "Failed to access newly created directory."; exit 1; }
        git clone "$REPO_URL"
    fi
}



# Function to detect the Linux distribution and set the appropriate package manager commands
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case $ID in
            ubuntu)
                PKG_UPDATE="sudo apt update -y"
                PKG_INSTALL="sudo apt install -y"
                ;;
            arch)
                PKG_UPDATE="sudo pacman -Syu --noconfirm"
                PKG_INSTALL="sudo pacman -S --noconfirm"
                ;;
            *)
                echo "Unsupported distribution: $ID"
                exit 1
                ;;
        esac
    else
        echo "Could not detect the distribution."
        exit 1
    fi
}

# Function to clone the GitHub repository containing package lists
clone_package_list() {
    echo "Cloning package list from GitHub to GITHUB directory..." 
    if [ -d "~/GITHUB/
    # git clone https://github.com/<YourUsername>/<YourRepo>.git ~/package-backup
    if [ $? -ne 0 ]; then
        echo "Error cloning the repository. Exiting."
        exit 1
    fi
}

# Function to install packages from the list (works for both Ubuntu and Arch)
install_packages() {
    echo "Updating package list and installing packages..."

    # Run the appropriate package manager update command
    eval $PKG_UPDATE

    # Install packages from the list
    while IFS= read -r package || [ -n "$package" ]; do
        # Skip comments and empty lines
        if [[ "$package" =~ ^#.* ]] || [[ -z "$package" ]]; then
            continue
        fi
        echo "Installing $package..."
        eval "$PKG_INSTALL $package"
    done < ~/package-backup/packages.txt
}

# Function to apply common configurations (same for both Ubuntu and Arch)
apply_common_configs() {
    echo "Applying common configurations..."
    
    # Example: Copy a pre-configured .bashrc file from backup
    if [ -f ~/package-backup/.bashrc ]; then
        cp ~/package-backup/.bashrc ~/
        echo ".bashrc configuration applied."
    else
        echo ".bashrc not found in the backup."
    fi
    
    # Example: Set up Git configuration
    git config --global user.name "Your Name"
    git config --global user.email "youremail@example.com"
    echo "Git configuration applied."
}

# Main script logic
detect_distro

echo "Detected distribution and set package manager commands."

# Clone the package list repository from GitHub
clone_package_list

# Install packages based on the detected distribution
install_packages

# Apply additional configurations
apply_common_configs

echo "Setup complete!"

