# Offline Installation of RKE2 (Rancher Kubernetes Engine 2)

This repository provides a script and necessary files for the offline installation of Rancher RKE2 on a Linux system. The installation process is automated using a Bash script that handles the configuration, package installation, and setup of the RKE2 server with Cilium as the Container Network Interface (CNI).

## Prerequisites

- **Linux distribution** with systemd (Debian 12.X).
- **Root access** or sudo privileges.
- **Pre-downloaded installation files** (included in this repository).
- **Internet access is required** for the initial download of files and script but not for installation.

## Files Included

- `config.sh`: The installation script for RKE2.
- `rke2-server.service`: A systemd service file to manage the RKE2 server.
- `rke2-images.linux-amd64.tar.zst`, `rke2.linux-amd64.tar.gz`, `sha256sum-amd64.txt`, `rke2-images-core.linux-amd64.tar.gz`, `rke2-images-cilium.linux-amd64.tar.gz`: Required installation files for RKE2.
- `sources.list`: APT repositories for updating and upgrading the system.

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/offline-rke2-installation.git
cd offline-rke2-installation
