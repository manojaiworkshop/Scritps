#!/usr/bin/env bash
# Production-grade Kubernetes setup for Ubuntu using kubeadm
# - Sets up containerd (systemd cgroups)
# - Configures kernel modules and sysctl
# - Disables swap
# - Installs kubelet, kubeadm, kubectl from pkgs.k8s.io
# - Holds Kubernetes packages to prevent unintended upgrades
#
# Usage:
#   sudo bash install_kubernetes_kubeadm_ubuntu.sh [--k8s-version v1.30] [--containerd-version 1.7.20]
#   sudo bash install_kubernetes_kubeadm_ubuntu.sh --control-plane  # also prints init/join guidance
#
# Tested on Ubuntu 20.04/22.04/24.04 (amd64)

set -euo pipefail

# -------- Configurable defaults --------
K8S_SERIES="v1.30"        # Stable series from pkgs.k8s.io (e.g., v1.28, v1.29, v1.30)
CONTAINERD_VERSION=""      # Empty = install distro package; or set e.g. 1.7.20
DO_CONTROL_PLANE=false

# -------- Helpers --------
log() { echo -e "\e[32m[INFO]\e[0m $*"; }
warn() { echo -e "\e[33m[WARN]\e[0m $*"; }
err() { echo -e "\e[31m[ERROR]\e[0m $*" >&2; }
cmd_exists() { command -v "$1" >/dev/null 2>&1; }

# -------- Parse args --------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --k8s-version)
      K8S_SERIES="$2"; shift 2;;
    --containerd-version)
      CONTAINERD_VERSION="$2"; shift 2;;
    --control-plane)
      DO_CONTROL_PLANE=true; shift;;
    -h|--help)
      grep -E "^# (Usage|Tested| - | Usage:)" "$0" | sed 's/^# //'; exit 0;;
    *) warn "Unknown argument: $1"; shift;;
  esac
done

# -------- Preflight checks --------
if [[ $EUID -ne 0 ]]; then
  err "This script must be run as root. Use: sudo bash $0"; exit 1;
fi

if ! grep -E -q 'Ubuntu' /etc/os-release; then
  warn "Non-Ubuntu OS detected. Proceeding, but this is designed for Ubuntu."
fi

ARCH=$(dpkg --print-architecture)
if [[ "$ARCH" != "amd64" && "$ARCH" != "arm64" ]]; then
  warn "Architecture $ARCH not explicitly tested. Proceeding."
fi

# -------- Update base packages --------
log "Updating apt and installing prerequisites..."
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  apt-transport-https ca-certificates curl gpg lsb-release software-properties-common

# -------- Disable swap (required by kubelet) --------
log "Disabling swap..."
swapoff -a || true
# Comment out any swap entries in /etc/fstab to keep it disabled after reboot
if grep -Eqs '^[^#].*\sswap\s' /etc/fstab; then
  cp -a /etc/fstab "/etc/fstab.bak.$(date +%s)"
  sed -ri 's/^([^#].*\sswap\s.*)$/# \1/g' /etc/fstab
fi

# -------- Kernel modules and sysctl for Kubernetes networking --------
log "Configuring kernel modules and sysctl..."
cat >/etc/modules-load.d/k8s.conf <<'EOF'
overlay
br_netfilter
EOF

modprobe overlay || true
modprobe br_netfilter || true

cat >/etc/sysctl.d/99-kubernetes-cri.conf <<'EOF'
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system >/dev/null

