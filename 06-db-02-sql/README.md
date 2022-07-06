*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 6.2. Типы и структура СУБД"

# Ответы на домашнее задание к занятию "6.2. SQL"

## Введение

Перед выполнением задания вы можете ознакомиться с
[дополнительными материалами](https://github.com/netology-code/virt-homeworks/tree/master/additional/README.md).

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume,
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

###### Ответ:

```bash
vagrant@build1:~/docker_postgres$ cat docker-compose.yml
version: "3.3"
services:
  postgres:
    image: postgres:12
    environment:
      POSTGRES_USER: "user"
      POSTGRES_PASSWORD: "qwertyui"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - ./backups:/var/lib/postgresql/backups
      - ./data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
```

## Задача 2

В БД из задачи 1:
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

###### Ответ:

* Подключаемся к docker контейнеру

```Bash
docker exec -it stack_postgres_1 bash
```

* Подключаемся к базе PostgreSQL

```bash
psql --username=user
```

* создайте пользователя test-admin-user и БД test_db

```bash
CREATE USER "test-admin-user" WITH PASSWORD 'qwertyui';
CREATE DATABASE test_db;
\c test_db
You are now connected to database "test_db" as user "user".
```

* в БД test_db создайте таблицу orders и clients

```bash
CREATE TABLE orders (
    id integer PRIMARY KEY,
    name varchar(128),
    price numeric(10,2)
);

CREATE TABLE clients (
    id integer PRIMARY KEY,
    fio varchar(64),
    country varchar(64),
    order_id integer default null,
    FOREIGN KEY (order_id) REFERENCES orders (id)
);
```

* предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db

```bash
GRANT ALL PRIVILEGES ON orders TO "test-admin-user";
GRANT ALL PRIVILEGES ON clients TO "test-admin-user";
```

* создайте пользователя test-simple-user и предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

```bash
CREATE USER "test-simple-user" WITH PASSWORD 'qwertyui';
GRANT SELECT, INSERT, UPDATE, DELETE ON orders TO "test-simple-user";
GRANT SELECT, INSERT, UPDATE, DELETE ON clients TO "test-simple-user";
```

* итоговый список БД после выполнения пунктов выше**

```bash
\list
                             List of databases
   Name    | Owner | Encoding |  Collate   |   Ctype    | Access privileges
-----------+-------+----------+------------+------------+-------------------
 postgres  | user  | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | user  | UTF8     | en_US.utf8 | en_US.utf8 | =c/user          +
           |       |          |            |            | user=CTc/user
 template1 | user  | UTF8     | en_US.utf8 | en_US.utf8 | =c/user          +
           |       |          |            |            | user=CTc/user
 test_db   | user  | UTF8     | en_US.utf8 | en_US.utf8 |
(4 rows)

```

* описание таблиц (describe)**

```bash
\d orders
                      Table "public.orders"
 Column |          Type          | Collation | Nullable | Default
--------+------------------------+-----------+----------+---------
 id     | integer                |           | not null |
 name   | character varying(128) |           |          |
 price  | numeric(10,2)          |           |          |
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)

\d clients
                      Table "public.clients"
 Column  |         Type          | Collation | Nullable | Default
---------+-----------------------+-----------+----------+---------
 id      | integer               |           | not null |
 fio     | character varying(64) |           |          |
 country | character varying(64) |           |          |
 order_id| integer               |           |          |
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
Foreign-key constraints:
    "clients_order_id_fkey" FOREIGN KEY (order_id) REFERENCES orders(id)
```

* SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

```bash
SELECT *
FROM information_schema.table_privileges
WHERE table_catalog = 'test_db'
 AND table_schema = 'public'
 AND grantee != 'user';

 grantor |     grantee      | table_catalog | table_schema | table_name | privilege_type | is_grantable | with_hierarchy
---------+------------------+---------------+--------------+------------+----------------+--------------+----------------
user    | test-admin-user  | test_db       | public       | orders     | INSERT         | NO           | NO
user    | test-admin-user  | test_db       | public       | orders     | SELECT         | NO           | YES
user    | test-admin-user  | test_db       | public       | orders     | UPDATE         | NO           | NO
user    | test-admin-user  | test_db       | public       | orders     | DELETE         | NO           | NO
user    | test-admin-user  | test_db       | public       | orders     | TRUNCATE       | NO           | NO
user    | test-admin-user  | test_db       | public       | orders     | REFERENCES     | NO           | NO
user    | test-admin-user  | test_db       | public       | orders     | TRIGGER        | NO           | NO
user    | test-simple-user | test_db       | public       | orders     | INSERT         | NO           | NO
user    | test-simple-user | test_db       | public       | orders     | SELECT         | NO           | YES
user    | test-simple-user | test_db       | public       | orders     | UPDATE         | NO           | NO
user    | test-simple-user | test_db       | public       | orders     | DELETE         | NO           | NO
user    | test-admin-user  | test_db       | public       | clients    | INSERT         | NO           | NO
user    | test-admin-user  | test_db       | public       | clients    | SELECT         | NO           | YES
user    | test-admin-user  | test_db       | public       | clients    | UPDATE         | NO           | NO
user    | test-admin-user  | test_db       | public       | clients    | DELETE         | NO           | NO
user    | test-admin-user  | test_db       | public       | clients    | TRUNCATE       | NO           | NO
user    | test-admin-user  | test_db       | public       | clients    | REFERENCES     | NO           | NO
user    | test-admin-user  | test_db       | public       | clients    | TRIGGER        | NO           | NO
user    | test-simple-user | test_db       | public       | clients    | INSERT         | NO           | NO
user    | test-simple-user | test_db       | public       | clients    | SELECT         | NO           | YES
user    | test-simple-user | test_db       | public       | clients    | UPDATE         | NO           | NO
user    | test-simple-user | test_db       | public       | clients    | DELETE         | NO           | NO
(22 rows)

```

## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы
- приведите в ответе:
    - запросы
    - результаты их выполнения.

###### Ответ:

```bash
INSERT INTO orders (id, name, price) VALUES
(1, 'Шоколад', 10),
(2, 'Принтер', 3000),
(3, 'Книга', 500),
(4, 'Монитор', 7000),
(5, 'Гитара', 4000);
INSERT 0 5
INSERT INTO clients (id, fio, country) VALUES
(1, 'Иванов Иван Иванович', 'USA'),
(2, 'Петров Петр Петрович', 'Canada'),
(3, 'Иоганн Себастьян Бах', 'Japan'),
(4, 'Ронни Джеймс Дио', 'Russia'),
(5, 'Ritchie Blackmore', 'Russia');
INSERT 0 5
SELECT COUNT(*) FROM orders;
 count
-------
     5
(1 row)

SELECT COUNT(*) FROM clients;
 count
-------
     5
(1 row)

```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.

Подсказка - используйте директиву `UPDATE`.

###### Ответ:

* SQL-запросы для выполнения данных операций.

```text
UPDATE clients SET order_id = 3 WHERE id = 1;
UPDATE clients SET order_id = 4 WHERE id = 2;
UPDATE clients SET order_id = 5 WHERE id = 3;
```

* SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.

```text
SELECT c.fio, o.name
FROM clients c
LEFT JOIN orders o ON c.order_id = o.id
WHERE o.id IS NOT NULL;

         fio          |  name
----------------------+---------
 Иванов Иван Иванович | Книга
 Петров Петр Петрович | Монитор
 Иоганн Себастьян Бах | Гитара
(3 rows)
```

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

###### Ответ:

```bash
EXPLAIN SELECT c.fio, o.name
FROM clients c
LEFT JOIN orders o ON c.order_id = o.id
WHERE o.id IS NOT NULL;
                               QUERY PLAN
-------------------------------------------------------------------------
 Hash Join  (cost=15.61..28.65 rows=239 width=420)
   Hash Cond: (c.order_id = o.id)
   ->  Seq Scan on clients c  (cost=0.00..12.40 rows=240 width=150)
   ->  Hash  (cost=12.50..12.50 rows=249 width=278)
         ->  Seq Scan on orders o  (cost=0.00..12.50 rows=249 width=278)
               Filter: (id IS NOT NULL)
(6 rows)
```

15.61. - Приблизительная стоимость запуска. Это время, которое проходит, прежде чем начнётся этап вывода данных.

.28.65 - Приблизительная общая стоимость. Она вычисляется в предположении, что узел плана выполняется до конца, то есть возвращает все доступные строки (кроме случаев с LIMIT).

rows=239 - Ожидаемое число строк, которое должен вывести этот узел плана.

width=420 - Ожидаемый средний размер строк, выводимых этим узлом плана (в байтах).

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления.

###### Ответ:

* Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

```bash
vagrant@server1:~$ docker exec -t stack_postgres_1 pg_dump -U user test_db -f /var/lib/postgresql/backups/backups_test_db.sql
vagrant@server1:~$ ls -la /opt/stack/backups/
total 12
drwxr-xr-x 2 root root 4096 Jul  6 15:48 .
drwxr-xr-x 4 root root 4096 Jul  6 13:23 ..
-rw-r--r-- 1 root root 2684 Jul  6 15:48 backups_test_db.sql
```

* Остановите контейнер с PostgreSQL (но не удаляйте volumes).

```bash
vagrant@server1:~$ docker stop stack_postgres_1
```

* Поднимите новый пустой контейнер с PostgreSQL.

```bash
vagrant@build1:~/docker_postgres$ cat docker-compose.yml
version: "3.3"
services:
  postgres_2:
    image: postgres:12
    environment:
      POSTGRES_USER: "user"
      POSTGRES_PASSWORD: "qwertyui"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - ./backups:/var/lib/postgresql/backups
      - ./data2:/var/lib/postgresql/data
    ports:
      - "5432:5432"
```

* Восстановите БД test_db в новом контейнере.

Сначала нужно создать БД и пользователя:

```bash
\list
                             List of databases
   Name    | Owner | Encoding |  Collate   |   Ctype    | Access privileges
-----------+-------+----------+------------+------------+-------------------
 postgres  | user  | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | user  | UTF8     | en_US.utf8 | en_US.utf8 | =c/user          +
           |       |          |            |            | user=CTc/user
 template1 | user  | UTF8     | en_US.utf8 | en_US.utf8 | =c/user          +
           |       |          |            |            | user=CTc/user
 user      | user  | UTF8     | en_US.utf8 | en_US.utf8 |
(4 rows)

CREATE USER "test-admin-user" WITH PASSWORD 'qwertyui';
CREATE DATABASE test_db;
\c test_db;
```

Когда БД создана выполняем команду для восстановления данных

```bash
docker exec -i stack_postgres_2_1 psql -U user -d test_db -f /var/lib/postgresql/backups/backups_test_db.sql
```
