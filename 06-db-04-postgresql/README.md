*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql

###### Ответ:

* Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

```bash
version: "3.3"
services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_USER: "postgres"
      POSTGRES_PASSWORD: "qwertyui"
      PGDATA: "/var/lib/postgresql/data/pgdata"
    volumes:
      - ./backups:/var/lib/postgresql/backups
      - ./data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
```

* Подключитесь к БД PostgreSQL используя `psql`.

```bash
docker exec -it stack_postgres_1 psql -U postgres
```

* Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:

* вывода списка БД

`\l[+] [PATTERN] list databases`

* подключения к БД

`\c[onnect] {[DBNAME|- USER|- HOST|- PORT|-] | conninfo} connect to new database`

* вывода списка таблиц

`\dt[S+] [PATTERN] list tables`

* вывода описания содержимого таблиц

`\d[S+] NAME describe table, view, sequence, or index`
* выхода из psql

`\q quit psql`


## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders`
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

###### Ответ:

* Используя `psql` создайте БД `test_database`.

```sql
CREATE DATABASE test_database;
```

* Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

```bash
docker exec -it stack_postgres_1 psql -U postgres -d test_database -f /var/lib/postgresql/backups/test_dump.sql
SET
SET
SET
SET
SET
 set_config
------------

(1 row)

SET
SET
SET
SET
SET
SET
CREATE TABLE
ALTER TABLE
CREATE SEQUENCE
ALTER TABLE
ALTER SEQUENCE
ALTER TABLE
COPY 8
 setval
--------
      8
(1 row)

ALTER TABLE
```

* Перейдите в управляющую консоль `psql` внутри контейнера.

```bash
docker exec -it stack_postgres_1 psql -U postgres
```

* Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

```sql
postgres=# \c test_database;
You are now connected to database "test_database" as user "postgres".
test_database=# \dt
         List of relations
 Schema |  Name  | Type  |  Owner
--------+--------+-------+----------
 public | orders | table | postgres
(1 row)

test_database=# ANALYZE orders;
ANALYZE
```

* Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders`
с наибольшим средним значением размера элементов в байтах. **Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

```sql
SELECT MAX(avg_width) max_avg_width FROM pg_stats WHERE tablename = 'orders';
 max_avg_width
---------------
            16
(1 row)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

###### Ответ:

* Предложите SQL-транзакцию для проведения данной операции.

Шардируем `orders` на `orders_1` (price > 499) и `orders_2` (price <= 499)

```sql
BEGIN TRANSACTION;

CREATE TABLE public.orders_main (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
) PARTITION BY RANGE(price);

CREATE TABLE orders_1 PARTITION OF orders_main FOR VALUES FROM (500) TO (MAXVALUE);
CREATE TABLE orders_2 PARTITION OF orders_main FOR VALUES FROM (MINVALUE) TO (500);

INSERT INTO orders_main SELECT * FROM orders;

COMMIT;
```

```SQL
test_database=# SELECT * FROM orders_main;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
(8 rows)

test_database=# SELECT * FROM orders_1;
 id |       title        | price
----+--------------------+-------
  2 | My little database |   500
  6 | WAL never lies     |   900
  8 | Dbiezdmin          |   501
(3 rows)

test_database=# SELECT * FROM orders_2;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
(5 rows)

test_database=# \dt
                  List of relations
 Schema |    Name     |       Type        |  Owner
--------+-------------+-------------------+----------
 public | orders      | table             | postgres
 public | orders_1    | table             | postgres
 public | orders_2    | table             | postgres
 public | orders_main | partitioned table | postgres
(4 rows)
```

* Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

Да, это можно было бы сделать при создании таблицы.

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

###### Ответ:

* Используя утилиту `pg_dump` создайте бекап БД `test_database`.

```bash
docker exec -it stack_postgres_1 pg_dump -U postgres test_database -f /var/lib/postgresql/backups/test_database_backup.sql
```

* Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

Добавил бы свойство `UNIQUE`

Так делать нельзя, потому что это низкоуровневая операция, лучшее ее не использовать вручную.

```SQL
CREATE UNIQUE INDEX title_unique ON orders_main (title, price);
```

Нужно делать используя `ALTER TABLE`

```SQL
ALTER TABLE orders_1 ADD CONSTRAINT title_unique_1 UNIQUE (title);
ALTER TABLE orders_2 ADD CONSTRAINT title_unique_2 UNIQUE (title);

test_database=# SELECT * FROM orders_main;
 id |        title         | price
----+----------------------+-------
  1 | War and peace        |   100
  3 | Adventure psql time  |   300
  4 | Server gravity falls |   300
  5 | Log gossips          |   123
  7 | Me and my bash-pet   |   499
  2 | My little database   |   500
  6 | WAL never lies       |   900
  8 | Dbiezdmin            |   501
  9 | Letters from Earth   |   550
(9 rows)

test_database=# INSERT INTO orders_main (id, title, price) VALUES (10, 'Letters from Earth', 551);
ERROR:  duplicate key value violates unique constraint "title_unique_1"
DETAIL:  Key (title)=(Letters from Earth) already exists.
```

При попытке добавить `'Letters from Earth', 551` получили ошибку что ключ `title` не уникален.
