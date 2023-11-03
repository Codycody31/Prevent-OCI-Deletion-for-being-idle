#!/bin/bash

# Display a welcome message with a border for visual appeal
printf "\n"
echo -e "================================================="
echo "     Welcome to the POCIDFBI Configuration Script     "
echo "================================================="
printf "\n"

# Get the directory of the script itself
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

# Define the log file path
LOG_DIR="$SCRIPT_DIR/log"
LOG_FILE="$LOG_DIR/POCIDFBITrack.log"

# Default configuration values
WORKER_COUNT=5
CPU_THRESHOLD=20
LOGGING_ENABLED=true
DURATION_BETWEEN_CHECKS=10 # In seconds

# Configuration file path
CONFIG_FILE="$SCRIPT_DIR/config.conf"

# Function to check if input is a number
is_number() {
  local num="$1"
  # Use regex to check if input is a number
  [[ $num =~ ^[0-9]+$ ]]
}

# Attempt to read the existing configuration file
if [ -f "$CONFIG_FILE" ]; then
  WORKER_COUNT=$(grep "^WORKER_COUNT=" "$CONFIG_FILE" | cut -d'=' -f2)
  CPU_THRESHOLD=$(grep "^CPU_THRESHOLD=" "$CONFIG_FILE" | cut -d'=' -f2)
  LOGGING_ENABLED=$(grep "^LOGGING_ENABLED=" "$CONFIG_FILE" | cut -d'=' -f2)
  DURATION_BETWEEN_CHECKS=$(grep "^DURATION_BETWEEN_CHECKS=" "$CONFIG_FILE" | cut -d'=' -f2)
fi

# Display the current configuration
echo -e "Current Configuration:"
printf "\n"
echo "  Worker Count: $WORKER_COUNT"
echo "  CPU Threshold: $CPU_THRESHOLD"
echo "  Logging: $([[ $LOGGING_ENABLED == true ]] && echo "Enabled" || echo "Disabled")"
echo "  Duration Between Checks: ${DURATION_BETWEEN_CHECKS}s"
printf "\n"
echo "-------------------------------------------------"
printf "\n"

# Prompt user for new configurations
echo "Please enter new values or press ENTER to keep the current settings."

# Worker count
read -rp "Worker Count [$WORKER_COUNT]: " input
if is_number "$input"; then
  WORKER_COUNT=$input
fi

# CPU threshold
read -rp "CPU Threshold [$CPU_THRESHOLD]: " input
if is_number "$input"; then
  CPU_THRESHOLD=$input
fi

# Logging option
read -rp "Enable Logging? [$([[ $LOGGING_ENABLED == true ]] && echo "Y/n" || echo "y/N")]: " input
if [[ $input =~ ^[Yy]$ ]]; then
  LOGGING_ENABLED=true
elif [[ $input =~ ^[Nn]$ ]]; then
  LOGGING_ENABLED=false
fi

# Duration between checks
read -rp "Duration Between Checks (in seconds) [$DURATION_BETWEEN_CHECKS]: " input
if is_number "$input"; then
  DURATION_BETWEEN_CHECKS=$input
fi

# Write new configuration to file
{
  echo "WORKER_COUNT=$WORKER_COUNT"
  echo "CPU_THRESHOLD=$CPU_THRESHOLD"
  echo "LOGGING_ENABLED=$LOGGING_ENABLED"
  echo "DURATION_BETWEEN_CHECKS=$DURATION_BETWEEN_CHECKS"
} >"$CONFIG_FILE"

echo -e "================================================="

# Display the new configuration
printf "\n"
echo -e "Updated Configuration:"
printf "\n"
echo "  Worker Count: $WORKER_COUNT"
echo "  CPU Threshold: $CPU_THRESHOLD"
echo "  Logging: $([[ $LOGGING_ENABLED == true ]] && echo "Enabled" || echo "Disabled")"
echo "  Duration Between Checks: ${DURATION_BETWEEN_CHECKS}s"
printf "\n"
echo "-------------------------------------------------"
printf "\n"
echo "Configuration saved to $CONFIG_FILE"
printf "\n\n"

# Terminate running instances of POCIDFBIManager.sh
echo "Terminating all running instances of POCIDFBIManager.sh..."
printf "\n"
pkill -f POCIDFBIManager.sh

# Completion message with a border for visual appeal
echo -e "================================================="
echo "     Configuration Complete! Exiting now.         "
echo "================================================="
printf "\n"
