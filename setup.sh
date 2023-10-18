#!/bin/bash

# Welcome message
echo "Welcome to the setup script for Prevent-OCI-Deletion-for-being-idle!"

# Define the directory where we want the repo to reside
TARGET_DIR="/home/ubuntu/Prevent-OCI-Deletion-for-being-idle"
echo "This script will install the repo in to $TARGET_DIR..."

# Define the URL for the GitHub zip file
REPO_ZIP_URL="https://github.com/Codycody31/Prevent-OCI-Deletion-for-being-idle/archive/refs/heads/master.zip"

# Fetch and unzip the repo
echo "Fetching and unzipping the repo..."
wget $REPO_ZIP_URL -O repo.zip
unzip repo.zip -d /home/ubuntu/
echo "Moving the repo to $TARGET_DIR..."
mv /home/ubuntu/Prevent-OCI-Deletion-for-being-idle-master $TARGET_DIR
rm repo.zip

# Set up cron
# Note: This will override any previous cron tasks set up for the script
# Backup the crontab first
crontab -l > cron_backup.txt

# Check if the cron task already exists
if grep -q "startPointlessProcesses.sh" cron_backup.txt; then
    echo "Cron task already exists. Skipping..."
else
    echo "Cron task does not exist. Adding..."
fi

# Add the cron task
echo "* * * * * $TARGET_DIR/startPointlessProcesses.sh" | crontab -

echo "Setup complete!"
