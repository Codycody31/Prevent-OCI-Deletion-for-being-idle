# OCIScripts: Improved

The `OCIScripts` repository has been designed to help users maintain their Oracle Cloud Infrastructure (OCI) ForeverFree tier instances active, following Oracle's policy that could lead to the deletion of instances under certain conditions.

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
   cd prevent_OCI_Deletion_for_being_idle
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
   */10 * * * * /home/ubuntu/prevent_OCI_Deletion_for_being_idle/startPointlessProcesses.sh
   ```

## Monitoring

To keep an eye on the script's activities, you can monitor the log file:

```bash
tail -f /home/ubuntu/prevent_OCI_Deletion_for_being_idle/log/trackPointlessWork.log
```

## Notes

* Adjust the frequency in the crontab entry as per your requirements.
* Monitor your instance's resource usage regularly to ensure it remains within desired parameters.
* Understand that this approach, while effective, can be resource-intensive. Ensure you are within the ethical bounds of Oracle's policy and terms of service.
