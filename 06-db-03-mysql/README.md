*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 6.3. MySQL"

## Введение

Перед выполнением задания вы можете ознакомиться с
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и
восстановитесь из него.

Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h` получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с данным контейнером.

###### Ответ:

* Используя docker поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

```bash
vagrant@build1:/opt/stack$ cat docker-compose.yml
version: "3.3"
services:
  mysql:
    image: mysql:8
    environment:
      MYSQL_ROOT_PASSWORD: qwertyui
      MYSQL_DATABASE: test_db
    volumes:
      - ./backups:/var/lib/backups
      - ./data:/var/lib/mysql/
    ports:
      - "3306:3306"
```

* Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-03-mysql/test_data) и
восстановитесь из него.

```bash
vagrant@server1:/opt/stack$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED              STATUS              PORTS                                                  NAMES
e96f6e313f2b   mysql:8   "docker-entrypoint.s…"   About a minute ago   Up About a minute   0.0.0.0:3306->3306/tcp, :::3306->3306/tcp, 33060/tcp   stack_mysql_1
vagrant@server1:/opt/stack$ docker exec -it stack_mysql_1 bash
mysql -u root -p test_db < /var/lib/backups/test_dump.sql
```

* Перейдите в управляющую консоль `mysql` внутри контейнера.

```bash
mysql -u root -p
Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
mysql>
```

* Используя команду `\h` получите список управляющих команд.

```bash
mysql> \h

List of all MySQL commands:
Note that all text commands must be first on line and end with ';'
...
status    (\s) Get status information from the server.
...

For server side help, type 'help contents'
```

* Найдите команду для выдачи статуса БД и **приведите в ответе** из ее вывода версию сервера БД.

```bash
mysql> \s
--------------
mysql  Ver 8.0.29 for Linux on x86_64 (MySQL Community Server - GPL)

...
Server version:		8.0.29 MySQL Community Server - GPL
...
--------------
```

* Подключитесь к восстановленной БД и получите список таблиц из этой БД.

```Bash
mysql> use test_db;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> show tables;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0.00 sec)
```

* **Приведите в ответе** количество записей с `price` > 300.

```bash
mysql> SELECT COUNT(*) `count` FROM `orders` WHERE `price` > 300
    -> ;
+-------+
| count |
+-------+
|     1 |
+-------+
1 row in set (0.00 sec)
```

## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:
- плагин авторизации mysql_native_password
- срок истечения пароля - 180 дней
- количество попыток авторизации - 3
- максимальное количество запросов в час - 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James"

Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.

Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и
**приведите в ответе к задаче**.

###### Ответ:

* Создайте пользователя test в БД c паролем test-pass, используя:
  - плагин авторизации mysql_native_password
  - срок истечения пароля - 180 дней
  - количество попыток авторизации - 3
  - максимальное количество запросов в час - 100
  - аттрибуты пользователя:
      - Фамилия "Pretty"
      - Имя "James"

```bash
mysql> CREATE USER IF NOT EXISTS 'test'@'localhost' IDENTIFIED WITH mysql_native_password BY 'test-pass'
    -> WITH MAX_CONNECTIONS_PER_HOUR 100
    -> PASSWORD EXPIRE INTERVAL 180 DAY
    -> FAILED_LOGIN_ATTEMPTS 3
    -> PASSWORD_LOCK_TIME 1
    -> ATTRIBUTE '{"lastname":"Pretty", "name":"James"}';
Query OK, 0 rows affected (0.04 sec)
```

* Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.

```bash
mysql> GRANT SELECT ON test_db.* TO 'test'@'localhost';
Query OK, 0 rows affected, 1 warning (0.02 sec)
```

* Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES получите данные по пользователю `test` и
**приведите в ответе к задаче**.

```bash
mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER = 'test';
+------+-----------+-----------------------------------------+
| USER | HOST      | ATTRIBUTE                               |
+------+-----------+-----------------------------------------+
| test | localhost | {"name": "James", "lastname": "Pretty"} |
+------+-----------+-----------------------------------------+
1 row in set (0.03 sec)
```

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

###### Ответ:

* Установите профилирование `SET profiling = 1`.

```bash
mysql> SET profiling = 1;
Query OK, 0 rows affected, 1 warning (0.00 sec)
```

* Изучите вывод профилирования команд `SHOW PROFILES;`.

```bash
mysql> SHOW PROFILES;
Empty set, 1 warning (0.00 sec)
```

* Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

```bash
mysql> SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES where TABLE_SCHEMA = 'test_db';
+------------+--------+
| TABLE_NAME | ENGINE |
+------------+--------+
| orders     | InnoDB |
+------------+--------+
1 row in set (0.00 sec)
```

* Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`
- на `InnoDB`

```bash
mysql> ALTER TABLE orders ENGINE = MyISAM;
Query OK, 5 rows affected (0.10 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> ALTER TABLE orders ENGINE = InnoDB;
Query OK, 5 rows affected (0.06 sec)
Records: 5  Duplicates: 0  Warnings: 0

mysql> SHOW PROFILES;
+----------+------------+-----------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                   |
+----------+------------+-----------------------------------------------------------------------------------------+
|        1 | 0.00160150 | SELECT TABLE_NAME, ENGINE FROM information_schema.TABLES where TABLE_SCHEMA = 'test_db' |
|        2 | 0.10420800 | ALTER TABLE orders ENGINE = MyISAM                                                      |
|        3 | 0.05712350 | ALTER TABLE orders ENGINE = InnoDB                                                      |
+----------+------------+-----------------------------------------------------------------------------------------+
3 rows in set, 1 warning (0.00 sec)
```

## Задача 4

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):
- Скорость IO важнее сохранности данных
- Нужна компрессия таблиц для экономии места на диске
- Размер буффера с незакомиченными транзакциями 1 Мб
- Буффер кеширования 30% от ОЗУ
- Размер файла логов операций 100 Мб

Приведите в ответе измененный файл `my.cnf`.

###### Ответ:

* Скорость IO важнее сохранности данных

`innodb_flush_log_at_trx_commit = 0`

* Нужна компрессия таблиц для экономии места на диске

`innodb_file_per_table = ON`

* Размер буффера с незакомиченными транзакциями 1 Мб

`innodb_log_buffer_size = 1M`

* Буффер кеширования 30% от ОЗУ

`innodb_buffer_pool_size=1G`

* Размер файла логов операций 100 Мб

`innodb_log_file_size = 100M`

```bash
cat /etc/my.cnf

[mysqld]
skip-host-cache
skip-name-resolve
datadir=/var/lib/mysql
socket=/var/run/mysqld/mysqld.sock
secure-file-priv=/var/lib/mysql-files
user=mysql

pid-file=/var/run/mysqld/mysqld.pid
[client]
socket=/var/run/mysqld/mysqld.sock

!includedir /etc/mysql/conf.d/

innodb_flush_log_at_trx_commit = 0
innodb_file_per_table = ON
innodb_log_buffer_size = 1M
innodb_buffer_pool_size = 1G
innodb_log_file_size = 100M
```
