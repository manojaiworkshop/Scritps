# 1) Inspect duplicates (optional)
nl -ba /etc/apt/sources.list.d/ubuntu-mirrors.list

# 2) Remove duplicated lines 3..8 by keeping only one set for main/restricted/universe/multiverse
sudo cp /etc/apt/sources.list.d/ubuntu-mirrors.list{,.bak.$(date +%s)}
# Quick fix: deduplicate identical lines
sudo awk '!seen[$0]++' /etc/apt/sources.list.d/ubuntu-mirrors.list | sudo tee /etc/apt/sources.list.d/ubuntu-mirrors.list >/dev/null

# 3) Remove any old Kubernetes list using apt.kubernetes.io (xenial)
if [ -f /etc/apt/sources.list.d/kubernetes.list ]; then
  sudo sed -n '1,200p' /etc/apt/sources.list.d/kubernetes.list
  sudo cp /etc/apt/sources.list.d/kubernetes.list{,.bak.$(date +%s)}
  # Clear or remove it to avoid conflict with new pkgs.k8s.io source
  sudo rm -f /etc/apt/sources.list.d/kubernetes.list
fi

# 4) Update apt and proceed
sudo apt-get update