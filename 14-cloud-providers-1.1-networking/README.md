*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 14.1 «Организация сети»

### Подготовка к выполнению задания

1. Домашнее задание состоит из обязательной части, которую нужно выполнить на провайдере Yandex Cloud, и дополнительной части в AWS (выполняется по желанию).
2. Все домашние задания в блоке 15 связаны друг с другом и в конце представляют пример законченной инфраструктуры.  
3. Все задания нужно выполнить с помощью Terraform. Результатом выполненного домашнего задания будет код в репозитории.
4. Перед началом работы настройте доступ к облачным ресурсам из Terraform, используя материалы прошлых лекций и домашнее задание по теме «Облачные провайдеры и синтаксис Terraform». Заранее выберите регион (в случае AWS) и зону.

---
### Задание 1. Yandex Cloud

**Что нужно сделать**

1. Создать пустую VPC. Выбрать зону.
2. Публичная подсеть.

 - Создать в VPC subnet с названием public, сетью 192.168.10.0/24.
 - Создать в этой подсети NAT-инстанс, присвоив ему адрес 192.168.10.254. В качестве image_id использовать fd80mrhj8fl2oe87o4e1.
 - Создать в этой публичной подсети виртуалку с публичным IP, подключиться к ней и убедиться, что есть доступ к интернету.
3. Приватная подсеть.
 - Создать в VPC subnet с названием private, сетью 192.168.20.0/24.
 - Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс.
 - Создать в этой приватной подсети виртуалку с внутренним IP, подключиться к ней через виртуалку, созданную ранее, и убедиться, что есть доступ к интернету.

Resource Terraform для Yandex Cloud:

- [VPC subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet).
- [Route table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table).
- [Compute Instance](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance).

---
### Задание 2. AWS* (задание со звёздочкой)

Это необязательное задание. Его выполнение не влияет на получение зачёта по домашней работе.

**Что нужно сделать**

1. Создать пустую VPC с подсетью 10.10.0.0/16.
2. Публичная подсеть.

 - Создать в VPC subnet с названием public, сетью 10.10.1.0/24.
 - Разрешить в этой subnet присвоение public IP по-умолчанию.
 - Создать Internet gateway.
 - Добавить в таблицу маршрутизации маршрут, направляющий весь исходящий трафик в Internet gateway.
 - Создать security group с разрешающими правилами на SSH и ICMP. Привязать эту security group на все, создаваемые в этом ДЗ, виртуалки.
 - Создать в этой подсети виртуалку и убедиться, что инстанс имеет публичный IP. Подключиться к ней, убедиться, что есть доступ к интернету.
 - Добавить NAT gateway в public subnet.
3. Приватная подсеть.
 - Создать в VPC subnet с названием private, сетью 10.10.2.0/24.
 - Создать отдельную таблицу маршрутизации и привязать её к private подсети.
 - Добавить Route, направляющий весь исходящий трафик private сети в NAT.
 - Создать виртуалку в приватной сети.
 - Подключиться к ней по SSH по приватному IP через виртуалку, созданную ранее в публичной подсети, и убедиться, что с виртуалки есть выход в интернет.

Resource Terraform:

1. [VPC](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc).
1. [Subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet).
1. [Internet Gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway).

### Правила приёма работы

Домашняя работа оформляется в своём Git репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
Файл README.md должен содержать скриншоты вывода необходимых команд, а также скриншоты результатов.
Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

----
###### Ответ:

Файл переменных окружения:

<details>
<summary>.tfvars</summary>

```bash
yandex_token="y0_AgAAA***************************************SM"
yandex_zone="ru-central1-a"
yandex_cloud_id="b1g*****************"
yandex_folder_id="b1g*****************"
yandex_service_acc="service-acc01"
yandex_profile="profile01"
yandex_image_id="fd8*****************"
vm1_user_name="vm1user"
vm2_user_name="vm2user"
vm_user_name_nat="vmusernat"
ssh_key_path="~/.ssh/id_rsa.pub"
```

</details>

---

Манифесты `terraform`:

Описание провайдера:
<details>
<summary>main.tf</summary>

```yaml
provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = "${var.yandex_cloud_id}"
  folder_id = "${var.yandex_folder_id}"
}
```

</details>

---

Версия:
<details>
<summary>version.tf</summary>

```yaml
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}
```

</details>

