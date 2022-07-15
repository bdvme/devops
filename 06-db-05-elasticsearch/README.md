*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 6.5. Elasticsearch

## Задача 1

В этом задании вы потренируетесь в:
- установке elasticsearch
- первоначальном конфигурировании elastcisearch
- запуске elasticsearch в docker

Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

###### Ответ:

* Используя манифесты vagrant, ansible и docker была поднята виртуальная машина с развернутым в ней docker контейнером elasticsearch. Доступ к elasticsearch c хоста http://localhost:9092

* Dockerfile-манифест для elasticsearch

```bash
FROM centos:7

COPY elasticsearch-8.3.2-linux-x86_64.tar.gz .
COPY elasticsearch-8.3.2-linux-x86_64.tar.gz.sha512 .

RUN yum update -y && \
    yum install perl-Digest-SHA -y && \
    shasum -a 512 -c elasticsearch-8.3.2-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-8.3.2-linux-x86_64.tar.gz && \
    cd elasticsearch-8.3.2/ && \
    useradd elasticuser && \
    chown -R elasticuser:elasticuser /elasticsearch-8.3.2/ && \
    rm -fr /elasticsearch-8.3.2-linux-x86_64.tar.gz.sha512 /elasticsearch-8.3.2-linux-x86_64.tar.gz

RUN mkdir /var/lib/{data,logs} && \
    chown -R elasticuser:elasticuser /var/lib/data && \
    chown -R elasticuser:elasticuser /var/lib/logs

WORKDIR /elasticsearch-8.3.2
RUN mkdir snapshots && \
    chown -R elasticuser:elasticuser snapshots

ADD elasticsearch.yml /elasticsearch-8.3.2/config/
RUN chown -R elasticuser:elasticuser /elasticsearch-8.3.2/config

USER elasticuser

EXPOSE 9200 9300

CMD ["./bin/elasticsearch", "-Ecluster.name=netology_cluster", "-Enode.name=netology_test"]
```

* Ссылка на образ [elasticsearch](https://hub.docker.com/repository/docker/bdvme/elasticsearch) в репозитории dockerhub

* Ответ `elasticsearch` на запрос пути `/` в json виде

```bash
curl localhost:9092/
{
  "name" : "netology_test",
  "cluster_name" : "netology_cluster",
  "cluster_uuid" : "o-eLxTJKSbuoBDlRR-I8NQ",
  "version" : {
    "number" : "8.3.2",
    "build_type" : "tar",
    "build_hash" : "8b0b1f23fbebecc3c88e4464319dea8989f374fd",
    "build_date" : "2022-07-06T15:15:15.901688194Z",
    "build_snapshot" : false,
    "lucene_version" : "9.2.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```

## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html)
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

###### Ответ:

* Добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

  * PUT /ind-1
```bash
curl -X PUT "localhost:9092/ind-1?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0
    }
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-1"
}
```

  * PUT /ind-2
```bash
curl -X PUT "localhost:9092/ind-2?pretty" -H 'Content-Type: application/json' -d'
{
"settings": {
  "index": {
    "number_of_shards": 2,  
    "number_of_replicas": 1
  }
}
}
'
{
"acknowledged" : true,
"shards_acknowledged" : true,
"index" : "ind-2"
}
```

* PUT /ind-3
```bash
curl -X PUT "localhost:9092/ind-3?pretty" -H 'Content-Type: application/json' -d'
{
"settings": {
"index": {
  "number_of_shards": 4,  
  "number_of_replicas": 2
}
}
}
'
{
"acknowledged" : true,
"shards_acknowledged" : true,
"index" : "ind-3"
}
```

* Получите список индексов и их статусов

```bash
curl -X GET "localhost:9092/_cat/indices?v"
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   ind-1 AUUMc1oRS3i_cPT_kk60Jw   1   0          0            0       225b           225b
yellow open   ind-3 t88wIIStT8SkvhuoWmE9QA   4   2          0            0       900b           900b
yellow open   ind-2 JeLwW3KTRvGUxkuSJ76NOw   2   1          0            0       450b           450b
```

* Получите состояние кластера `elasticsearch`

```bash
curl -X GET "localhost:9092/_cluster/health?pretty"
{
  "cluster_name" : "netology_cluster",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
```

* Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

У индексов помеченых состоянием Yellow данные должны быть реплицированы, но в кластере всего одна нода, поэтому размещать их негде.

* Удалите все индексы.

```bash
curl -X DELETE "localhost:9092/_all"
{
  "acknowledged" : true
}
```

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository)
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html)
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее.

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

