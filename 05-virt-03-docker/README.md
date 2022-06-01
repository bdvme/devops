*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 5.3 Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера.

## Задача 1

Сценарий выполения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберете любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.

###### Ответ:

* Используя конфигурационные файлы из предыдущего домашнего задания [05-virt-02-iaac](https://github.com/bdvme/devops/tree/main/05-virt-02-iaac), модифицировав файлы [provision.yml](https://github.com/bdvme/devops/tree/main/05-virt-03-docker/src/ansible/provision.yml), [Vagrantfile](https://github.com/bdvme/devops/tree/main/05-virt-03-docker/src/vagrant/Vagrantfile) и добавив файлы [Dockerfile](https://github.com/bdvme/devops/tree/main/05-virt-03-docker/src/webserver/Dockerfile), [index.html](https://github.com/bdvme/devops/tree/main/05-virt-03-docker/src/webserver/index.html) реализовал функционал требующийся в задании.

```Bash
cd 05-virt-03-docker
tree
.
├── README.md
└── src
    ├── ansible
    │   ├── inventory
    │   └── provision.yml
    ├── docker_ansible
    │   └── Dockerfile
    ├── vagrant
    │   ├── Vagrantfile
    │   └── ansible.cfg
    └── webserver
        ├── Dockerfile
        └── index.html
```

* HTML-код содержится в файле `./src/webserver/index.html`
* Инструкции для сборки docker образа в файле `./src/webserver/Dockerfile`

* Ссылка на форк: https://hub.docker.com/r/bdvme/devtest

## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- Высоконагруженное монолитное java веб-приложение;
- Nodejs веб-приложение;
- Мобильное приложение c версиями для Android и iOS;
- Шина данных на базе Apache Kafka;
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana;
- Мониторинг-стек на базе Prometheus и Grafana;
- MongoDB, как основное хранилище данных для java-приложения;
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry.

###### Ответ:

* Высоконагруженное монолитное java веб-приложение
  * Лучше использовать полную аппаратную виртуализацию (например VMWare vCentre) или физический сервер. Так как приложение монолитное и нет микросервисов, а так же для уменьшения количества точек отказа и сокращения временных задержек при больших нагрузках.

* Nodejs веб-приложение
  * Подойдет Docker контейнер, можно выделить для каждого микросервиса свой контейнер.

*  Мобильное приложение c версиями для Android и iOS
  * Для Android приложения можно использовать физическую машину, а так же Docker контейнер. Для iOS придется использовать только физическое устройство, лицензия Apple не позволяет виртуализировать iOS.

* Шина данных на базе Apache Kafka
  * Apache Kafka это распределенная система с горизонтальной масштабируемостью, серверы объединяются в кластеры, что повышает надежность и отказоустойчивость. Для Apache Kafka можно применять как физические устройства, так и Docker контейнеры, в которые можно поместить брокеры Kafka, продюссеры, консьюмеры, Zookeeper.

* Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana
  * Для Elasticsearch необходимо использовать высокопроизводительные физические серверы, либо аппаратную виртуализацию (например VMWare vCentre).

* Мониторинг-стек на базе Prometheus и Grafana
  * Для Prometheus и Grafana можно использовать Docker контейнер, так как не требуется высокая производительность. Задача Prometheus - сбор метрик из сервисов, а Grafana - визуализация собранных данных.

* MongoDB, как основное хранилище данных для java-приложения
  * Для реализации этого сценария подойдет как физическая машина, так и виртуализация (например VMware vSAN), а так же Docker контейнер с внешним томом хранения данных (Persistent Volumes).

* Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry
  * Данный сценарий быстро и удобно развернуть в Docker контейнерах. Приватный Docker Registry можно развернуть используя образ registry из Docker Hub, gitlab сервер с Runner так же есть в Docker Hub.

## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

###### Ответ:

```
vagrant@server1:~$ docker run -it -d -v ~/data:/data -h "centos" --name data_centos_1 centos
3c4e1f40b9e006a4faa58731df5a78c1fd020b48736cc97972ac019dffc311bc
vagrant@server1:~$ docker run -it -d -v ~/data:/data -h "debian" --name data_debian_1 debian
3a2494a5c7d272be2a782cbe2d96f5ba1bee5da8275970d7225aa12463205c62
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND       CREATED          STATUS          PORTS     NAMES
3a2494a5c7d2   debian    "bash"        6 seconds ago    Up 5 seconds              data_debian_1
3c4e1f40b9e0   centos    "/bin/bash"   29 seconds ago   Up 28 seconds             data_centos_1
vagrant@server1:~$ docker exec -it data_centos_1 /bin/bash
[root@centos /]# ls
bin  data  dev	etc  home  lib	lib64  lost+found  media  mnt  opt  proc  root	run  sbin  srv	sys  tmp  usr  var
[root@centos /]# ls -la /home
total 8
drwxr-xr-x 2 root root 4096 Nov  3  2020 .
drwxr-xr-x 1 root root 4096 Jun  1 09:51 ..
[root@centos /]# cd data
[root@centos data]# echo "centos: I'm DevOps Engineer!" > centos_node.txt
[root@centos data]# ls
centos_node.txt
[root@centos data]# read escape sequence
vagrant@server1:~$ cd data
vagrant@server1:~/data$ echo "host: I'm DevOps Engineer!" > host_node.txt
vagrant@server1:~/data$ docker exec -it data_debian_1 /bin/bash
root@debian:/# cd data
root@debian:/data# ls
centos_node.txt  host_node.txt
root@debian:/data# cat *.txt
centos: I'm DevOps Engineer!
host: I'm DevOps Engineer!
root@debian:/data# read escape sequence
```

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

Соберите Docker образ с Ansible, загрузите на Docker Hub и пришлите ссылку вместе с остальными ответами к задачам.

###### Ответ:

```
vagrant upload ../../src/docker_ansible/Dockerfile ./docker_ansible/Dockerfile
Uploading ../../src/docker_ansible/Dockerfile to ./docker_ansible/Dockerfile
Upload has completed successfully!

  Source: ../../src/docker_ansible/Dockerfile
  Destination: ./docker_ansible/Dockerfile
vagrant ssh
vagrant@server1:~$ cd docker_ansible/
vagrant@server1:~/docker_ansible$ ls
Dockerfile
vagrant@server1:~/docker_ansible$ docker build -t bdvme/ansible:v2.9.24 .
Sending build context to Docker daemon   2.56kB
Step 1/5 : FROM alpine:3.14
3.14: Pulling from library/alpine
8663204ce13b: Pull complete
Digest: sha256:06b5d462c92fc39303e6363c65e074559f8d6b1363250027ed5053557e3398c5
Status: Downloaded newer image for alpine:3.14
........
........
Successfully built 4bf1fb84e313
Successfully tagged bdvme/ansible:v2.9.24
vagrant@server1:~/docker_ansible$ docker image ls
REPOSITORY      TAG       IMAGE ID       CREATED          SIZE
bdvme/ansible   v2.9.24   4bf1fb84e313   11 seconds ago   245MB
vagrant@server1:~/docker_ansible$ docker run -it --name ansible bdvme/ansible:v2.9.24
ansible-playbook [core 2.13.0]
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.9/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible-playbook
  python version = 3.9.5 (default, Nov 24 2021, 21:19:13) [GCC 10.3.1 20210424]
  jinja version = 3.1.2
  libyaml = False
vagrant@server1:~/docker_ansible$ docker push bdvme/ansible:v2.9.24
The push refers to repository [docker.io/bdvme/ansible]
b2c0892b4001: Pushed
517d2c01764e: Pushed
b541d28bf3b4: Mounted from library/alpine
v2.9.24: digest: sha256:0f244cc5bfb11009a76ca2a57b602bf1de4cbf29f04c2fb5ddb8ee64caace70f size: 947
```
* Ссылка на форк: https://hub.docker.com/r/bdvme/ansible
