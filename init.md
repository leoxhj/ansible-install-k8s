# system initialization
```bash
# install dependencies
yum install -y epel-release
yum install -y chrony conntrack ipvsadm ipset jq iptables curl sysstat libseccomp wget socat git lrzsz
# disable fireware
systemctl stop firewalld
systemctl disable firewalld
iptables -F && iptables -X && iptables -F -t nat && iptables -X -t nat
iptables -P FORWARD ACCEPT
# swap off
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
# kernel optimization
cat > kubernetes.conf <<EOF
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
net.ipv4.tcp_tw_recycle=0
net.ipv4.neigh.default.gc_thresh1=1024
net.ipv4.neigh.default.gc_thresh1=2048
net.ipv4.neigh.default.gc_thresh1=4096
vm.swappiness=0
vm.overcommit_memory=1
vm.panic_on_oom=0
fs.inotify.max_user_instances=8192
fs.inotify.max_user_watches=1048576
fs.file-max=52706963
fs.nr_open=52706963
net.ipv6.conf.all.disable_ipv6=1
net.netfilter.nf_conntrack_max=2310720
EOF
cp kubernetes.conf  /etc/sysctl.d/kubernetes.conf
sysctl -p /etc/sysctl.d/kubernetes.conf
# set timezone
timedatectl set-timezone Asia/Shanghai
# system clock sync
systemctl enable chronyd
systemctl start chronyd
timedatectl status
# write current UTC
timedatectl set-local-rtc 0
systemctl restart rsyslog 
systemctl restart crond
# remove unneccesary service
systemctl stop postfix && systemctl disable postfix
# upgrade kernel from 3.10.x to > 4.4.x 
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel install -y kernel-lt
grub2-set-default 0
# reboot to new kernel
sync
reboot

```

# setup network
```bash
# centos 7.x
cd /etc/sysconfig/network-scripts/
cp ifcfg-ens33 ifcfg-ens33.backup
vi ifcfg-ens33
# dynamic, assigned by DHCP
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="dhcp"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens192"
UUID="88f530cf-851d-4f23-a1f7-326684d9df15"
DEVICE="ens192"
ONBOOT="yes"
# static
TYPE="Ethernet"
PROXY_METHOD="none"
BROWSER_ONLY="no"
BOOTPROTO="static"
DEFROUTE="yes"
IPV4_FAILURE_FATAL="no"
IPV6INIT="yes"
IPV6_AUTOCONF="yes"
IPV6_DEFROUTE="yes"
IPV6_FAILURE_FATAL="no"
IPV6_ADDR_GEN_MODE="stable-privacy"
NAME="ens192"
UUID="88f530cf-851d-4f23-a1f7-326684d9df15"
DEVICE="ens192"
ONBOOT="yes"
IPADDR="192.168.2.50"
NETMASK="255.255.255.0"
GATEWAY="192.168.2.1"
DNS1="192.168.2.1"
DNS2="8.8.8.8"
systemctl restart network

```

# set hostname
```bash
hostnamectl set-hostname k8s-master01
cat >> /etc/hosts <<EOF
{ip} {hostname}
...
...

EOF
```

# set ssh-key
```bash
ssh-keygen -t rsa 
ssh-copy-id root@zhangjun-k8s-01
ssh-copy-id root@zhangjun-k8s-02
ssh-copy-id root@zhangjun-k8s-03
```