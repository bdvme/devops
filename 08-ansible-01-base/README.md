*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 8.1 Введение в Ansible.

## Подготовка к выполнению
1. Установите ansible версии 2.10 или выше.
2. Создайте свой собственный публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

## Основная часть
1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.
2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.
3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.
4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.
6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.
9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

## Необязательная часть

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.

###### Ответы:

* Создал ВМ используя инстументы: Vagrant, Ansible.
* `playbook` находится в каталоге `./src/ansible/roles/sync/files/stack/opt/`

1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.

###### Ответ:

```bash
vagrant ssh
vagrant@server1:/opt/playbook$ ansible-playbook -i ./inventory/test.yml ./site.yml

...

TASK [Print fact]
*****************************************************************
ok: [localhost] => {
    "msg": 12
}

...

```

2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.

###### Ответ:

```bash
vagrant@server1:/opt/playbook$ nano ./group_vars/all/examp.yml

cat ./group_vars/all/examp.yml
---
  some_fact: all default fact

```

3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.

###### Ответ:

* Docker контейнеры CentOS7 и Ubuntu создаю с помощью docker-compose.yml и Dockerfile

```bash
cat docker-compose.yml

version: "3.3"
services:
  centos:
    build:
      context: .
      dockerfile: dockerfile_centos
    container_name: centos7
    stdin_open: true
    tty: true
    entrypoint: /bin/bash
  ubuntu:
    build:
      context: .
      dockerfile: dockerfile_ubuntu
    container_name: ubuntu
    stdin_open: true
    tty: true
    entrypoint: /bin/bash
```

```bash
cat dockerfile_centos

FROM centos:7

RUN yum -y update && \
yum -y install python3
```

```bash
cat dockerfile_ubuntu

FROM ubuntu:20.04

RUN apt -y update && \
apt -y install python3
```

4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.

###### Ответ:

```Bash
vagrant ssh -c "ansible-playbook -i /opt/playbook/inventory/prod.yml /opt/playbook/site.yml"

PLAY [Print os facts]
*****************************************************************
TASK [Gathering Facts]
*****************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS]
*****************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact]
*****************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP
*****************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

```

5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.

###### Ответ:

* Устанавливаем значения:

  * для `deb` - 'deb default fact'

```bash
cat /opt/playbook/group_vars/deb/examp.yml

---
  some_fact: "deb default fact"
```

  * для `el` - 'el default fact'

```bash
cat /opt/playbook/group_vars/el/examp.yml

---
  some_fact: "el default fact"
```

6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.

###### Ответ:

```bash
vagrant ssh -c "ansible-playbook -i /opt/playbook/inventory/prod.yml /opt/playbook/site.yml"

PLAY [Print os facts]
*****************************************************************

TASK [Gathering Facts]
*****************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS]
*****************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact]
*****************************************************************
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}

PLAY RECAP
*****************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.

###### Ответ:

```bash
cd /opt/playbook/
ansible-vault encrypt ./group_vars/deb/examp.yml
New Vault password:
Confirm New Vault password:
Encryption successful
cat ./group_vars/deb/examp.yml
$ANSIBLE_VAULT;1.1;AES256
31353961323536626430376338663534666233353332356339613839333931326362653265663062
3935646633333633306263626136623266343664383936610a336263363532316465326163323261
32386266373631313032303561356339396633313730333539343961303532616366646162356534
6139356331663965300a643765366332313737613036633332653164393361343066656665396566
34366639653562366631363134316665306635373139613963363562636461323666643366353366
6537386364346436343333326365626131393431306533353136

cd /opt/playbook/
ansible-vault encrypt ./group_vars/el/examp.yml
New Vault password:
Confirm New Vault password:
Encryption successful
cat ./group_vars/el/examp.yml
$ANSIBLE_VAULT;1.1;AES256
36653734356539323132633633356366346436393064316266616335663533306165316564376138
3233623638626230316433646663343039376265373630350a326162633134363739653965613364
62376233343633343936396633396539626337306566356238656333323531646462316365396636
3466343738316264370a613964323338623832313666656236306631646661343238383962333932
32626562393261336562313233303465663662303437326163633439313231373336633937323338
3433366563653062373565323362373337376538336561363134
```

8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.

###### Ответ:

```bash
vagrant ssh -c "sudo ansible-playbook -i /opt/playbook/inventory/prod.yml /opt/playbook/site.yml --ask-vault-pass"
Vault password:

PLAY [Print os facts]
*****************************************************************

TASK [Gathering Facts]
*****************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS]
*****************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact]
*****************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP
*****************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.

###### Ответ:

* Для control node нужен плагин `local`

10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.

###### Ответ:

```bash
---
  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker
  local:
    hosts:
      localhost:
        ansible_connection: local
```

11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.

###### Ответ:

```bash
vagrant ssh -c "sudo ansible-playbook -i /opt/playbook/inventory/prod.yml /opt/playbook/site.yml --ask-vault-pass"
Vault password:

PLAY [Print os facts]
*****************************************************************

TASK [Gathering Facts]
*****************************************************************
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS]
*****************************************************************
ok: [localhost] => {
    "msg": "Ubuntu"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact]
*****************************************************************
ok: [localhost] => {
    "msg": "local default fact"
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP
*****************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

###### Ответ:

* [08-ansible-01-base "Introduction to Ansible."](https://github.com/bdvme/devops/tree/main/08-ansible-01-base)

* [08-ansible=01-base "Introduction to Ansible: selftest"](https://github.com/bdvme/devops/tree/main/08-ansible-01-base/playbook)
