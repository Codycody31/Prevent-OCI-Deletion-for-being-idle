#!/bin/bash

# Initialize flag for cron setup to true (meaning by default cron will be set up)
SETUP_CRON=true

# Function to display help message
display_help() {
    echo "Usage: $0 [options]"
    echo "  -n  Disable cron setup."
    echo "  -h  Display this help message."
}

# Check for --help option
if [[ " $* " == *" --help "* ]]; then
    display_help
    exit 0
fi

# Parse CLI arguments
while getopts ":nh" opt; do
    case ${opt} in
    n) # process option n
        SETUP_CRON=false
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

# Define the directory where we want the repo to reside
TARGET_DIR="$HOME/Prevent-OCI-Deletion-for-being-idle"

# Check if the repository already exists
if [ -d "$TARGET_DIR" ]; then
    echo "It seems the repository is already installed at $TARGET_DIR."
    read -p -r "Do you want to update it to the latest version? (y/n): " decision

    if [[ $decision == "n" ]]; then
        echo "Exiting setup..."
        exit 1
    fi
fi

# Ensure that wget and unzip are installed
echo "Checking if wget and unzip are installed..."
if ! [ -x "$(command -v wget)" ]; then
    echo "wget is not installed. Installing..."
    sudo apt-get install wget
fi
if ! [ -x "$(command -v unzip)" ]; then
    echo "unzip is not installed. Installing..."
    sudo apt-get install unzip
fi

# Ensure that the log directory exists
echo "Checking if the log directory exists..."
if [ ! -d "$TARGET_DIR/log" ]; then
    echo "The log directory does not exist. Creating..."
    mkdir -p "$TARGET_DIR/log"
fi

echo "This script will install the repo into $TARGET_DIR..."

# Define the URL for the GitHub zip file
REPO_ZIP_URL="https://github.com/Codycody31/Prevent-OCI-Deletion-for-being-idle/archive/refs/heads/stable.zip"

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
mv "$HOME"/Prevent-OCI-Deletion-for-being-idle-stable/* "$TARGET_DIR"

# Clean up files
rm -f -r "$HOME/POCIDFBI.zip" "$HOME/Prevent-OCI-Deletion-for-being-idle-stable"

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
