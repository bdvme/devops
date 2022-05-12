*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 5.2 Применение принципов IaaC в работе с виртуальными машинами.

## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.
- Какой из принципов IaaC является основополагающим?

###### Ответ:

* Опишите своими словами основные преимущества применения на практике IaaC паттернов

  * Скорость и уменьшение затрат: IaC позволяет быстрее конфигурировать инфраструктуру и направлен на обеспечение прозрачности, чтобы помочь другим командам со всего предприятия работать быстрее и эффективнее.

  * Масштабируемость и стандартизация: IaC предоставляет стабильные среды быстро и на должном уровне. Командам разработчиков не нужно прибегать к ручной настройке - они обеспечивают корректность, описывая с помощью кода требуемое состояние сред.

  * провизионирование всех вычислительных, сетевых и служб хранения отвечает код, они каждый раз будут развертываться одинаково. Это означает, что стандарты безопасности можно легко и последовательно применять в разных компаниях.

  * Восстановление в аварийных ситуациях: Название говорит само за себя — это очень важно. IaC — чрезвычайно эффективный способ отслеживания вашей инфраструктуры и повторного развертывания последнего работоспособного состояния после сбоя или катастрофы любого рода.

* Какой из принципов IaaC является основополагающим?

  * Идемпотентность - свойство объекта или операции при повторном применении операции к объекту давать тот же результат, что и при первом - например, код используемый для развертывания серверов/конфигурации серверов, постоянно дает одинаковый результат и конечное состояние.


## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

###### Ответ:

* Чем Ansible выгодно отличается от других систем управление конфигурациями?

   * При использовании Ansible не требуется установка на серверы дополнительного ПО, его можно использовать без PKI (Public Key Infrastructure). Для написания сценариев (playbooks) используется YAML, тем самым достигается высокая читаемость выполняемых действий и упрощается документирование.

* Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

  * Ansible использует метод push, благодаря которому вы самостоятельно отправляете на все агенты конфигурацию и сразу же получаете результат, время реакции на проблемы и ошибки значительно меньше чем при методе pull, при котором агенты сами по таймеру забирают конфигурацию с центральной ноды.

## Задача 3

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*

###### Ответ:

* Vagrant


```bash
brew install vagrant
vagrant -v
Vagrant 2.2.19
```

* VirtualBox

```bash
brew install virtualbox
vboxmanage --version
6.1.34r150636
```

* Ansible

```bash
brew install ansible
ansible --version
ansible [core 2.12.5]
  config file = None
  configured module search path = ['/Volumes/Azgard/Users/bdv/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/local/lib/python3.10/site-packages/ansible
  ansible collection location = /Volumes/Azgard/Users/bdv/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/local/bin/ansible
  python version = 3.10.4 (main, May 11 2022, 13:42:07) [Clang 10.0.0 (clang-1000.11.45.5)]
  jinja version = 3.1.2
  libyaml = True
```

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды
```
docker ps
```

###### Ответ:

* Используем конфигурационные файлы из практической части лекции

```
cd 05-virt-02-iaac
tree
.
├── README.md
└── src
    ├── ansible
    │   ├── inventory
    │   └── provision.yml
    └── vagrant
        ├── Vagrantfile
        └── ansible.cfg
```

* Перейдем в директорию с файлом `Vagrantfile`

* Выполним команду `vagrant up`

