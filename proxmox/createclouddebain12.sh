#!/bin/bash

# Set the directory for images
IMAGE_DIR="/var/lib/vz/images"
IMAGE_URL="https://cdimage.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
IMAGE_FILE="${IMAGE_DIR}/debian-12-genericcloud-amd64.qcow2"
SSH_KEY_FILE="${IMAGE_DIR}/id_rsa.pub"

# Check if the cloud image exists, and download it if not
if [ ! -f "$IMAGE_FILE" ]; then
    echo "Debian cloud image not found. Downloading..."
    wget -O "$IMAGE_FILE" "$IMAGE_URL"
else
    echo "Debian cloud image already exists. Skipping download."
fi

# Prompt for VM details
read -p "Enter VM ID: " VM_ID
read -p "Enter VM Name: " VM_NAME
read -p "Enter VM IP Address (e.g., 192.168.2.202/24): " VM_IP
read -p "Enter Gateway (e.g., 192.168.2.1): " VM_GATEWAY

# Create the VM
echo "Creating VM..."
qm create "$VM_ID" --name "$VM_NAME" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0

# Import the disk
echo "Importing disk..."
qm importdisk "$VM_ID" "$IMAGE_FILE" local-lvm

# Configure the VM
echo "Configuring VM..."
qm set "$VM_ID" --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-"$VM_ID"-disk-0
qm set "$VM_ID" --boot c --bootdisk scsi0
qm set "$VM_ID" --ide2 local-lvm:cloudinit

# Check if SSH key exists
if [ ! -f "$SSH_KEY_FILE" ]; then
    echo "SSH key file not found at $SSH_KEY_FILE. Please place it there and rerun."
    exit 1
fi

# Add SSH key and cloud-init configuration
qm set "$VM_ID" --sshkey "$SSH_KEY_FILE"
qm set "$VM_ID" --ciuser root --cipassword "securepassword" --ipconfig0 ip="$VM_IP",gw="$VM_GATEWAY"

# Start the VM
echo "Starting VM..."
qm start "$VM_ID"

echo "VM $VM_NAME with ID $VM_ID has been successfully created and started."

