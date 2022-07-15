*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 5.5 Оркестрация кластером Docker контейнеров на примере Docker Swarm

## Задача 1

Дайте письменые ответы на следующие вопросы:

- В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?
- Какой алгоритм выбора лидера используется в Docker Swarm кластере?
- Что такое Overlay Network?


###### Ответ:

* В чём отличие режимов работы сервисов в Docker Swarm кластере: replication и global?
  * replication
    > приложение запускается в том количестве экземпляров, какое укажет пользователь

  * global
    > приложение запускается обязательно на каждой ноде и в единственном экземпляре

* Какой алгоритм выбора лидера используется в Docker Swarm кластере?
  * Используется алгоритм поддержания распределенного консенсуса - Raft
    > Он позволяет решить проблему согласованности, чтоб все manager ноды знали о состоянии кластера

    > Для отказоустойчивой работы должно быть обязательно нечетное колличество manager нод (2 < N < 8)

* Что такое Overlay Network?
  * Это сеть поверх другой сети.
    > В Docker Overlay-сеть создает подсеть, которую могут использовать контейнеры в разных хостах swarm-кластера.

    > Контейнеры на разных физических хостах могут обмениваться данными по overlay-сети.

    > Overlay-сеть использует технологию vxlan

## Задача 2

Создать ваш первый Docker Swarm кластер в Яндекс.Облаке

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker node ls
```

###### Ответ:

```bash
[centos@node01 ~]$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
o9s3rbtd7qvvy84wkckwbcxor *   node01.netology.yc   Ready     Active         Leader           20.10.17
cqjqi26fhetlfmfecnogq2qv2     node02.netology.yc   Ready     Active         Reachable        20.10.17
vub2b8gi5u6eab8tcwthmfpzg     node03.netology.yc   Ready     Active         Reachable        20.10.17
rgv2k9owvd8zf27yky67lia0s     node04.netology.yc   Ready     Active                          20.10.17
qtd1z9emefe57t96ukapjnw8h     node05.netology.yc   Ready     Active                          20.10.17
lk1ri99822gdwscb8zemirmnd     node06.netology.yc   Ready     Active                          20.10.17
[centos@node01 ~]$
```

## Задача 3

Создать ваш первый, готовый к боевой эксплуатации кластер мониторинга, состоящий из стека микросервисов.

Для получения зачета, вам необходимо предоставить скриншот из терминала (консоли), с выводом команды:
```
docker service ls
```

###### Ответ:

```bash
[centos@node01 ~]$ sudo docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
strbvptpeuw6   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0
woyavqpcfa3n   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
gppt2mrhc66h   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest
yaat6o0cems9   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest
30fyas7wrkx4   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4
prwzwhwxx7wh   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0
oonzlqbxrpb6   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0
wgzby7bgdsys   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0
[centos@node01 ~]$
```


## Задача 4 (*)

Выполнить на лидере Docker Swarm кластера команду (указанную ниже) и дать письменное описание её функционала, что она делает и зачем она нужна:
```
# см.документацию: https://docs.docker.com/engine/swarm/swarm_manager_locking/
docker swarm update --autolock=true
```

###### Ответ:

* Команда `docker swarm update --autolock=true` включает автоблокировку на существующем рое.
* Функция `автоматической блокировки` защищает конфигурацию и данные от злоумышленников, которые могут получить доступ к журналам Raft.

Проверим как это работает.

* Подключаемся к `node01`

`ssh centos@node01`

```bash
[centos@node01 ~]$ sudo docker swarm update --autolock=true
Swarm updated.
To unlock a swarm manager after it restarts, run the `docker swarm unlock`
command and provide the following key:

    SWMKEY-1-nt3IuWknX+06+YlH7CQNHeq4qYjvOFUCcX97jpcU8CU

