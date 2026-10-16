# Proxmox Scripts

Small, focused scripts for common Proxmox administration tasks. Categories will grow as more tools are added.

> Run these commands as `root` on the Proxmox host. Review the scripts and make backups before upgrading production systems.

## Categories

- [Maintenance](#maintenance) — system and container updates
- More categories will be added for tasks such as backups, storage, networking, and virtual-machine management.

## Maintenance

### Update the host

Updates packages, removes unused dependencies, shows the current kernel and root-disk usage, then recommends a reboot.

```bash
curl -fsSL https://raw.githubusercontent.com/krzyyysiek/proxmox/main/scripts/update.sh | bash
```

### Update running LXC containers

Updates every running container and skips stopped ones. It supports APT (Debian/Ubuntu), APK (Alpine), DNF/YUM, and Pacman. When complete, it optionally reboots the containers that updated successfully.

```bash
curl -fsSL https://raw.githubusercontent.com/krzyyysiek/proxmox/main/scripts/CTupdate.sh | bash
```

## Before you run a script

- Check backups and available disk space before upgrades.
- Review update output for failures; the container script exits with an error if any container update fails.
- Reboot the host after host updates when a new kernel or other core components were installed.