# -------- Install and configure containerd --------
install_containerd() {
  log "Installing containerd..."
  if [[ -n "${CONTAINERD_VERSION}" ]]; then
    # Install specific containerd from upstream if requested
    # Uses official docker apt repo for containerd.io package
    if ! apt-cache policy | grep -q "download.docker.com"; then
      log "Adding Docker apt repo for containerd.io..."
      install -m 0755 -d /etc/apt/keyrings
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
      chmod a+r /etc/apt/keyrings/docker.gpg
      . /etc/os-release
      echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $VERSION_CODENAME stable" \
      > /etc/apt/sources.list.d/docker.list
      apt-get update -y
    fi
    apt-get install -y containerd.io="${CONTAINERD_VERSION}"* || {
      warn "Specific containerd version ${CONTAINERD_VERSION} not found; installing latest available."
      apt-get install -y containerd.io
    }
  else
    # Use distro containerd if available, else containerd.io
    if apt-cache show containerd >/dev/null 2>&1; then
      apt-get install -y containerd
    else
      if ! apt-cache policy | grep -q "download.docker.com"; then
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg
        . /etc/os-release
        echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $VERSION_CODENAME stable" \
        > /etc/apt/sources.list.d/docker.list
        apt-get update -y
      fi
      apt-get install -y containerd.io
    fi
  fi

  # Generate default config and set SystemdCgroup = true
  mkdir -p /etc/containerd
  containerd config default >/etc/containerd/config.toml || true
  sed -ri 's|^(\s*SystemdCgroup\s*=\s*)false|\1true|' /etc/containerd/config.toml

  systemctl enable --now containerd
  log "containerd installed and configured with SystemdCgroup=true."
}

if ! cmd_exists containerd; then
  install_containerd
else
  log "containerd already installed. Ensuring SystemdCgroup=true..."
  if [[ -f /etc/containerd/config.toml ]]; then
    sed -ri 's|^(\s*SystemdCgroup\s*=\s*)false|\1true|' /etc/containerd/config.toml || true
  else
    mkdir -p /etc/containerd
    containerd config default >/etc/containerd/config.toml || true
    sed -ri 's|^(\s*SystemdCgroup\s*=\s*)false|\1true|' /etc/containerd/config.toml || true
  fi
  systemctl restart containerd
fi

# -------- Add Kubernetes apt repository (pkgs.k8s.io) --------
log "Adding Kubernetes apt repository (pkgs.k8s.io ${K8S_SERIES})..."
install -m 0755 -d /usr/share/keyrings
curl -fsSL "https://pkgs.k8s.io/core:/stable:/${K8S_SERIES}/deb/Release.key" \
  | gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg

cat >/etc/apt/sources.list.d/kubernetes.list <<EOF
deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/${K8S_SERIES}/deb/ /
EOF

apt-get update -y || {
  err "apt update failed. Check for duplicate or broken sources in /etc/apt/sources.list.d/*.list"; exit 1;
}

# -------- Install kubelet, kubeadm, kubectl --------
log "Installing kubelet, kubeadm, kubectl..."
DEBIAN_FRONTEND=noninteractive apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

systemctl enable --now kubelet

# -------- Configure crictl to use containerd by default --------
log "Configuring crictl runtime to containerd..."
cat >/etc/crictl.yaml <<'EOF'
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 10
debug: false
pull-image-on-create: false
EOF

# -------- Print next steps --------
log "Kubernetes node prerequisites are installed."

if $DO_CONTROL_PLANE; then
  cat <<'EOT'

Next steps (Control plane init):
1) Choose a pod network (CNI). Examples:
   - Calico:
     kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml
   - Cilium:
     cilium install

2) Initialize cluster (example CIDR for Calico):
   kubeadm init \
     --pod-network-cidr=192.168.0.0/16 \
     --kubernetes-version stable-1

3) Configure kubectl for current user:
   mkdir -p $HOME/.kube
   cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
   chown $(id -u):$(id -g) $HOME/.kube/config

4) Install your chosen CNI BEFORE scheduling workloads.

To join worker nodes, run the command printed by kubeadm init, e.g.:
   kubeadm join <API_SERVER>:6443 --token <token> \
     --discovery-token-ca-cert-hash sha256:<hash>

EOT
else
  cat <<'EOT'

Node is ready for kubeadm. To join this node as a worker, obtain the join command from the control plane and run it here, e.g.:
  kubeadm join <API_SERVER>:6443 --token <token> \
    --discovery-token-ca-cert-hash sha256:<hash>

EOT
fi

log "All done!"
