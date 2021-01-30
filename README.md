# 主要组件版本
| 组件 | 版本 | 发布时间 |
| --- | --- | --- |
| kubernetes | 1.18.6 | 2020-01-22 |
| etcd | 3.4.3 | 2019-10-24 |
| containerd | 1.3.3 | 2020-02-07 |
| runc | 1.0.0-rc10 | 2019-12-23 |
| calico | 3.12.0 | 2020-01-27 |
| coredns | 1.6.6 | 2019-12-20 |
| dashboard | v2.0.0-rc4 | 2020-02-06 |
| k8s-prometheus-adapter | 0.5.0 | 2019-04-03|
| prometheus-operator | 0.35.0 | 2020-01-13 |
| prometheus | 2.15.2 | 2020-01-06 |
| elasticsearch、kibana | 7.2.0 | 2019-06-25 |
| cni-plugins | 0.8.5 | 2019-12-20 |
| metrics-server | 0.3.6 | 2019-10-15 |

# Kubernetes v1.18 高可用集群自动部署（离线版）
>### 确保所有节点系统时间一致
### 1、下载所需文件

下载Ansible部署文件：

```
# git clone https://github.com/lizhenliang/ansible-install-k8s
# cd ansible-install-k8s
```

下载软件包并解压/root目录：

链接：https://pan.baidu.com/s/1EWnJoJjAD3GNqghOwgodWQ 
提取码：tlvz
```
# tar zxf binary_pkg.tar.gz
```
### 2、修改Ansible文件

修改hosts文件，根据规划修改对应IP和名称。

```
# vi hosts
...
```
修改group_vars/all.yml文件，修改软件包目录和证书可信任IP。

```
# vim group_vars/all.yml
software_dir: '/root/binary_pkg'
...
cert_hosts:
  k8s:
  etcd:
```
## 3、一键部署
### 架构图
单Master架构
![avatar](https://github.com/lizhenliang/ansible-install-k8s/blob/master/single-master.jpg)

多Master架构
![avatar](https://github.com/lizhenliang/ansible-install-k8s/blob/master/multi-master.jpg)
### 部署命令
单Master版：
```
# ansible-playbook -i hosts single-master-deploy.yml -uroot -k
```
多Master版：
```
# ansible-playbook -i hosts multi-master-deploy.yml -uroot -k
```

## 4、部署控制
如果安装某个阶段失败，可针对性测试.

例如：只运行部署插件
```
# ansible-playbook -i hosts single-master-deploy.yml -uroot -k --tags addons
```

## 5、节点扩容
1）修改hosts，添加新节点ip
```
# vi hosts
```
2）执行部署
```
ansible-playbook -i hosts add-node.yml -uroot -k
```
3）在Master节点允许颁发证书并加入集群
```
kubectl get csr
kubectl certificate approve node-csr-xxx
```

视频教程：https://ke.qq.com/course/266656

![avatar](https://github.com/lizhenliang/Shell-Python-Document/blob/master/%E8%81%94%E7%B3%BB%E6%96%B9%E5%BC%8F.png)
