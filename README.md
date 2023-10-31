# Prevent OCI Deletion for being idle

<div align="center">

[![Version](https://img.shields.io/github/v/release/Codycody31/Prevent-OCI-Deletion-for-being-idle)](https://github.com/Codycody31/Prevent-OCI-Deletion-for-being-idle/releases/)
[![Discord](https://img.shields.io/discord/1166016207816757248?color=7289da&label=Discord&logo=discord&logoColor=white)](https://discord.gg/HRNVF5Tf9a)
[![License](https://img.shields.io/github/license/Codycody31/Prevent-OCI-Deletion-for-being-idle)](LICENSE)

</div>

The `Prevent-OCI-Deletion-for-being-idle` repository has been designed to help users maintain their Oracle Cloud Infrastructure (OCI) ForeverFree tier instances active, following Oracle's policy that could lead to the deletion of instances under certain conditions.

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

1. **workers/WasteCPUWorker.sh** - This is the CPU "waster" script, designed to produce computational work.
2. **POCIDFBIManager.sh** - This script acts as the "manager". It monitors the CPU usage and spawns instances of `WasteCPUWorker.sh` if the usage falls below a certain threshold.

## Configuration

Before you set up and run the scripts, you may want to configure the worker count and CPU threshold to fit your needs. There are two primary ways to configure these parameters:

### 1. Command Line Interface (CLI)

You can directly pass these values when running the manager script (`POCIDFBIManager.sh`) using the `-w`, `-n` and `-c` options.

```bash
./POCIDFBIManager.sh -w [WORKER_COUNT] -c [CPU_THRESHOLD] -n -d [DURATION_BETWEEN_CHECKS]
```

Replace `[WORKER_COUNT]` with the desired number of worker instances and `[CPU_THRESHOLD]` with the desired CPU usage threshold (as a percentage) below which the worker script should be invoked. `-n` is a flag used to disable logging, when applied disables logging to a file. `-d` is a flag used to set the duration between checks, the default is 10 seconds.

**Example**:

```bash
./POCIDFBIManager.sh -w 5 -c 20 -n -d 10
```

This command runs the manager script with a worker count of 5 and a CPU threshold of 20% (i.e., if CPU usage falls below 20%, the worker script will be invoked). The worker script used is `WasteCPUWorker.sh`. The `-n` flag disables logging, and the `-d` flag sets the duration between checks to 10 seconds.

### 2. Configuration File (`config.conf`)

Alternatively, you can use the provided `config.conf` file to set default values for the worker count and CPU threshold. This approach is beneficial if you don't want to provide these values every time you run the script.

Open `config.conf` in your favorite text editor:

```bash
nano config.conf
```

And then set your desired values:

```bash
WORKER_COUNT=5
CPU_THRESHOLD=20
LOGGING_ENABLED=true
DURATION_BETWEEN_CHECKS=10
```

Save the file and exit the editor. Now, when you run the manager script without CLI arguments, it will use these values from `config.conf`. An important thing to note, is that once the manager is started it will only grab the settings once. If you change the settings in `config.conf` you will need to restart the manager script.

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

5. Add the following line to run the script every minute and log the output:

   ```bash
   * * * * * /bin/bash  $HOME/Prevent-OCI-Deletion-for-being-idle/POCIDFBIManager.sh
   ```

## Automated Setup

For a quick and easy setup, you can run the following one-liner which fetches the `install.sh` script from the repository and executes it:

```bash
curl -fsSL https://raw.githubusercontent.com/Codycody31/Prevent-OCI-Deletion-for-being-idle/stable/install.sh | bash
```

Upon running the above command, the script will be set up to trigger every minute via `crontab`. You can verify this by running `crontab -l` and checking for the following line:

```bash
* * * * * /bin/bash  $HOME/Prevent-OCI-Deletion-for-being-idle/POCIDFBIManager.sh
```

## Why and How of the Script Strategy

**1. Why Use `WasteCPUWorker.sh`?**

The `WasteCPUWorker.sh` script is designed to generate computational work. The script produces random numbers and writes them to `/dev/null`, which means the numbers are discarded immediately. This activity creates a CPU workload without having any lasting effect on storage or other system resources.

**2. Why Monitor with `POCIDFBIManager.sh`?**

Instead of blindly running the CPU waster script continuously, it's more efficient to monitor the system and only generate extra CPU work when it's needed. The `POCIDFBIManager.sh` script acts as a manager, checking the current CPU workload and deciding whether to activate the waste worker scripts.

## Modifying the Manager Script

To control the CPU usage, you might want to adjust the manager script. Here's a breakdown of its logic and where you can make modifications:

* **Threshold of Activation**:
  The line

  ```bash
  if [ "$currentCpuLoad" -le "$CPU_THRESHOLD" ]
  ```

  determines when to activate the CPU waster script. Here, it activates if CPU load is less than or equal to 20% (the default value). You can change this value to suit your needs. Via the CLI, you can use the `-c` option to set this value. If you are using the configuration file, you can set the `CPU_THRESHOLD` variable to your desired value.

* **Measuring CPU Load**:
  The line

  ```bash
  currentCpuLoad=$[100-$(vmstat 1 2|tail -1|awk '{print $15}')]
  ```

  uses `vmstat` to get system statistics. The value derived represents the CPU idle time, which is then subtracted from 100 to get the actual CPU load. If you are familiar with other system monitoring tools or commands and wish to use them, you can replace this line with an appropriate command that returns the current CPU load.

* **Logging Information**:
  You can add more detailed logging by adding `log` commands to the script. For example, if you want to log the time when the script activates, you can add the following line:

  ```bash
  log "Script activated at $(date) due to low CPU load."
  ```

## Troubleshooting: Stopping Rogue Script Instances

If you've disabled the script from executing via `crontab`, but notice that the script (or its associated processes) are still consuming excessive CPU resources, it's possible that some instances of the script or its children are still running. Here's how you can identify and terminate such processes:

### Identifying Running Scripts

1. **Check for the manager script** (`POCIDFBIManager.sh`):

   ```bash
   pgrep -f POCIDFBIManager.sh
   ```

   This will display the process IDs of any instances of `POCIDFBIManager.sh` that are currently active.

2. **Inspect for the CPU wastage script** (`WasteCPUWorker.sh`):

   ```bash
   pgrep -f WasteCPUWorker.sh
   ```

   If this script is active, you'll see its process IDs.

### Terminating the Scripts

1. **Terminate `POCIDFBIManager.sh` instances**:

   ```bash
   pkill -f POCIDFBIManager.sh
   ```

2. **Terminate `WasteCPUWorker.sh` instances**:

   ```bash
   pkill -f WasteCPUWorker.sh
   ```

### Verification

After initiating the kill commands:

1. **Recheck for `POCIDFBIManager.sh`**:

   ```bash
   pgrep -f POCIDFBIManager.sh
   ```

   Ensure no process IDs are listed. If there are, manually terminate them:

   ```bash
   kill -9 <PID>
   ```

   Replace `<PID>` with the lingering process ID.

2. **Recheck for `WasteCPUWorker.sh`**:

   ```bash
   pgrep -f WasteCPUWorker.sh
   ```

### Monitoring

Once you've ensured that the unwanted processes are terminated:

* **Monitor the system's CPU usage** with tools such as `top` or `htop` to confirm that CPU utilization is back to normal.

> **Caution**: Always exercise caution when using the `kill` command, especially with the `-9` option. It forcibly terminates processes and can inadvertently affect essential system processes if misused.

## Platform Compatibility

These scripts have been specifically designed and tested on Ubuntu 22.04 instances. Before using them, ensure you are running an instance with Ubuntu 22.04, as the commands, package references, and script behaviors might differ in other distributions or versions.

If you are interested in adapting these scripts for other operating systems, distributions, or different Ubuntu versions, you might need to adjust command syntax, package management commands, and potentially other system-specific details.

## Tips

* If you are uncertain about the effect of changes you make, test them in a controlled environment before deploying them on your main instance.
  
* It's a good practice to keep an eye on the system's behavior after making adjustments to ensure it behaves as expected. Tools like `top` or `htop` can be valuable in real-time monitoring.

## Notes

* Adjust the frequency in the crontab entry as per your requirements.
* Monitor your instance's resource usage regularly to ensure it remains within desired parameters.
* Understand that this approach, while effective, can be resource-intensive. Ensure you are within the ethical bounds of Oracle's policy and terms of service.

## Disclaimer

The code and scripts provided in this repository are the independent work of Codycody31 and are not endorsed, certified, or otherwise affiliated with VMG Ware. While Codycody31 is a member of VMG Ware, it is important to note that no VMG Ware resources were used in the creation of this repository, and it does not represent the views or policies of VMG Ware.

Users are responsible for understanding the implications and ensuring that their use of these scripts aligns with Oracle's terms of service, as well as other ethical and legal considerations. Always exercise caution and discretion when using third-party scripts, and seek appropriate legal counsel if unsure.
