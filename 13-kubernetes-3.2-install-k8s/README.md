*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 13.2 «Установка Kubernetes»

### Цель задания

Установить кластер K8s.

### Чеклист готовности к домашнему заданию

1. Развёрнутые ВМ с ОС Ubuntu 20.04-lts.


### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция по установке kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/).
2. [Документация kubespray](https://kubespray.io/).

-----

### Задание 1. Установить кластер k8s с 1 master node

1. Подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды.
2. В качестве CRI — containerd.
3. Запуск etcd производить на мастере.
4. Способ установки выбрать самостоятельно.

## Дополнительные задания (со звёздочкой)

**Настоятельно рекомендуем выполнять все задания под звёздочкой.** Их выполнение поможет глубже разобраться в материале.   
Задания под звёздочкой необязательные к выполнению и не повлияют на получение зачёта по этому домашнему заданию. 

------
### Задание 2*. Установить HA кластер

1. Установить кластер в режиме HA.
2. Использовать нечётное количество Master-node.
3. Для cluster ip использовать keepalived или другой способ.

----
###### Ответ:

### Задание 1. Установить кластер k8s с 1 master node

Установку K8S буду производить с помощью Vagrant+Ansible+Shell



Подготовим 5 ВМ:

```bash
cd ./src/vagrant
vagrant up
```

Файл hosts.yml генерируется через шаблоны при создании ВМ.

<details> 
<summary>hosts.yml</summary>
<pre><code>
all:
  hosts:
    master01:
      ansible_host: {{ hostvars[groups['k8s-master'][0]].ip }}
      ip: {{ hostvars[groups['k8s-master'][0]].ip }}
      access_ip: {{ hostvars[groups['k8s-master'][0]].ip }}
      ssh_key_info:
        ssh_public_key: "~/.ssh/id_rsa.pub"
    worker01:
      ansible_host: {{ hostvars[groups['k8s-worker'][0]].ip }}
      ip: {{ hostvars[groups['k8s-worker'][0]].ip }}
      access_ip: {{ hostvars[groups['k8s-worker'][0]].ip }}
      ssh_key_info:
        ssh_public_key: "~/.ssh/id_rsa.pub"
    worker02:
      ansible_host: {{ hostvars[groups['k8s-worker'][1]].ip }}
      ip: {{ hostvars[groups['k8s-worker'][1]].ip }}
      access_ip: {{ hostvars[groups['k8s-worker'][1]].ip }}
      ssh_key_info:
        ssh_public_key: "~/.ssh/id_rsa.pub"
    worker03:
      ansible_host: {{ hostvars[groups['k8s-worker'][2]].ip }}
      ip: {{ hostvars[groups['k8s-worker'][2]].ip }}
      access_ip: {{ hostvars[groups['k8s-worker'][2]].ip }}
      ssh_key_info:
        ssh_public_key: "~/.ssh/id_rsa.pub"
    worker04:
      ansible_host: {{ hostvars[groups['k8s-worker'][3]].ip }}
      ip: {{ hostvars[groups['k8s-worker'][3]].ip }}
      access_ip: {{ hostvars[groups['k8s-worker'][3]].ip }}
      ssh_key_info:
        ssh_public_key: "~/.ssh/id_rsa.pub"
  vars:
    ansible_connection: ssh
    ansible_user: vagrant
    ansible_ssh_pass: vagrant
  children:
    kube_control_plane:
      hosts:
        master01:
    kube_node:
      hosts:
        worker01:
        worker02:
        worker03:
        worker04:
    etcd:
      hosts:
        master01:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
</code></pre>
</details>

в файле k8s-cluster.yml активируем следующие настройки для создания конфигурационного файла `admin.conf` и установки `kubectl`:

```bash
kubeconfig_localhost: true
kubectl_localhost: true
```

shell-файл для запуска ansible-playbook:
<details> 
<summary>k8s.sh</summary>
<pre><code>
sudo ansible-playbook -i inventory/cluster/hosts.yml -b --diff cluster.yml

mkdir -p ~/.kube
sudo cp inventory/cluster/artifacts/admin.conf ~/.kube/config
sudo cp inventory/cluster/artifacts/kubectl /usr/local/bin/kubectl

sudo chown vagrant:vagrant ~/.kube/config
</code></pre>
</details>

Зайдем на master и установим k8s:
```bash
vagrant ssh master01.netology
vagrant@master01:~$ cd /opt/kubespray/
vagrant@master01:/opt/kubespray$ ./k8s.sh
```

Установка K8S с помощью Kubespray прошла успешно:

```bash
PLAY RECAP ***************************************************************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
master01                   : ok=707  changed=144  unreachable=0    failed=0    skipped=1217 rescued=0    ignored=4   
worker01                   : ok=489  changed=92   unreachable=0    failed=0    skipped=721  rescued=0    ignored=0   
worker02                   : ok=489  changed=92   unreachable=0    failed=0    skipped=720  rescued=0    ignored=0   
worker03                   : ok=489  changed=92   unreachable=0    failed=0    skipped=720  rescued=0    ignored=0   
worker04                   : ok=489  changed=92   unreachable=0    failed=0    skipped=720  rescued=0    ignored=0   

Monday 25 September 2023  14:33:43 +0000 (0:00:00.337)       0:38:48.906 ****** 
=============================================================================== 
download : Download_file | Download item ------------------------------------------------------------------------------------------------------------------------------------------------------------ 177.82s
container-engine/containerd : Download_file | Download item ----------------------------------------------------------------------------------------------------------------------------------------- 155.14s
container-engine/crictl : Download_file | Download item --------------------------------------------------------------------------------------------------------------------------------------------- 120.10s
download : Download_file | Download item ------------------------------------------------------------------------------------------------------------------------------------------------------------ 105.71s
container-engine/nerdctl : Download_file | Download item --------------------------------------------------------------------------------------------------------------------------------------------- 99.27s
download : Download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------- 84.99s
download : Download_file | Download item ------------------------------------------------------------------------------------------------------------------------------------------------------------- 84.54s
download : Download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------- 77.87s
download : Download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------- 58.98s
download : Download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------- 57.15s
container-engine/runc : Download_file | Download item ------------------------------------------------------------------------------------------------------------------------------------------------ 53.27s
download : Download_file | Download item ------------------------------------------------------------------------------------------------------------------------------------------------------------- 46.50s
download : Download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------- 45.58s
download : Download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------- 38.96s
download : Download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------- 36.87s
download : Download_file | Download item ------------------------------------------------------------------------------------------------------------------------------------------------------------- 32.18s
container-engine/crictl : Extract_file | Unpacking archive ------------------------------------------------------------------------------------------------------------------------------------------- 23.95s
container-engine/nerdctl : Extract_file | Unpacking archive ------------------------------------------------------------------------------------------------------------------------------------------ 23.88s
download : Download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------- 23.83s
kubernetes/kubeadm : Join to cluster ----------------------------------------------------------------------------------------------------------------------------------------------------------------- 20.55s
vagrant@master01:/opt/kubespray$ 
```

Проверим ноды:

```bash
vagrant@master01:/opt/kubespray$ kubectl get node

NAME       STATUS   ROLES           AGE     VERSION
master01   Ready    control-plane   4m48s   v1.28.2
worker01   Ready    <none>          3m45s   v1.28.2
worker02   Ready    <none>          3m46s   v1.28.2
worker03   Ready    <none>          3m45s   v1.28.2
worker04   Ready    <none>          3m45s   v1.28.2

vagrant@master01:/opt/kubespray$ kubectl get pod -A
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-67cb94d654-p46df           1/1     Running   0          3m15s
kube-system   coredns-67cb94d654-zrrr7           1/1     Running   0          3m20s
kube-system   dns-autoscaler-7b6c6d8b5b-h4llx    1/1     Running   0          3m16s
kube-system   kube-apiserver-master01            1/1     Running   1          5m30s
kube-system   kube-controller-manager-master01   1/1     Running   2          5m30s
kube-system   kube-flannel-77c6t                 1/1     Running   0          3m46s
kube-system   kube-flannel-kg9xx                 1/1     Running   0          3m46s
kube-system   kube-flannel-l8lkj                 1/1     Running   0          3m46s
kube-system   kube-flannel-lsq8h                 1/1     Running   0          3m46s
kube-system   kube-flannel-v5hlw                 1/1     Running   0          3m46s
kube-system   kube-proxy-2p4dc                   1/1     Running   0          4m26s
kube-system   kube-proxy-965xk                   1/1     Running   0          4m26s
kube-system   kube-proxy-cz974                   1/1     Running   0          4m26s
kube-system   kube-proxy-vl74t                   1/1     Running   0          4m26s
kube-system   kube-proxy-xz8zs                   1/1     Running   0          4m26s
kube-system   kube-scheduler-master01            1/1     Running   1          5m30s
kube-system   nginx-proxy-worker01               1/1     Running   0          4m30s
kube-system   nginx-proxy-worker02               1/1     Running   0          4m30s
kube-system   nginx-proxy-worker03               1/1     Running   0          4m30s
kube-system   nginx-proxy-worker04               1/1     Running   0          4m29s
kube-system   nodelocaldns-2m6hk                 1/1     Running   0          3m15s
kube-system   nodelocaldns-7xscb                 1/1     Running   0          3m15s
kube-system   nodelocaldns-dt7l9                 1/1     Running   0          3m15s
kube-system   nodelocaldns-grvtp                 1/1     Running   0          3m15s
kube-system   nodelocaldns-xtzzz                 1/1     Running   0          3m15s
```