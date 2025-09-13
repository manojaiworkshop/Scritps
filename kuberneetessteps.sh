sudo kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/calico.yaml


kubectl get nodes
kubectl get pods -n kube-system
kubectl get pods -A

mkdir -p $HOME/.kube

cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

chown $(id -u):$(id -g) $HOME/.kube/config


kubectl describe pod calico-node-m4rlr -n kube-system


kubectl taint nodes --all node-role.kubernetes.io/control-plane-

kubeadm reset -f && rm -rf /etc/kubernetes /var/lib/etcd /var/lib/kubelet /etc/cni/net.d && pkill -f kube



# Your Kubernetes control-plane has initialized successfully!

# To start using your cluster, you need to run the following as a regular user:

#   mkdir -p $HOME/.kube
#   sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
#   sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Alternatively, if you are the root user, you can run:

#   export KUBECONFIG=/etc/kubernetes/admin.conf

# You should now deploy a pod network to the cluster.
# Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
#   https://kubernetes.io/docs/concepts/cluster-administration/addons/

# Then you can join any number of worker nodes by running the following on each as root:

# kubeadm join 31.97.229.208:6443 --token yaha7u.oo6tre5o079euovd \
#         --discovery-token-ca-cert-hash sha256:d1f53efcb483a11cb35e4349a7749f7fe35c7deaa78cd1688c6d83cd4d5b47a5 
# root@srv943889:~/SchoolServer# 