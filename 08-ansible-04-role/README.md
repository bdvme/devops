*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 8.4 Работа с roles.

## Подготовка к выполнению

1. (Необязательно) Познакомтесь с [lighthouse](https://youtu.be/ymlrNlaHzIY?t=929)
2. Создайте два пустых публичных репозитория в любом своём проекте: vector-role и lighthouse-role.
3. Добавьте публичную часть своего ключа к своему профилю в github.

## Основная часть

Наша основная цель - разбить наш playbook на отдельные roles. Задача: сделать roles для clickhouse, vector и lighthouse и написать playbook для использования этих ролей. Ожидаемый результат: существуют три ваших репозитория: два с roles и один с playbook.

1. Создать в старой версии playbook файл `requirements.yml` и заполнить его следующим содержимым:

   ```yaml
   ---
     - src: git@github.com:AlexeySetevoi/ansible-clickhouse.git
       scm: git
       version: "1.11.0"
       name: clickhouse
   ```

2. При помощи `ansible-galaxy` скачать себе эту роль.
3. Создать новый каталог с ролью при помощи `ansible-galaxy role init vector-role`.
4. На основе tasks из старого playbook заполните новую role. Разнесите переменные между `vars` и `default`.
5. Перенести нужные шаблоны конфигов в `templates`.
6. Описать в `README.md` обе роли и их параметры.
7. Повторите шаги 3-6 для lighthouse. Помните, что одна роль должна настраивать один продукт.
8. Выложите все roles в репозитории. Проставьте тэги, используя семантическую нумерацию Добавьте roles в `requirements.yml` в playbook.
9. Переработайте playbook на использование roles. Не забудьте про зависимости lighthouse и возможности совмещения `roles` с `tasks`.
10. Выложите playbook в репозиторий.
11. В ответ приведите ссылки на оба репозитория с roles и одну ссылку на репозиторий с playbook.

---

Подготовка:
---
Для выполнения домашнего задания я использовал инструменты Vagrant, Ansible.

С помощью описания в ./src/vagrant/Vagrantfile создал 4 виртуальные машины, по одной на каждый сервис + мастер хост.

```
vagrant status
Current machine states:

server01.netology         running (virtualbox)
server02.netology         running (virtualbox)
server03.netology         running (virtualbox)
server04.netology         running (virtualbox)
```

Вся начинка виртуальных машин устанавливалась используя ansible playbook ./src/ansible/provision.yml.

## Основная часть

1. Создал и заполнил файл `requirements.yml`

```YAML
---
  - src: https://github.com/AlexeySetevoi/ansible-clickhouse.git
    scm: git
    version: "1.11.0"
    name: clickhouse
```

2. При помощи `ansible-galaxy` скачал себе эту роль.

```bash
ansible-galaxy install -f -r requirements.yml --roles-path roles --ignore-errors
```

3. Создал новый каталог с ролями vector-role, lighthouse-role при помощи

```bash
ansible-galaxy role init vector-role
ansible-galaxy role init lighthouse-role
```

4. На основе tasks из старого playbook заполнил новые role. Разнес переменные между `vars` и `default`.

```YAML
#./playbook/roles/lighthouse/vars/main.yml
---
# vars file for lighthouse
lighthouse_repo: "https://github.com/VKCOM/lighthouse.git"
lighthouse_access_log: lighthouse_access
lighthouse_dir: "/var/www/{{ virtual_domain }}"
nginx_root_dir: "/usr/share/nginx/html"
worker_processes: auto
worker_connections: 2048
client_max_body_size: 512M
nginx_user: nginx
virtual_domain: lighthouse

```

```YAML
#./playbook/roles/vector/vars/main.yml
---
# vars file for vector
vector_version: 0.22.0
```

5. Перенес шаблоны конфигов в `templates`.

```
./playbook/roles/lighthouse/templates
.
├── lighthouse.conf.j2
└── nginx.conf.j2
```

6. Описал в `README.md` обе роли и их параметры.

[Описание для роли Lighthouse](https://github.com/bdvme/lighthouse-role/blob/main/README.md)

[Описание для роли Vector](https://github.com/bdvme/vector-role/blob/main/README.md)

7. Выложите все roles в репозитории. Проставьте тэги, используя семантическую нумерацию Добавьте roles в `requirements.yml` в playbook.

[Lighthouse-role](https://github.com/bdvme/lighthouse-role)

[Vector-role](https://github.com/bdvme/vector-role)

```YAML
---
  - src: https://github.com/AlexeySetevoi/ansible-clickhouse.git
    scm: git
    version: "1.11.0"
    name: clickhouse

  - src: https://github.com/bdvme/lighthouse-role.git
    scm: git
    version: "2.11.0"
    name: lighthouse

  - src: https://github.com/bdvme/vector-role.git
    scm: git
    version: "0.22.0"
    name: vector
```
8. Переработал playbook на использование roles. Не забудьте про зависимости lighthouse и возможности совмещения `roles` с `tasks`.

Совмещение `roles` с `tasks` на примере работы с ролью `clickhouse`

```yaml
---
- name: Install clickhouse
  hosts: clickhouse
  become: yes
  become_user: root
  remote_user: vagrant
  roles:
    - { role: clickhouse, vars: { clickhouse_listen_host_custom: "{{ hostvars['clk-instance']['ansible_host'] }}", "127.0.0.1" } }
  handlers:
    - name: Clickhouse-server restart
      service:
        name: clickhouse-server
        state: restarted
  tasks:
    - name: Create clickhouse database
      command: "clickhouse-client -q 'CREATE DATABASE IF NOT EXISTS logs;'"
    - name: Create clickhouse table
      command: "clickhouse-client -q 'CREATE TABLE IF NOT EXISTS  logs.logs (message String) ENGINE = MergeTree() ORDER BY tuple();'"
      notify: "Clickhouse-server restart"
  tags: clickhouse
```

9. Выложите playbook в репозиторий.

[Playbook](https://github.com/bdvme/devops/blob/main/08-ansible-04-role/playbook/playbook.yml)