```
vagrant up
Bringing machine 'server1.netology' up with 'virtualbox' provider...
==> server1.netology: Checking if box 'bento/ubuntu-20.04' version '202112.19.0' is up to date...
==> server1.netology: Clearing any previously set network interfaces...
==> server1.netology: Preparing network interfaces based on configuration...
    server1.netology: Adapter 1: nat
    server1.netology: Adapter 2: hostonly
==> server1.netology: Forwarding ports...
    server1.netology: 22 (guest) => 20011 (host) (adapter 1)
    server1.netology: 22 (guest) => 2222 (host) (adapter 1)
==> server1.netology: Running 'pre-boot' VM customizations...
==> server1.netology: Booting VM...
==> server1.netology: Waiting for machine to boot. This may take a few minutes...
    server1.netology: SSH address: 127.0.0.1:2222
    server1.netology: SSH username: vagrant
    server1.netology: SSH auth method: private key
    server1.netology: Warning: Connection reset. Retrying...
    server1.netology: Warning: Remote connection disconnect. Retrying...
    server1.netology:
    server1.netology: Vagrant insecure key detected. Vagrant will automatically replace
    server1.netology: this with a newly generated keypair for better security.
    server1.netology:
    server1.netology: Inserting generated public key within guest...
    server1.netology: Removing insecure key from the guest if it's present...
    server1.netology: Key inserted! Disconnecting and reconnecting using new SSH key...
==> server1.netology: Machine booted and ready!
==> server1.netology: Checking for guest additions in VM...
==> server1.netology: Setting hostname...
==> server1.netology: Configuring and enabling network interfaces...
==> server1.netology: Mounting shared folders...
    server1.netology: /vagrant => /Volumes/EncSync/EncSync/netology_devops/virt-homeworks/05-virt-02-iaac/src/vagrant
==> server1.netology: Running provisioner: ansible...
    server1.netology: Running ansible-playbook...

PLAY [nodes] *******************************************************************

TASK [Gathering Facts] *********************************************************
ok: [server1.netology]

TASK [Create directory for ssh-keys] *******************************************
ok: [server1.netology]

TASK [Adding rsa-key in /root/.ssh/authorized_keys] ****************************
changed: [server1.netology]

TASK [Checking DNS] ************************************************************
changed: [server1.netology]

TASK [Installing tools] ********************************************************
ok: [server1.netology] => (item=git)
ok: [server1.netology] => (item=curl)

TASK [Installing docker] *******************************************************
changed: [server1.netology]

TASK [Add the current user to docker group] ************************************
changed: [server1.netology]

PLAY RECAP *********************************************************************
server1.netology           : ok=7    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

* Выполним команду `vagrant ssh` и подключимся в виртуальной машине

```
vagrant ssh
Welcome to Ubuntu 20.04.3 LTS (GNU/Linux 5.4.0-91-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Thu 12 May 2022 12:56:30 PM UTC

  System load:  0.0                Users logged in:          0
  Usage of /:   13.6% of 30.88GB   IPv4 address for docker0: 172.17.0.1
  Memory usage: 24%                IPv4 address for eth0:    10.0.2.15
  Swap usage:   0%                 IPv4 address for eth1:    192.168.99.11
  Processes:    108


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
Last login: Thu May 12 12:22:08 2022 from 10.0.2.2
vagrant@server1:~$
```

* Выполним команду `docker ps`

```
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```

* Командой `docker run hello-world` запустим контейнер "Hello-world"

```
vagrant@server1:~$ docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
2db29710123e: Pull complete
Digest: sha256:80f31da1ac7b312ba29d65080fddf797dd76acfb870e677f390d5acba9741b17
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

* Командой `docker run -it ubuntu bash` запустим оболочку `bash` в контейнере `ubuntu`

```
vagrant@server1:~$ docker run -it ubuntu bash
Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
125a6e411906: Pull complete
Digest: sha256:26c68657ccce2cb0a31b330cb0be2b5e108d467f641c62e13ab40cbec258c68d
Status: Downloaded newer image for ubuntu:latest
root@1f3e93421a9e:/#
```

* Выполним команду `docker ps -a`

```
vagrant@server1:~$ docker ps -a
CONTAINER ID   IMAGE         COMMAND    CREATED         STATUS                     PORTS     NAMES
1f3e93421a9e   ubuntu        "bash"     2 minutes ago   Exited (0) 6 seconds ago             eloquent_austin
91de8a3acca9   hello-world   "/hello"   4 minutes ago   Exited (0) 4 minutes ago             inspiring_shtern
```
