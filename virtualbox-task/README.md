
# Prometheus Node Exporter Setup Guide

This guide details the step-by-step process of setting up and running the Prometheus Node Exporter within a virtualized environment. This setup allows for the collection of system metrics from a Linux host, which can then be scraped by a Prometheus server.

## Prerequisites

Before you begin, ensure you have the following installed on your host machine:

  * **VirtualBox:** This virtualization software will be used to create and run the virtual machine. You can download the appropriate version for your system (macOS, Windows, Linux) from the official [VirtualBox Downloads](https://www.virtualbox.org/wiki/Downloads) page.
  * **Ubuntu Desktop ISO:** The operating system for our virtual machine. The latest version can be downloaded from the [Ubuntu website](https://ubuntu.com/download/desktop).

-----

## 1\. Virtual Machine (VM) Setup

Follow these steps to create and configure your Ubuntu virtual machine:

1.  **Create a New VM:** Open VirtualBox and create a new virtual machine.

2.  **VM Configuration:**

      * **CPU:** Assign at least **2 CPU cores** to ensure smooth performance.
      * **RAM:** Allocate a minimum of **4 GB of RAM**.
      * **Storage:** Provide at least **25 GB of disk space** for the OS and application files.

3.  **Network Configuration:** Configure the VM's network interface card (NIC) to use **NAT (Network Address Translation)**. This setting allows the VM to access the internet through the host machine's network connection.

4.  **Install Ubuntu:** Mount the downloaded Ubuntu ISO file and complete the installation, setting up a hostname, username, and password as prompted.

5.  **Install Essential Tools:** After the installation is complete, open a terminal in your Ubuntu VM and install essential networking and text editing tools:

    ```bash
    sudo apt update
    sudo apt install -y vim net-tools telnet wget
    ```

-----

## 2\. Prometheus Node Exporter Installation

This section covers the download and setup of the Node Exporter itself.

1.  **Download Node Exporter:** Use `wget` to download the latest version of the Node Exporter for Linux AMD64 from the official GitHub repository.

    ```bash
    wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
    ```

2.  **Extract the Files:** Extract the downloaded compressed archive. This will create a directory containing the `node_exporter` executable.

    ```bash
    tar -xvf node_exporter-1.6.1.linux-amd64.tar.gz
    cd node_exporter-1.6.1.linux-amd64
    ```

3.  **Verify the Executable:** Inside the new directory, you'll find the `node_exporter` binary. You can verify it by running `./node_exporter --version`.

-----

## 3\. Creating the Runner Script

To ensure the Node Exporter runs continuously and restarts automatically if it fails, a simple bash runner script is used.

1.  **Create the Script:** Create a new file named `node_exporter_runner.sh` and add the following content. Make sure to replace `/path/to/node_exporter/directory` with the actual path where you extracted the Node Exporter files.

    ```bash
    #!/bin/bash
    cd /path/to/node_exporter/directory

    while true; do
        echo "Starting node_exporter at $(date)"
        ./node_exporter &> ./node_exporter.log
        echo "node_exporter stopped at $(date). Restarting in 5 seconds..."
        sleep 5
    done
    ```

      * This script runs a **`while` loop** that continuously attempts to start the `node_exporter`.
      * `&> ./node_exporter.log` redirects both **standard output (`stdout`) and standard error (`stderr`)** to the `node_exporter.log` file, ensuring all output is captured for debugging.
      * The `sleep 5` command introduces a 5-second delay before restarting, preventing a rapid, resource-intensive restart loop.

2.  **Create the Log File:** Create an empty log file that the script will use to write output.

    ```bash
    touch node_exporter.log
    ```

-----

## 4\. Finalizing and Running the Setup

The last step is to configure file permissions and run the script.

1.  **Set File Permissions:** It's crucial to make the scripts executable and ensure correct ownership. This prevents "permission denied" errors when you try to run them.

      * Make the runner script executable:
        ```bash
        chmod +x node_exporter_runner.sh
        ```
      * Ensure the executable binary has the correct ownership (typically owned by the user running the script):
        ```bash
        sudo chown your_user:your_group node_exporter
        ```

2.  **Run the Node Exporter Script:** You have a few options for running the script based on your needs:

      * **Foreground:** Runs the script directly in your current terminal session. It will stop when the session is closed.
        ```bash
        ./node_exporter_runner.sh
        ```
      * **Background (using `&`):** Runs the script in the background, freeing up your terminal. It will terminate if the terminal session is closed.
        ```bash
        ./node_exporter_runner.sh &
        ```
      * **Persistent Background (using `nohup`):** The `nohup` command runs the script in a way that it ignores hang-up signals (`SIGHUP`), allowing it to continue running even after you log out of the terminal session. This is ideal for long-term use.
        ```bash
        nohup ./node_exporter_runner.sh &
        ```

Congratulations\! You have successfully set up and configured the Prometheus Node Exporter on your Ubuntu virtual machine. The exporter is now running and ready to be scraped by a Prometheus server, allowing you to monitor your VM's system metrics.
