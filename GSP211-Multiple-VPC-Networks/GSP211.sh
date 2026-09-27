#!/bin/bash

# ============================================================
# Google Cloud Skills Boost - GSP211
# Multiple VPC Networks
# ============================================================

set -e

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

VM1="mynet-vm-1"
VM2="mynet-vm-2"

MANAGEMENT_NETWORK="managementnet"
MANAGEMENT_SUBNET="managementsubnet-1"
MANAGEMENT_RANGE="10.130.0.0/20"

PRIVATE_NETWORK="privatenet"
PRIVATE_SUBNET_1="privatesubnet-1"
PRIVATE_RANGE_1="172.16.0.0/24"

PRIVATE_SUBNET_2="privatesubnet-2"
PRIVATE_RANGE_2="172.20.0.0/20"

# ------------------------------------------------------------
# Detect zones and regions from the lab-created VMs
# ------------------------------------------------------------

echo "Detecting lab VM zones..."

ZONE_1=$(gcloud compute instances describe "$VM1" \
    --format='value(zone)' 2>/dev/null | awk -F/ '{print $NF}')

ZONE_2=$(gcloud compute instances describe "$VM2" \
    --format='value(zone)' 2>/dev/null | awk -F/ '{print $NF}')

if [[ -z "$ZONE_1" || -z "$ZONE_2" ]]; then
    echo "ERROR: Could not find $VM1 or $VM2."
    echo "Make sure the GSP211 lab has been started and the lab-created VMs exist."
    exit 1
fi

REGION_1="${ZONE_1%-*}"
REGION_2="${ZONE_2%-*}"

echo "VM 1: $VM1"
echo "Zone 1: $ZONE_1"
echo "Region 1: $REGION_1"
echo
echo "VM 2: $VM2"
echo "Zone 2: $ZONE_2"
echo "Region 2: $REGION_2"
echo

# ------------------------------------------------------------
# Task 1 - Create managementnet
# ------------------------------------------------------------

echo "Creating managementnet..."

gcloud compute networks create "$MANAGEMENT_NETWORK" \
    --subnet-mode=custom

gcloud compute networks subnets create "$MANAGEMENT_SUBNET" \
    --network="$MANAGEMENT_NETWORK" \
    --region="$REGION_1" \
    --range="$MANAGEMENT_RANGE"

# ------------------------------------------------------------
# Task 1 - Create privatenet
# ------------------------------------------------------------

echo "Creating privatenet..."

gcloud compute networks create "$PRIVATE_NETWORK" \
    --subnet-mode=custom

gcloud compute networks subnets create "$PRIVATE_SUBNET_1" \
    --network="$PRIVATE_NETWORK" \
    --region="$REGION_1" \
    --range="$PRIVATE_RANGE_1"

gcloud compute networks subnets create "$PRIVATE_SUBNET_2" \
    --network="$PRIVATE_NETWORK" \
    --region="$REGION_2" \
    --range="$PRIVATE_RANGE_2"

# ------------------------------------------------------------
# Task 1 - Firewall rules
# ------------------------------------------------------------

echo "Creating firewall rules..."

gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp \
    --direction=INGRESS \
    --priority=1000 \
    --network="$MANAGEMENT_NETWORK" \
    --action=ALLOW \
    --rules=icmp,tcp:22,tcp:3389 \
    --source-ranges=0.0.0.0/0

gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp \
    --direction=INGRESS \
    --priority=1000 \
    --network="$PRIVATE_NETWORK" \
    --action=ALLOW \
    --rules=icmp,tcp:22,tcp:3389 \
    --source-ranges=0.0.0.0/0

# ------------------------------------------------------------
# Task 2 - Create VM instances
# ------------------------------------------------------------

echo "Creating managementnet-vm-1..."

gcloud compute instances create managementnet-vm-1 \
    --zone="$ZONE_1" \
    --machine-type=e2-micro \
    --subnet="$MANAGEMENT_SUBNET"

echo "Creating privatenet-vm-1..."

gcloud compute instances create privatenet-vm-1 \
    --zone="$ZONE_1" \
    --machine-type=e2-micro \
    --subnet="$PRIVATE_SUBNET_1"

# ------------------------------------------------------------
# Task 4 - Create multi-NIC VM
# ------------------------------------------------------------

echo "Creating vm-appliance..."

gcloud compute instances create vm-appliance \
    --zone="$ZONE_1" \
    --machine-type=e2-standard-4 \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet="$PRIVATE_SUBNET_1" \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet="$MANAGEMENT_SUBNET" \
    --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=mynetwork

# ------------------------------------------------------------
# Completion
# ------------------------------------------------------------

echo
echo "============================================================"
echo "GSP211 resource creation completed successfully!"
echo "============================================================"
echo
echo "Next steps:"
echo "1. Click Check my progress in the lab."
echo "2. Complete the connectivity tests."
echo "3. Verify vm-appliance network interfaces."
echo "4. Run 'sudo ifconfig' and 'ip route' when required."
