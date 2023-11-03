#!/bin/bash

# Get the directory of the script itself
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Define the log file path
LOG_DIR="$SCRIPT_DIR/log"
LOG_FILE="$LOG_DIR/POCIDFBITrack.log"

# Default values
WORKER_COUNT=5
CPU_THRESHOLD=20
LOGGING_ENABLED=true
DURATION_BETWEEN_CHECKS=10 # In seconds

# Configuration file path
CONFIG_FILE="$SCRIPT_DIR/config.conf"

# Function to validate if the provided input is a number
is_number() {
    local num="$1"
    # Use regex to check if the input is a number
    [[ $num =~ ^[0-9]+$ ]]
}

# Read from configuration file if it exists
if [ -f "$CONFIG_FILE" ]; then
    WORKER_COUNT=$(grep "^WORKER_COUNT=" "$CONFIG_FILE" | cut -d'=' -f2)
    CPU_THRESHOLD=$(grep "^CPU_THRESHOLD=" "$CONFIG_FILE" | cut -d'=' -f2)
    LOGGING_ENABLED=$(grep "^LOGGING_ENABLED=" "$CONFIG_FILE" | cut -d'=' -f2)
    DURATION_BETWEEN_CHECKS=$(grep "^DURATION_BETWEEN_CHECKS=" "$CONFIG_FILE" | cut -d'=' -f2)
fi

# Welcome message
echo "Welcome to the POCIDFBI configuration script!"
echo "Please answer the following questions to configure the script."

# Worker count
read -rp "Enter the worker count (Default: $WORKER_COUNT): " input
if is_number "$input"; then
    WORKER_COUNT=$input
fi

# CPU threshold
read -rp "Enter the CPU threshold (Default: $CPU_THRESHOLD): " input
if is_number "$input"; then
    CPU_THRESHOLD=$input
fi

# Enable logging to the log file?
read -rp "Enable logging to the log file? (Default: $LOGGING_ENABLED) [y/N]: " input
if [[ $input =~ ^[Yy]$ ]]; then
    LOGGING_ENABLED=true
else
    LOGGING_ENABLED=false
fi

# Duration between checks
read -rp "Enter the duration between checks (Default: $DURATION_BETWEEN_CHECKS): " input
if is_number "$input"; then
    DURATION_BETWEEN_CHECKS=$input
fi

# Write to configuration file
echo "WORKER_COUNT=$WORKER_COUNT" >"$CONFIG_FILE"
echo "CPU_THRESHOLD=$CPU_THRESHOLD" >>"$CONFIG_FILE"
echo "LOGGING_ENABLED=$LOGGING_ENABLED" >>"$CONFIG_FILE"
echo "DURATION_BETWEEN_CHECKS=$DURATION_BETWEEN_CHECKS" >>"$CONFIG_FILE"

# Display the configuration
echo "Configuration:"
echo "Worker count: $WORKER_COUNT"
echo "CPU threshold: $CPU_THRESHOLD"
echo "Logging enabled: $LOGGING_ENABLED"
echo "Duration between checks: $DURATION_BETWEEN_CHECKS"

# Kill all running instances of POCIDFBIManager.sh
echo "Killing all running instances of POCIDFBIManager.sh..."
pkill -f POCIDFBIManager.sh

# Finish message
echo "Configuration complete!"
