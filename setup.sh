#!/bin/bash

# Define the directory where we want the repo to reside
TARGET_DIR="/home/ubuntu/Prevent-OCI-Deletion-for-being-idle"

# Define the URL for the GitHub zip file
REPO_ZIP_URL="https://github.com/Codycody31/Prevent-OCI-Deletion-for-being-idle/archive/refs/heads/main.zip"

# Fetch and unzip the repo
wget $REPO_ZIP_URL -O repo.zip
unzip repo.zip -d /home/ubuntu/
mv /home/ubuntu/Prevent-OCI-Deletion-for-being-idle-main $TARGET_DIR
rm repo.zip

# Set up cron
# Note: This will override any previous cron tasks set up for the script
# Backup the crontab first
crontab -l > cron_backup.txt
echo "* * * * * $TARGET_DIR/startPointlessProcesses.sh >> $TARGET_DIR/log/trackPointlessWork.log 2>&1" | crontab -

echo "Setup complete!"
