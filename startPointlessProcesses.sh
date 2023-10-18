#!/bin/bash

# Run this script using a "screen" (# apt install screen) ($ man screen)

# Define the lockfile path
LOCKFILE="/tmp/startPointlessProcesses.lock"

# Check if lockfile exists
if [ -e "$LOCKFILE" ]; then
    echo "Another instance of the script is already running. Exiting." >> /home/ubuntu/Prevent-OCI-Deletion-for-being-idle/log/trackPointlessWork.log
    exit 0
fi

# Create lockfile
touch "$LOCKFILE"

# Ensure that lockfile is removed when script exits
trap "rm -f $LOCKFILE" EXIT

# Change directory to the script's directory
cd "$(dirname "$0")" || exit

# Define the log file path
log_file="/home/ubuntu/Prevent-OCI-Deletion-for-being-idle/log/trackPointlessWork.log"

# Function to calculate the current CPU load
get_cpu_load() {
    echo $((100 - $(vmstat 1 2 | tail -1 | awk '{print $15}')))
}

# Log script startup
echo "Starting startPointlessProcesses.sh at $(date). Monitoring CPU Load..." >> "$log_file"

while true; do
    currentCpuLoad=$(get_cpu_load)
    echo "Current CPU Load at $(date): $currentCpuLoad%" >> "$log_file"

    if [ $currentCpuLoad -le 20 ]; then  # Adjusted the threshold to 20% for some buffer
        echo "CPU Load below threshold at $(date). Spawning 5 instances of cpuUser.sh." >> "$log_file"
        
        # Spawn 5 instances of cpuUser.sh concurrently
        for i in {1..5}; do
            /bin/bash cpuUser.sh &
        done
        
        wait  # Wait for all spawned scripts to complete
        
        echo "Completed running cpuUser.sh instances at $(date)." >> "$log_file"
    else
        echo "CPU Load is within acceptable range at $(date). No action taken." >> "$log_file"
    fi
    
    sleep 10  # 10-second delay between checks
done
