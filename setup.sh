#!/bin/bash

# Welcome message
echo "Welcome to the setup script for Prevent-OCI-Deletion-for-being-idle!"

# Define the directory where we want the repo to reside
TARGET_DIR="/home/ubuntu/Prevent-OCI-Deletion-for-being-idle"
echo "This script will install the repo in to $TARGET_DIR..."

# Define the URL for the GitHub zip file
REPO_ZIP_URL="https://github.com/Codycody31/Prevent-OCI-Deletion-for-being-idle/archive/refs/heads/production.zip"

# Fetch and unzip the repo
echo "Fetching and unzipping the repo..."
wget $REPO_ZIP_URL -O repo.zip
unzip repo.zip -d /home/ubuntu/
echo "Moving the repo to $TARGET_DIR..."
mv /home/ubuntu/Prevent-OCI-Deletion-for-being-idle-production $TARGET_DIR
rm repo.zip

# Set up cron
# Backup the crontab first
crontab -l > cron_backup.txt

# Check if the cron task already exists
if grep -q "startPointlessProcesses.sh" cron_backup.txt; then
    echo "Cron task already exists. Skipping..."
else
    echo "Cron task does not exist. Adding..."
    # Add the cron task without overwriting
    (crontab -l; echo "* * * * * /bin/bash $TARGET_DIR/startPointlessProcesses.sh >> $TARGET_DIR/log/trackPointlessWork.log 2>&1") | crontab -
fi

echo "Setup complete!"
