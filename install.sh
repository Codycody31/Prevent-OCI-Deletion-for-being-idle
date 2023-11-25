#!/bin/bash

# Initialize flag for cron setup to true (meaning by default cron will be set up)
SETUP_CRON=true
TARGET_DIR="$HOME/Prevent-OCI-Deletion-for-being-idle" # Default installation directory

# Function to display help message
display_help() {
    echo "Usage: $0 [options]"
    echo "  -n  Disable cron setup."
    echo "  -h  Display this help message."
}

# Function to check and install necessary commands
check_and_install_command() {
    local cmd=$1
    local package=$2
    if ! [ -x "$(command -v $cmd)" ]; then
        echo "$cmd is not installed. Installing..."
        install_package $package
    else
        echo "$cmd is already installed."
    fi
}

# Function to detect and use system's package manager
install_package() {
    local package=$1
    if [ -x "$(command -v apt-get)" ]; then
        sudo apt-get install $package
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install $package
    else
        echo "No known package manager found. Install $package manually."
        exit 1
    fi
}

# Check for --help option
if [[ " $* " == *" --help "* ]]; then
    display_help
    exit 0
fi

# Parse CLI arguments
while getopts ":nd:h" opt; do
    case ${opt} in
    n) # process option n
        SETUP_CRON=false
        ;;
    d)
        TARGET_DIR=$OPTARG
        ;;
    h) # process option h
        display_help
        exit 0
        ;;
    \?)
        echo "Usage: $0 [-n (no cron setup)]"
        exit 1
        ;;
    esac
done

# Welcome message
echo "Welcome to the setup script for Prevent-OCI-Deletion-for-being-idle!"

# Check if the repository already exists
if [ -d "$TARGET_DIR" ]; then
    echo "It seems the repository is already installed at $TARGET_DIR."

    # Ask user if they want to update the repo
    read -rp "Do you want to update it to the latest version? (y/n): " decision
    if [[ $decision == "n" ]]; then
        echo "Exiting setup..."
        exit 1
    fi

    # Delete the old repo
    echo "Deleting the old repo..."
    rm -f -r "$TARGET_DIR"
fi

# Ensure that wget and unzip are installed
echo "Checking if wget and unzip are installed..."
check_and_install_command "wget" "wget"
check_and_install_command "unzip" "unzip"

# Ensure that the log directory exists
echo "Checking if the log directory exists..."
if [ ! -d "$TARGET_DIR/log" ]; then
    echo "The log directory does not exist. Creating..."
    mkdir -p "$TARGET_DIR/log"
fi

echo "This script will install the repo into $TARGET_DIR..."

# Define the URL for the GitHub zip file
REPO_ZIP_URL="https://github.com/Codycody31/Prevent-OCI-Deletion-for-being-idle/archive/refs/heads/master.zip"

# Fetch and unzip the repo
echo "Fetching and unzipping the repo..."
wget $REPO_ZIP_URL -O "$HOME/POCIDFBI.zip"
unzip "$HOME/POCIDFBI.zip" -d "$HOME/"

echo "Moving the repo to $TARGET_DIR..."

# Check if target dir is not empty
if [ "$(ls -A "$TARGET_DIR")" ]; then
    echo "Target directory is not empty. Cleaning up..."
    rm -f -r "${TARGET_DIR/*/}"
fi

# Move content to location
mv "$HOME"/Prevent-OCI-Deletion-for-being-idle-master/* "$TARGET_DIR"

# Clean up files
rm -f -r "$HOME/POCIDFBI.zip" "$HOME/Prevent-OCI-Deletion-for-being-idle-master"

# Make POCIDFBI.sh executable and add it to PATH
chmod +x "$TARGET_DIR/POCIDFBI.sh"
# If it is not already in bin, add it
if ! [ -x "$(command -v POCIDFBI)" ]; then
    sudo ln -s "$TARGET_DIR/POCIDFBI.sh" /usr/local/bin/POCIDFBI
fi
echo "POCIDFBI.sh is now executable and can be run from anywhere using the command POCIDFBI."

# Set up cron only if SETUP_CRON is true
if $SETUP_CRON; then
    # Backup the crontab first
    crontab -l >"$HOME/cron_backup.txt"

    # Check if the cron task already exists
    if grep -q "POCIDFBIManager.sh" "$HOME/cron_backup.txt"; then
        echo "Cron task already exists. Skipping..."
    else
        echo "Cron task does not exist. Adding..."
        # Add the cron task without overwriting
        (
            crontab -l
            echo "* * * * * /bin/bash $TARGET_DIR/POCIDFBIManager.sh"
        ) | crontab -
    fi
else
    echo "Skipping cron setup as per user request."
    echo "If you'd like to add the cron task manually later, here's the line you would add to your crontab:"
    echo "* * * * * /bin/bash $TARGET_DIR/POCIDFBIManager.sh"
fi

echo "Setup complete!"