Please remember to store this key in a password manager, since without it you
will not be able to restart the manager.
[centos@node01 ~]$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
o9s3rbtd7qvvy84wkckwbcxor *   node01.netology.yc   Ready     Active         Leader           20.10.17
cqjqi26fhetlfmfecnogq2qv2     node02.netology.yc   Ready     Active         Reachable        20.10.17
vub2b8gi5u6eab8tcwthmfpzg     node03.netology.yc   Ready     Active         Reachable        20.10.17
rgv2k9owvd8zf27yky67lia0s     node04.netology.yc   Ready     Active                          20.10.17
qtd1z9emefe57t96ukapjnw8h     node05.netology.yc   Ready     Active                          20.10.17
lk1ri99822gdwscb8zemirmnd     node06.netology.yc   Ready     Active                          20.10.17
```
* Перезагрузим Docker на `node01`

```bash
[centos@node01 ~]$ sudo service docker restart
Redirecting to /bin/systemctl restart docker.service
[centos@node01 ~]$ sudo docker service ls
Error response from daemon: Swarm is encrypted and needs to be unlocked before it can be used. Please use "docker swarm unlock" to unlock it.
```

* Подключимся к `node02`

`ssh centos@node02`

```bash
[centos@node02 ~]$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
o9s3rbtd7qvvy84wkckwbcxor     node01.netology.yc   Ready     Active         Unreachable      20.10.17
cqjqi26fhetlfmfecnogq2qv2 *   node02.netology.yc   Ready     Active         Reachable        20.10.17
vub2b8gi5u6eab8tcwthmfpzg     node03.netology.yc   Ready     Active         Leader           20.10.17
rgv2k9owvd8zf27yky67lia0s     node04.netology.yc   Ready     Active                          20.10.17
qtd1z9emefe57t96ukapjnw8h     node05.netology.yc   Ready     Active                          20.10.17
lk1ri99822gdwscb8zemirmnd     node06.netology.yc   Ready     Active                          20.10.17
```

* Видим что `Leader` сменился при перезапуске Docker с `node01` на `node03`
* Переключаемся снова на `node01`

```bash
[centos@node01 ~]$ sudo docker swarm unlock
Please enter unlock key:
[centos@node01 ~]$ sudo docker service ls
ID             NAME                                MODE         REPLICAS   IMAGE                                          PORTS
strbvptpeuw6   swarm_monitoring_alertmanager       replicated   1/1        stefanprodan/swarmprom-alertmanager:v0.14.0
woyavqpcfa3n   swarm_monitoring_caddy              replicated   1/1        stefanprodan/caddy:latest                      *:3000->3000/tcp, *:9090->9090/tcp, *:9093-9094->9093-9094/tcp
gppt2mrhc66h   swarm_monitoring_cadvisor           global       6/6        google/cadvisor:latest
yaat6o0cems9   swarm_monitoring_dockerd-exporter   global       6/6        stefanprodan/caddy:latest
30fyas7wrkx4   swarm_monitoring_grafana            replicated   1/1        stefanprodan/swarmprom-grafana:5.3.4
prwzwhwxx7wh   swarm_monitoring_node-exporter      global       6/6        stefanprodan/swarmprom-node-exporter:v0.16.0
oonzlqbxrpb6   swarm_monitoring_prometheus         replicated   1/1        stefanprodan/swarmprom-prometheus:v2.5.0
wgzby7bgdsys   swarm_monitoring_unsee              replicated   1/1        cloudflare/unsee:v0.8.0
[centos@node01 ~]$ sudo docker node ls
ID                            HOSTNAME             STATUS    AVAILABILITY   MANAGER STATUS   ENGINE VERSION
o9s3rbtd7qvvy84wkckwbcxor *   node01.netology.yc   Ready     Active         Reachable        20.10.17
cqjqi26fhetlfmfecnogq2qv2     node02.netology.yc   Ready     Active         Reachable        20.10.17
vub2b8gi5u6eab8tcwthmfpzg     node03.netology.yc   Ready     Active         Leader           20.10.17
rgv2k9owvd8zf27yky67lia0s     node04.netology.yc   Ready     Active                          20.10.17
qtd1z9emefe57t96ukapjnw8h     node05.netology.yc   Ready     Active                          20.10.17
lk1ri99822gdwscb8zemirmnd     node06.netology.yc   Ready     Active                          20.10.17
```

* Используя флаг `--autolock` мы разрешаем автоматическую блокировку узлов при перезапуске Docker.
* Когда Docker перезапустится нужно разблокировать рой, потому что при попытке запустить или перезапустить службу заблокированный рой выдаст ошибку `Error response from daemon: Swarm is encrypted and needs to be unlocked before it can be used. Please use "docker swarm unlock" to unlock it.`
