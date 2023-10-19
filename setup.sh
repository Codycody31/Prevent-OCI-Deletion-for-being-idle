#!/bin/bash

# Welcome message
echo "Welcome to the setup script for Prevent-OCI-Deletion-for-being-idle!"

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
if [ ! -d "/home/ubuntu/Prevent-OCI-Deletion-for-being-idle/log" ]; then
    echo "The log directory does not exist. Creating..."
    mkdir /home/ubuntu/Prevent-OCI-Deletion-for-being-idle/log
fi

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
