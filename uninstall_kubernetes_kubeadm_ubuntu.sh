#!/usr/bin/env bash
# Uninstall Kubernetes (kubeadm, kubelet, kubectl) and revert system changes on Ubuntu
# Removes all components, config, data, and apt sources
# Usage: sudo bash uninstall_kubernetes_kubeadm_ubuntu.sh

set -euo pipefail

log() { echo -e "\e[32m[INFO]\e[0m $*"; }
warn() { echo -e "\e[33m[WARN]\e[0m $*"; }
err() { echo -e "\e[31m[ERROR]\e[0m $*" >&2; }

if [[ $EUID -ne 0 ]]; then
  err "This script must be run as root. Use: sudo bash $0"; exit 1;
fi

log "Stopping kubelet and containerd..."
systemctl stop kubelet || true
systemctl disable kubelet || true
systemctl stop containerd || true
systemctl disable containerd || true

log "Removing Kubernetes packages..."
apt-mark unhold kubelet kubeadm kubectl || true
apt-get purge -y kubelet kubeadm kubectl kubernetes-cni cri-tools || true
apt-get autoremove -y

log "Removing containerd and Docker packages (if present)..."
apt-get purge -y containerd containerd.io docker-ce docker-ce-cli || true
apt-get autoremove -y

log "Deleting Kubernetes and containerd config/data directories..."
rm -rf /etc/kubernetes /var/lib/kubelet /var/lib/etcd /etc/containerd /var/lib/containerd /var/lib/calico /etc/cni /opt/cni /var/lib/cni /etc/crictl.yaml

log "Removing Kubernetes apt sources and keyrings..."
rm -f /etc/apt/sources.list.d/kubernetes.list
rm -f /usr/share/keyrings/kubernetes-archive-keyring.gpg
rm -f /etc/apt/sources.list.d/docker.list
rm -f /usr/share/keyrings/docker.gpg
apt-get update

log "Reverting sysctl and kernel module changes..."
rm -f /etc/modules-load.d/k8s.conf /etc/sysctl.d/99-kubernetes-cri.conf
sysctl --system >/dev/null

log "Re-enabling swap if previously disabled..."
if grep -Eqs '^#.*\sswap\s' /etc/fstab; then
  cp -a /etc/fstab "/etc/fstab.bak.$(date +%s)"
  sed -ri 's/^# (.*\sswap\s.*)$/\1/g' /etc/fstab
fi
swapon -a || true

log "Uninstall complete. Kubernetes and related components have been removed."
log "You may need to reboot to fully revert all changes."


sudo umount -l /var/lib/kubelet/pods/*/volumes/kubernetes.io~projected/*
sudo rm -rf /var/lib/kubelet