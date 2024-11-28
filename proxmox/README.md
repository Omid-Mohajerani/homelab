## Step 1: Remove the Subscription-Based Repository
Edit the Proxmox sources list to remove the subscription-based repository:

```bash
vim /etc/apt/sources.list.d/pve-enterprise.list
```

## Step 2: Add the No-Subscription Repository

```bash
vim /etc/apt/sources.list.d/pve-no-subscription.list
```

add repo 
```bash
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription
```

## Step 3: Update the Repository and Upgrade Packages

```bash
apt-get update
apt-get dist-upgrade
```
