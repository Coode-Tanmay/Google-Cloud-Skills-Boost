# GSP211 - Multiple VPC Networks

Google Cloud Skills Boost lab: **Multiple VPC Networks**

**Lab ID:** GSP211

This folder contains an automation script for completing the main resource-creation tasks of the GSP211 lab using Google Cloud Shell.

## 📋 Lab Overview

This lab covers:

- Creating custom VPC networks
- Creating VPC subnets
- Creating firewall rules
- Creating Compute Engine VM instances
- Testing connectivity between VMs
- Creating a VM with multiple network interfaces
- Exploring VPC routing and connectivity

## 📁 Files

| File | Description |
|------|-------------|
| `GSP211.sh` | Bash script that creates the required Google Cloud resources |

## ⚠️ Before Running the Script

This script is designed for a **Google Cloud Skills Boost temporary lab project**.

Make sure you have:

- Started the GSP211 lab
- Opened Google Cloud Shell
- Authenticated with the temporary Skills Boost account
- Selected the temporary lab project
- Not already created the resources manually

Check your active project:

```bash
gcloud config get-value project
