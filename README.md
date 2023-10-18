# OCIScripts: Improved

The `OCIScripts` repository has been designed to help users maintain their Oracle Cloud Infrastructure (OCI) ForeverFree tier instances active, following Oracle's policy that could lead to the deletion of instances under certain conditions.

## Acknowledgment

This project has been improved upon and expanded from the original work found at [OCIScripts by Drag-NDrop](https://github.com/Drag-NDrop/OCIScripts). We express our gratitude to the original author for their initiative and groundwork.

While the current repository contains modifications, optimizations, and extensions to the original work, the foundational ideas and script mechanisms are attributed to the source mentioned above. We encourage users and contributors to refer to the original repository to understand the context and motivation that led to the inception of these scripts.

## Why This Script?

Oracle may delete your ForeverFree tier instance if, during a 7-day period, the following criteria are met:

* CPU utilization for the 95th percentile is less than 10%.
* Network utilization is less than 10%.
* Memory utilization is less than 10% (applies to A1 shapes only).

The purpose of these scripts is to ensure that the instance remains within Oracle's usage guidelines without manual intervention. While this approach is practical, it is crucial to understand the ethical and environmental implications of such a strategy. We encourage users to only deploy this solution if absolutely necessary.

## Scripts Description

1. **cpuUser.sh** - This is the CPU "waster" script, designed to produce computational work.
2. **startPointlessProcesses.sh** - This script acts as the "manager". It monitors the CPU usage and spawns instances of `cpuUser.sh` if the usage falls below a certain threshold.
3. **cron instructions** - Guidelines to set up a scheduled task using crontab to automate the process.

## Setup & Usage

1. Clone the repository:

   ```bash
   git clone Codycody31/Prevent-OCI-Deletion-for-being-idle
   ```

2. Navigate to the repository directory:

   ```bash
   cd Prevent-OCI-Deletion-for-being-idle
   ```

3. Ensure the scripts have execute permissions:

   ```bash
   chmod +x *.sh
   ```

4. Edit your crontab:

   ```bash
   crontab -e
   ```

5. Add the following line to run the script every 10 minutes and log the output:

   ```bash
   */10 * * * * /home/ubuntu/Prevent-OCI-Deletion-for-being-idle/startPointlessProcesses.sh
   ```

## Monitoring

To keep an eye on the script's activities, you can monitor the log file:

```bash
tail -f /home/ubuntu/Prevent-OCI-Deletion-for-being-idle/log/trackPointlessWork.log
```

## Why and How of the Script Strategy

**1. Why Use `cpuUser.sh`?**

The `cpuUser.sh` script is designed to generate computational work. The script produces random numbers and writes them to `/dev/null`, which means the numbers are discarded immediately. This activity creates a CPU workload without having any lasting effect on storage or other system resources.

**2. Why Monitor with `startPointlessProcesses.sh`?**

Instead of blindly running the CPU waster script continuously, it's more efficient to monitor the system and only generate extra CPU work when it's needed. The `startPointlessProcesses.sh` script acts as a manager, checking the current CPU workload and deciding whether to activate the `cpuUser.sh` script.

## Modifying the Manager Script

To control the CPU usage, you might want to adjust the manager script. Here's a breakdown of its logic and where you can make modifications:

* **Threshold of Activation**:
  The line

  ```bash
  if [ $currentCpuLoad -le 20 ]
  ```

  determines when to activate the CPU waster script. Here, it activates if CPU load is less than or equal to 20%. If you wish to change this threshold, modify the number `20` to your desired value.

* **Measuring CPU Load**:
  The line

  ```bash
  currentCpuLoad=$[100-$(vmstat 1 2|tail -1|awk '{print $15}')]
  ```

  uses `vmstat` to get system statistics. The value derived represents the CPU idle time, which is then subtracted from 100 to get the actual CPU load. If you are familiar with other system monitoring tools or commands and wish to use them, you can replace this line with an appropriate command that returns the current CPU load.

* **Logging Information**:
  You can add more detailed logging by modifying the `echo` statements in the script. For example, you can add:

  ```bash
  echo "Script activated at $(date) due to low CPU load." >> /home/ubuntu/Prevent-OCI-Deletion-for-being-idle/log/trackPointlessWork.log
  ```

## Tips

* If you are uncertain about the effect of changes you make, test them in a controlled environment before deploying them on your main instance.
  
* It's a good practice to keep an eye on the system's behavior after making adjustments to ensure it behaves as expected. Tools like `top` or `htop` can be valuable in real-time monitoring.

## Notes

* Adjust the frequency in the crontab entry as per your requirements.
* Monitor your instance's resource usage regularly to ensure it remains within desired parameters.
* Understand that this approach, while effective, can be resource-intensive. Ensure you are within the ethical bounds of Oracle's policy and terms of service.
