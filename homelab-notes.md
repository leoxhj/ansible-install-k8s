# Guide to deploy kubernetes in homelab
This is note to deploy kubernetes 1.30.5 on my homelab based on OS: Ubuntu 24.04.1 LTS

## About hardware
Dell Optiplex 3070M, detailed specification shown as below
```bash
CPU: i7-8700T
Memory : 16G x 2 Samsung DDR4 2666
SSD1: M2 256G Samsung
SSD2: 1T WestData 
```

## About software
* pfSense for firewall
* Proxmox for virtualization
* Ubuntu 24.04.1 LTS
```yaml
Configure static ip address
vi /etc/netplan/50-cloud-init.yaml
network:
    renderer: networkd
    ethernets:
        ens18: # 替换为你的网络接口名称
            dhcp4: false # 关闭 DHCP
            dhcp6: false # 关闭 DHCP
            addresses: [192.168.2.51/24] # 静态 IP 地址和子网掩码
            routes:
              - to: default
                via: 192.168.2.1 # 网关地址
            nameservers:
                addresses: [192.168.2.1] # DNS 服务器地址
                search: []
    version: 2
netplan apply
* change hostname
hostnamectl set-hostname new-hostname
* Install package
apt -y install golang-cfssl python3-pip ansible openssh-server net-tools libnginx-mod-stream policycoreutils selinux-basics selinux-utils
* edit /etc/ssh/sshd_config and restart service (systemctl restart ssh)
PermitRootLogin yes
* Modify /etc/hosts
add all ip domains
* generate ssh key and copy ssh public key to all k8s servers from admin server
# ssh-keygen
# ssh-copy-id -i ~/.ssh/id_rsa.pub root@k8s-master1 && ssh k8s-master1
```


## Network infra


ChinaTelecom Moderm

Firewall+Route(pfsense)
|-WAN: 	PPPoE
|-LAN:	192.168.2.1
|-DHCP:	192.168.2.2 - 192.168.2.199

Switch(TP-Link - 16ports)
|-LAN:	192.168.2.11 (static)
|-DNS:	192.168.2.1
|-GW:	192.168.2.1
|-SM:	255.255.255.0
|-DHCP: disabled

Mi AX6000 (all wireless devices- max 34)
|-LAN:	192.168.2.10 (static)
|-DNS:	192.168.2.1
|-GW:	192.168.2.1
|-DHCP: 192.168.2.220 - 192.168.2.254

Proxmox - homelab3070 (i7-8700t 12c32g, 1T Solid SSD+256G M2.SSD)
LAN:	192.168.2.180:8006
|- 192.168.2.51 (ubuntu 24LTS)
|- 192.168.2.52 (ubuntu 24LTS)
|- 192.168.2.53 (ubuntu 24LTS)

Proxmox - homelab7060 (i7-8700t 12c24g, 500G Solid SSD)
LAN:	192.168.2.150:806


## Kubernetes
* set kubectl config
```bash
kubectl config set-cluster kubernetes --server=https://192.168.2.88:8080 --certificate-authority=/root/ansible-install-k8s/ssl/k8s/ca.pem --embed-certs=true
kubectl config set-context kubernetes --cluster=kubernetes --user=admin --namespace=kube-system
kubectl config use-context kubernetes
cfssl gencert -ca /etc/kubernetes/ssl/ca.pem -ca-key /etc/kubernetes/ssl/ca-key.pem -config /etc/kubernetes/ssl/ca-config.json -profile kubernetes kubectl-csr.json | cfssljson -bare kubectl
kubectl config set-credentials admin --client-key=/root/ansible-install-k8s/ssl/k8s/admin-key.pem --client-certificate=/root/ansible-install-k8s/ssl/k8s/admin.pem --user=admin --embed-certs=true
```
* get pending csr from master
  `kubectl get csr`
* approve pending csr from node
  `kubectl certificate approve (-f FILENAME | NAME)·`

* 

