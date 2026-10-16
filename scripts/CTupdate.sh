#!/usr/bin/env bash

# Update every running Proxmox LXC container, then optionally reboot them.
# Supports APT (Debian/Ubuntu), APK (Alpine), DNF/YUM, and Pacman containers.
set -u
set -o pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run this script as root on the Proxmox host." >&2
    exit 1
fi

mapfile -t containers < <(pct list | awk 'NR > 1 { print $1, $2 }')

if [[ ${#containers[@]} -eq 0 ]]; then
    echo "No containers found."
    exit 0
fi

updated_containers=()
failed_containers=()

for container in "${containers[@]}"; do
    read -r vmid status <<< "$container"

    if [[ $status != "running" ]]; then
        echo "=== CT $vmid: skipped ($status) ==="
        continue
    fi

    echo "=== CT $vmid: updating ==="
    if pct exec "$vmid" -- sh -c '
        if command -v apt-get >/dev/null 2>&1; then
            export DEBIAN_FRONTEND=noninteractive
            apt-get update && apt-get full-upgrade -y && apt-get autoremove -y && apt-get autoclean
        elif command -v apk >/dev/null 2>&1; then
            apk update && apk upgrade
        elif command -v dnf >/dev/null 2>&1; then
            dnf upgrade -y
        elif command -v yum >/dev/null 2>&1; then
            yum update -y
        elif command -v pacman >/dev/null 2>&1; then
            pacman -Syu --noconfirm
        else
            echo "Unsupported package manager: no apt-get, apk, dnf, yum, or pacman found." >&2
            exit 2
        fi
    '; then
        updated_containers+=("$vmid")
        echo "=== CT $vmid: complete ==="
    else
        failed_containers+=("$vmid")
        echo "=== CT $vmid: update failed ===" >&2
    fi
done

echo
if [[ ${#updated_containers[@]} -eq 0 ]]; then
    echo "No running containers were updated."
else
    echo "Successfully updated CTs: ${updated_containers[*]}"

    read -r -p "Reboot all successfully updated CTs? [y/N] " reply
    if [[ $reply =~ ^[Yy]([Ee][Ss])?$ ]]; then
        for vmid in "${updated_containers[@]}"; do
            echo "=== CT $vmid: rebooting ==="
            pct reboot "$vmid" || echo "CT $vmid could not be rebooted." >&2
        done
    else
        echo "Containers were not rebooted."
    fi
fi

if [[ ${#failed_containers[@]} -gt 0 ]]; then
    echo "Updates failed for CTs: ${failed_containers[*]}" >&2
    exit 1
fi
