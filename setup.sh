#!/bin/bash

# Welcome message
echo "Welcome to the setup script for Prevent-OCI-Deletion-for-being-idle!"

# Get the username of the user executing the script
CURRENT_USER=$(whoami)

# Define the directory where we want the repo to reside
TARGET_DIR="$HOME/Prevent-OCI-Deletion-for-being-idle"

# Check if the repository already exists
if [ -d "$TARGET_DIR" ]; then
  echo "It seems the repository is already installed at $TARGET_DIR."
  read -p "Do you want to update it to the latest version? (y/n): " decision

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
  mkdir -p "$TARGET_DIR"/log
fi

echo "This script will install the repo into $TARGET_DIR..."

# Define the URL for the GitHub zip file
REPO_ZIP_URL="https://github.com/Codycody31/Prevent-OCI-Deletion-for-being-idle/archive/refs/heads/master.zip"

# Fetch and unzip the repo
echo "Fetching and unzipping the repo..."
wget "$REPO_ZIP_URL" -O "$HOME"/POCIDFBI.zip
unzip "$HOME"/POCIDFBI.zip -d "$HOME"/

echo "Moving the repo to $TARGET_DIR..."

# Check if target dir is not empty
if [ "$(ls -A "$TARGET_DIR")" ]; then
  echo "Target directory is not empty. Cleaning up..."
  rm -f -r "$TARGET_DIR"/*
fi

# Move content to location
mv "$HOME"/Prevent-OCI-Deletion-for-being-idle-master/* "$TARGET_DIR"

# Clean up files
rm -f -r "$HOME"/POCIDFBI.zip "$HOME"/Prevent-OCI-Deletion-for-being-idle-master

# Set up cron
# Backup the crontab first
crontab -l >"$HOME"/cron_backup.txt

# Check if the cron task already exists
if grep -q "startPointlessProcesses.sh" "$HOME"/cron_backup.txt; then
  echo "Cron task already exists. Skipping..."
else
  echo "Cron task does not exist. Adding..."
  # Add the cron task without overwriting
  (
    crontab -l
    echo "* * * * * /bin/bash $TARGET_DIR/startPointlessProcesses.sh"
  ) | crontab -
fi

echo "Setup complete!"
