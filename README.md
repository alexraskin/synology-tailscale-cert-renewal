# Tailscale Certificate Automation Script for Synology DSM

This script automates the generation and renewal of Tailscale certificates on a Synology DSM. It ensures that the certificates are up-to-date and will regenerate them if they are about to expire soon.
Inspiration

This script was inspired by the [Medium article by Walid Karray on automating Tailscale](https://medium.com/@walid.karray/automating-tailscale-certificate-configuration-on-synology-dsm-8a3c3b79e010) certificate configuration on Synology DSM.

## Prerequisites

- Synology DSM with root access.
- Tailscale installed and configured.
- OpenSSL installed.

## Features

- Checks if the existing Tailscale certificate is about to expire (within 30 days).
- Automatically generates and installs a new certificate if necessary.
- Restarts the Synology web server to apply the new certificate.

## Usage

There are two ways to use this script:

1. Enable the Task Scheduler in DSM and create a new task that runs the script at a specific interval.
- Open the Task Scheduler in DSM.
- Click on Create > Scheduled Task > User-defined script.
- Enter a name for the task.
- Select the root user.
- Set the schedule to run the script at a specific interval (e.g., every week).
- In the Task Settings tab, enter the following command in the Run command field:
```
/path/to/tailscale-certificate.sh
```
- Click OK to save the task.

2. Run the script manually whenever you want to check and renew the Tailscale certificate.
- Open a terminal on your Synology DSM.
- Run the following command to make the script executable:
```
chmod +x /path/to/tailscale-certificate.sh
```
- Run the script using the following command:
```
sudo ./tailscale-certificate.sh
```

## License

This script is open-source and available for use and modification under the MIT License.


## Acknowledgments

[Walid Karray](https://medium.com/@walid.karray) for his detailed article on automating Tailscale certificate configuration on Synology DSM.