---

Описание NAT-инстанса:
<details>
<summary>nat-instance.tf</summary>

```yaml
resource "yandex_compute_instance" "nat-instance" {
  name                      = "vmnat"
  zone                      = "${var.yandex_zone}"
  platform_id               = "standard-v3"
  allow_stopping_for_update = true

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "${var.yandex_image_id}"
    }
  }

  network_interface {
    subnet_id          = "${yandex_vpc_subnet.public-subnet.id}"
    security_group_ids = ["${yandex_vpc_security_group.nat-instance-sg.id}"]
    nat                = true
    ipv4      = true
    ip_address = "192.168.10.254"
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user_name_nat}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }

  scheduling_policy {
    preemptible = true
  }

}
```

</details>

---

Описание таблицы маршрутизации:
<details>
<summary>nat-instance-route.tf</summary>

```yaml
resource "yandex_vpc_route_table" "nat-instance-route" {
  name       = "nat-instance-route"
  network_id = "${yandex_vpc_network.my-vpc.id}"
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "${yandex_compute_instance.nat-instance.network_interface.0.ip_address}"
  }
}
```

</details>

---

Описание сети:
<details>
<summary>network.tf</summary>

```yaml
# Network
resource "yandex_vpc_network" "my-vpc" {
  name = "local.network_name"
}

resource "yandex_vpc_subnet" "public-subnet" {
  name = "local.subnet_name1"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.my-vpc.id}"
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "private-subnet" {
  name = "local.subnet_name2"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.my-vpc.id}"
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = "${yandex_vpc_route_table.nat-instance-route.id}"
}
```

</details>

---

Описание группы безопасности:
<details>
<summary>security-group.tf</summary>

```yaml
resource "yandex_vpc_security_group" "nat-instance-sg" {
  name       = "local.sg_nat_name"
  network_id = "${yandex_vpc_network.my-vpc.id}"

  egress {
    protocol       = "ANY"
    description    = "any"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "ssh"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = "22"
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-http"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = "80"
  }

  ingress {
    protocol       = "TCP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = "443"
  }

  ingress {
    protocol       = "ICMP"
    description    = "ext-https"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
```

</details>

---

Описание VM1-инстанса, публичная сеть:
<details>
<summary>vm1.tf</summary>

```yaml
resource "yandex_compute_instance" "vm1" {
  name                      = "vm1"
  zone                      = "${var.yandex_zone}"
  hostname                  = "vm1.netology.cloud"
  platform_id               = "standard-v3"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "${var.yandex_image_id}"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.public-subnet.id}"
    nat = true
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm1_user_name}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }

  scheduling_policy {
    preemptible = true
  }
}
```

</details>

---

Описание VM2-инстанса, частная сеть:
<details>
<summary>vm2.tf</summary>

```yaml
resource "yandex_compute_instance" "vm2" {
  name                      = "vm2"
  zone                      = "${var.yandex_zone}"
  hostname                  = "vm2.netology.cloud"
  platform_id               = "standard-v3"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "${var.yandex_image_id}"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.private-subnet.id}"
    security_group_ids = ["${yandex_vpc_security_group.nat-instance-sg.id}"]
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm2_user_name}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }

  scheduling_policy {
    preemptible = true
  }
}
```

</details>

---

Описание переменных:
<details>
<summary>variable.tf</summary>

```yaml
variable "yandex_cloud_id" {
  default = "yandex_cloud_id"
}

variable "yandex_folder_id" {
  default = "yandex_folder_id"
}

variable "yandex_image_id" {
  default = "yandex_image_id"
}

variable "yandex_zone" {
  default = "yandex_zone"
}

variable "vm1_user_name" {
  default = "vm1_user_name"
}

variable "vm2_user_name" {
  default = "vm2_user_name"
}

variable "vm_user_name_nat" {
  default = "vm_user_name_nat"
}

variable "ssh_key_path" {
  default = "ssh_key_path"
}
```

</details>

---

Описание для вывода внешних и внутренных IP созданных VM
<details>
<summary>output.tf</summary>

