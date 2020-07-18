# SETUP KUBERNETES ON-PREMISES

#### PREREQUISITE
- OS: Ubuntu 16.04
- Minimum CPU: 2vCPU
- No swap enabled

#### How to setup cluster
1. Use script ``install-kubernetes-master.sh`` to setup master node.
2. Once master node is up, use script ``install-kubernetes-nodes.sh`` to setup needed packages for worker nodes.
3. Generate token on master ``kubeadm token create --print-join-command``
```
root@k8s-master:~# kubeadm token create --print-join-command
kubeadm join 192.168.10.11:6443 --token gbzo7i.1qhe5hyf3ebgwfjs     --discovery-token-ca-cert-hash sha256:4b5df4853e0cacd77f591f69cb96fad06c9baedc82551375758f2c8ba5e7b51c
```
4. Copy join command and execute on worker node
5. Create ``kube config`` with command `cp /etc/kubernetes/admin.conf ~/.kube/config`
6. Verify kubectl is able to connect kube-apiserver with command `kubectl get all`
```
NAME                                                READY   STATUS    RESTARTS   AGE
pod/calico-node-77rbr                               2/2     Running   0          38m
pod/calico-node-fptgb                               2/2     Running   0          38m
pod/calico-node-tsnjb                               2/2     Running   0          38m
pod/calico-node-x78rp                               2/2     Running   0          38m
pod/coredns-5644d7b6d9-7fnjh                        1/1     Running   0          36m
pod/coredns-5644d7b6d9-nd2jq                        1/1     Running   0          35m
pod/etcd-k8s-master.test.local                      1/1     Running   3          123m
pod/kube-apiserver-k8s-master.test.local            1/1     Running   3          123m
pod/kube-controller-manager-k8s-master.test.local   1/1     Running   5          123m
pod/kube-proxy-lwvq6                                1/1     Running   0          36m
pod/kube-proxy-qfltv                                1/1     Running   0          36m
pod/kube-proxy-qzjq9                                1/1     Running   0          36m
pod/kube-proxy-v7cq5                                1/1     Running   0          36m
pod/kube-scheduler-k8s-master.test.local            1/1     Running   4          123m

NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
service/calico-typha   ClusterIP   10.109.229.194   <none>        5473/TCP                 124m
service/kube-dns       ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP   124m

NAME                         DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                 AGE
daemonset.apps/calico-node   4         4         4       4            4           <none>                        124m
daemonset.apps/kube-proxy    4         4         4       4            4           beta.kubernetes.io/os=linux   124m

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/calico-typha   0/0     0            0           124m
deployment.apps/coredns        2/2     2            2           124m

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/calico-typha-6fb7467b59   0         0         0       124m
replicaset.apps/coredns-5644d7b6d9        2         2         2       124m
```

#### Supporting Document
- https://docs.projectcalico.org/v3.1/reference/node/configuration#ip-autodetection-methods
- https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