###### Ответ:

* Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

См. Dockerfile в задании 1

* Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository)
данную директорию как `snapshot repository` c именем `netology_backup`.

```bash
curl -X PUT "localhost:9092/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/elasticsearch-8.3.2/snapshots"
  }
}
'
{
  "acknowledged" : true
}
```

* Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

```bash
curl -X PUT "localhost:9092/test?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0
    }
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test"
}

curl -X GET "localhost:9092/_cat/indices?v"
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  twWOleJqQ9Wn4c_9CMu9CQ   1   0          0            0       225b           225b
```

* [Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html)
состояния кластера `elasticsearch`.

```bash
curl -X PUT "localhost:9092/_snapshot/netology_backup/snapshot_1?wait_for_completion=true&pretty"
{
  "snapshot" : {
    "snapshot" : "snapshot_1",
    "uuid" : "XmpgRk3rTYuzrCY82poAjQ",
    "repository" : "netology_backup",
    "version_id" : 8030299,
    "version" : "8.3.2",
    "indices" : [
      "test",
      ".geoip_databases"
    ],
    "data_streams" : [ ],
    "include_global_state" : true,
    "state" : "SUCCESS",
    "start_time" : "2022-07-11T11:16:30.953Z",
    "start_time_in_millis" : 1657538190953,
    "end_time" : "2022-07-11T11:16:33.960Z",
    "end_time_in_millis" : 1657538193960,
    "duration_in_millis" : 3007,
    "failures" : [ ],
    "shards" : {
      "total" : 2,
      "failed" : 0,
      "successful" : 2
    },
    "feature_states" : [
      {
        "feature_name" : "geoip",
        "indices" : [
          ".geoip_databases"
        ]
      }
    ]
  }
}
```

* список файлов в директории со `snapshot`ами.

```bash
docker exec -ti elasticsearch ls -la /elasticsearch-8.3.2/snapshots
total 48
drwxr-xr-x 1 elasticuser elasticuser  4096 Jul 11 11:16 .
drwxr-xr-x 1 elasticuser elasticuser  4096 Jul 11 09:59 ..
-rw-r--r-- 1 elasticuser elasticuser   843 Jul 11 11:16 index-0
-rw-r--r-- 1 elasticuser elasticuser     8 Jul 11 11:16 index.latest
drwxr-xr-x 4 elasticuser elasticuser  4096 Jul 11 11:16 indices
-rw-r--r-- 1 elasticuser elasticuser 18371 Jul 11 11:16 meta-XmpgRk3rTYuzrCY82poAjQ.dat
-rw-r--r-- 1 elasticuser elasticuser   352 Jul 11 11:16 snap-XmpgRk3rTYuzrCY82poAjQ.dat
```

* Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

```bash
curl -X DELETE "localhost:9092/test"
{"acknowledged":true}

curl -X PUT "localhost:9092/test-2?pretty" -H 'Content-Type: application/json' -d'
{
  "settings": {
    "index": {
      "number_of_shards": 1,  
      "number_of_replicas": 0
    }
  }
}
'
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}

curl -X GET "localhost:9092/_cat/indices?v"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 tXSq3SzaSFGf5oUpwiuxXQ   1   0          0            0       225b           225b
```

* [Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее.

```bash
curl -X POST "localhost:9092/_snapshot/netology_backup/snapshot_1/_restore?pretty"
{
  "accepted" : true
}

curl -X GET "localhost:9092/_cat/indices?v"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 tXSq3SzaSFGf5oUpwiuxXQ   1   0          0            0       225b           225b
green  open   test   JaO2x8bqQDqK8smANw9W4Q   1   0          0            0       225b           225b
```
