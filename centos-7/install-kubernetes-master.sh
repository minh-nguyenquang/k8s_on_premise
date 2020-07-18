# Install Docker CE
## Set up the repository
### Install required packages.
yum install -y yum-utils device-mapper-persistent-data lvm2

### Add Docker repository.
yum-config-manager \
  --add-repo \
  https://download.docker.com/linux/centos/docker-ce.repo

## Install Docker CE.
yum update && yum install -y docker-ce-18.06.2.ce

## Create /etc/docker directory.
mkdir /etc/docker

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart Docker
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

# Allow network bridge from container to localhost
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

# Add kubernetes repo
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Install specific verson of kubernetes
yum install -y kubelet-1.14.3 kubeadm-1.14.3 kubectl-1.14.3 --disableexcludes=kubernetes
systemctl enable --now kubelet

# Overlay network using calico
echo "deploying kubernetes (with calico)..."
kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=192.168.10.21 # add --apiserver-advertise-address="ip" if you want to use a different IP address than the main server IP
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f /root/calico_rbac.yml
kubectl apply -f /root/calico_deamonset.yml

# Overlay network using flannel
# echo "deploying kubernetes (with canal)..."
# kubeadm init --pod-network-cidr=10.244.0.0/16 # add --apiserver-advertise-address="ip" if you want to use a different IP address than the main server IP
# export KUBECONFIG=/etc/kubernetes/admin.conf
# kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/canal/rbac.yaml
# kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/canal/canal.yaml
