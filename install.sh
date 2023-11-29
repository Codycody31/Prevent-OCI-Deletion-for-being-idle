#!/bin/bash

# Initialize flag for cron setup to true (meaning by default cron will be set up)
POCIDFBI_SETUP_CRON=true
POCIDFBI_TARGET_DIR="$HOME/Prevent-OCI-Deletion-for-being-idle" # Default installation directory
IDLE_RUNNER_INSTALL_DIR="$HOME/IdleRunner"                      # Default installation directory for IdleRunner
INSTALL="POCIDFBI"                                              # Default installation type can be POCIDFBI or IDLERUNNER

# Function to display help message
display_help() {
    echo "Usage: $0 [options]"
    echo "  -n  Disable cron setup. (Default: false) (POCIDFBI only)"
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

# Function to install POCIDFBI
install_pocidfbi() {
    # Welcome message
    echo "Welcome to the setup script for Prevent-OCI-Deletion-for-being-idle!"

    # Check if the repository already exists
    if [ -d "$POCIDFBI_TARGET_DIR" ]; then
        echo "It seems the repository is already installed at $POCIDFBI_TARGET_DIR."

        # Ask user if they want to update the repo
        read -rp "Do you want to update it to the latest version? (y/n): " decision
        if [[ $decision == "n" ]]; then
            echo "Exiting setup..."
            exit 1
        fi

        # Delete the old repo
        echo "Deleting the old repo..."
        rm -f -r "$POCIDFBI_TARGET_DIR"
    fi

    # Ensure that wget and unzip are installed
    echo "Checking if wget and unzip are installed..."
    check_and_install_command "wget" "wget"
    check_and_install_command "unzip" "unzip"

    # Ensure that the log directory exists
    echo "Checking if the log directory exists..."
    if [ ! -d "$POCIDFBI_TARGET_DIR/log" ]; then
        echo "The log directory does not exist. Creating..."
        mkdir -p "$POCIDFBI_TARGET_DIR/log"
    fi

    echo "This script will install the repo into $POCIDFBI_TARGET_DIR..."

    # Define the URL for the GitHub zip file
    REPO_ZIP_URL="https://github.com/Codycody31/Prevent-OCI-Deletion-for-being-idle/archive/refs/heads/master.zip"

    # Fetch and unzip the repo
    echo "Fetching and unzipping the repo..."
    wget $REPO_ZIP_URL -O "$HOME/POCIDFBI.zip"
    unzip "$HOME/POCIDFBI.zip" -d "$HOME/"

    echo "Moving the repo to $POCIDFBI_TARGET_DIR..."

    # Check if target dir is not empty
    if [ "$(ls -A "$POCIDFBI_TARGET_DIR")" ]; then
        echo "Target directory is not empty. Cleaning up..."
        rm -f -r "${POCIDFBI_TARGET_DIR/*/}"
    fi

    # Move content to location
    mv "$HOME"/Prevent-OCI-Deletion-for-being-idle-master/* "$POCIDFBI_TARGET_DIR"

    # Clean up files
    rm -f -r "$HOME/POCIDFBI.zip" "$HOME/Prevent-OCI-Deletion-for-being-idle-master"

    # Make POCIDFBI.sh executable and add it to PATH
    chmod +x "$POCIDFBI_TARGET_DIR/POCIDFBI.sh"
    # If it is not already in bin, add it
    if ! [ -x "$(command -v POCIDFBI)" ]; then
        sudo ln -s "$POCIDFBI_TARGET_DIR/POCIDFBI.sh" /usr/local/bin/POCIDFBI
    fi
    echo "POCIDFBI.sh is now executable and can be run from anywhere using the command POCIDFBI."

    # Set up cron only if POCIDFBI_SETUP_CRON is true
    if $POCIDFBI_SETUP_CRON; then
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
                echo "* * * * * /bin/bash $POCIDFBI_TARGET_DIR/POCIDFBIManager.sh"
            ) | crontab -
        fi
    else
        echo "Skipping cron setup as per user request."
        echo "If you'd like to add the cron task manually later, here's the line you would add to your crontab:"
        echo "* * * * * /bin/bash $POCIDFBI_TARGET_DIR/POCIDFBIManager.sh"
    fi

    echo "Setup complete!"
}

# Function to install IdleRunner
install_idlerunner() {
    # Welcome message
    echo "Welcome to the setup script for IdleRunner!"

    # Check if the repository already exists
    if [ -d "$TARGET_DIR" ]; then
        echo "It seems the repository is already installed at $IDLE_RUNNER_INSTALL_DIR."

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

    echo "This script will install the repo into $IDLE_RUNNER_INSTALL_DIR..."

    # Define the URL for the GitHub zip file
    REPO_ZIP_URL="https://github.com/Drag-NDrop/IdleRunner/archive/refs/heads/main.zip"

    # Fetch and unzip the repo
    echo "Fetching and unzipping the repo..."
    wget $REPO_ZIP_URL -O "$HOME/IdleRunner.zip"
    unzip "$HOME/IdleRunner.zip" -d "$HOME/"

    echo "Moving the repo to $IDLE_RUNNER_INSTALL_DIR..."

    # Ensurethe installation directory exists
    if [ ! -d "$IDLE_RUNNER_INSTALL_DIR" ]; then
        echo "The installation directory does not exist. Creating..."
        mkdir -p "$IDLE_RUNNER_INSTALL_DIR"
    fi

    # Check if target dir is not empty
    if [ "$(ls -A "$IDLE_RUNNER_INSTALL_DIR")" ]; then
        echo "Target directory is not empty. Cleaning up..."
        rm -f -r "${IDLE_RUNNER_INSTALL_DIR/*/}"
    fi

    # Move content to location
    mv "$HOME"/IdleRunner-main/* "$IDLE_RUNNER_INSTALL_DIR"

    # Clean up files
    rm -f -r "$HOME/IdleRunner.zip" "$HOME/IdleRunner-main"

    # Make IdleRunner.sh executable
    chmod +x "$IDLE_RUNNER_INSTALL_DIR/IdleRunner.sh"
    chmod +x "$IDLE_RUNNER_INSTALL_DIR/IdleRunnerSetup.sh"

    # Run IdleRunnerSetup.sh
    cd "$IDLE_RUNNER_INSTALL_DIR" || exit
    ./IdleRunnerSetup.sh

    # Enter the Boinc directory
    cd "$IDLE_RUNNER_INSTALL_DIR/Boinc" || exit

    # Make BoincInstaller.sh executable
    chmod +x "$IDLE_RUNNER_INSTALL_DIR/Boinc/BoincInstaller.sh"
    chmod +x "$IDLE_RUNNER_INSTALL_DIR/Boinc/TrackBoincWork_Realtime.sh"

    # Run BoincInstaller.sh
    ./BoincInstaller.sh

    # Add aliases to bashrc
    echo "Adding aliases to bashrc..."
    echo "alias trackBoinc='$HOME/IdleRunner/Boinc/TrackBoincWork_Realtime.sh'" >>/etc/bash.bashrc
    echo "alias updateBoincCPUSettings='boinccmd --project https://universeathome.pl/universe/ update'" >>/etc/bash.bashrc

    # Reload bashrc
    source /etc/bash.bashrc

    # View the status of Boinc
    trackBoinc

    # Prompt if the user wants to install Oracle OCI Management agent
    read -rp "Would you like to install Oracle OCI Management agent? (y/n): " decision
    if [[ $decision == "y" ]]; then
        sudo apt install snapd --assume-yes
        sudo snap install oracle-cloud-agent --classic --assume-yes
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
        POCIDFBI_SETUP_CRON=false
        ;;
    d)
        POCIDFBI_TARGET_DIR=$OPTARG
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

echo "Would you like to install POCIDFBI or IDLERUNNER?"
echo "1. POCIDFBI"
echo "2. IDLERUNNER"
read -rp "Enter your choice (1/2): " choice
case $choice in
1)
    install_pocidfbi
    ;;
2)
    install_idlerunner
    ;;
*)
    echo "Invalid choice. Exiting..."
    exit 1
    ;;
esac