```yaml
output "internal_ip_address_vm1_yandex_cloud" {
  value = "${yandex_compute_instance.vm1.network_interface.0.ip_address}"
}

output "external_ip_address_vm1_yandex_cloud" {
  value = "${yandex_compute_instance.vm1.network_interface.0.nat_ip_address}"
}

output "internal_ip_address_vm2_yandex_cloud" {
  value = "${yandex_compute_instance.vm2.network_interface.0.ip_address}"
}

output "internal_ip_address_nat_instance_yandex_cloud" {
  value = "${yandex_compute_instance.nat-instance.network_interface.0.ip_address}"
}

output "external_ip_address_nat_instance_yandex_cloud" {
  value = "${yandex_compute_instance.nat-instance.network_interface.0.nat_ip_address}"
}
```

</details>

---

* Инициализация `Yandex.Cloud` используя `shell` скрипт:

<details>
<summary>init_yc.sh</summary>

```bash
#!/bin/sh -x
cd ../terraform
yc config profile create ${yandex_profile}
yc config set folder-id ${yandex_folder_id}
yc config set cloud-id ${yandex_cloud_id}
yc config set token ${yandex_token}
yc config set compute-default-zone ${yandex_zone}
yc config profile activate ${yandex_profile}
yc iam service-account create --name ${yandex_service_acc}
yandex_service_acc_id=$(yc iam service-account get ${yandex_service_acc} | awk 'NR==1{print $2}')
yc resource-manager folder add-access-binding ${yandex_folder_id} --role editor --subject serviceAccount:${yandex_service_acc_id}
yc iam key create --service-account-name ${yandex_service_acc} --output key.json
yc config set service-account-key key.json
yc config set token ${yandex_token}
```

</details>

```bash
cd ./shell
source .env
chmod +x ./init_yс.sh
./init_yс.sh
```

* Инициализация `Terraform`

```bash
cd ./terraform
terraform init
```

* Применяем манифесты `terraform`

```bash
terraform apply -auto-approve -var-file=".tfvars"

Apply complete! Resources: 9 added, 0 changed, 0 destroyed.

Outputs:

external_ip_address_nat_instance_yandex_cloud = "158.160.34.223"
external_ip_address_vm1_yandex_cloud = "51.250.95.81"
internal_ip_address_nat_instance_yandex_cloud = "192.168.10.254"
internal_ip_address_vm1_yandex_cloud = "192.168.10.16"
internal_ip_address_vm2_yandex_cloud = "192.168.20.11"
```

* Подключаемся по SSH к VM1 и проверяем внешний IP:

```bash
ssh vm1user@51.250.95.81
vm1user@vm1:~$ curl ifconfig.ru
51.250.95.81
```

* Проверяем доступ до внешнего сервера:

```bash
vm1user@vm1:~$ ping netology.ru
PING netology.ru (188.114.99.224) 56(84) bytes of data.
64 bytes from 188.114.99.224 (188.114.99.224): icmp_seq=1 ttl=52 time=59.4 ms
64 bytes from 188.114.99.224 (188.114.99.224): icmp_seq=2 ttl=52 time=59.3 ms
64 bytes from 188.114.99.224 (188.114.99.224): icmp_seq=3 ttl=52 time=59.3 ms
64 bytes from 188.114.99.224 (188.114.99.224): icmp_seq=4 ttl=52 time=59.5 ms
^C
--- netology.ru ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3003ms
rtt min/avg/max/mdev = 59.347/59.420/59.513/0.067 ms
vm1user@vm1:~$
```

* Подключаемся по SSH к VM2 и проверяем внешний IP:

```bash
ssh -i ~/.ssh/id_rsa -A -J vm1user@51.250.95.81 vm2user@192.168.20.11
vm2user@vm2:~$ curl ifconfig.ru
158.160.34.223
```

* Проверяем доступ до внешнего сервера:

```bash
vm2user@vm2:~$ ping netology.ru
PING netology.ru (188.114.99.224) 56(84) bytes of data.
64 bytes from 188.114.99.224 (188.114.99.224): icmp_seq=1 ttl=48 time=59.9 ms
64 bytes from 188.114.99.224 (188.114.99.224): icmp_seq=2 ttl=48 time=59.5 ms
64 bytes from 188.114.99.224 (188.114.99.224): icmp_seq=3 ttl=48 time=58.9 ms
64 bytes from 188.114.99.224 (188.114.99.224): icmp_seq=4 ttl=48 time=59.0 ms
^C
--- netology.ru ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3004ms
rtt min/avg/max/mdev = 58.940/59.382/59.920/0.463 ms
```
