*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 13.5 Troubleshooting

### Цель задания

Устранить неисправности при деплое приложения.

### Чеклист готовности к домашнему заданию

1. Кластер K8s.

### Задание. При деплое приложение web-consumer не может подключиться к auth-db. Необходимо это исправить

1. Установить приложение по команде:
```shell
kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
```
2. Выявить проблему и описать.
3. Исправить проблему, описать, что сделано.
4. Продемонстрировать, что проблема решена.


### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

----
###### Ответ:

### Задание. При деплое приложение web-consumer не может подключиться к auth-db. Необходимо это исправить

1. Установить приложение по команде:
```shell
kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
```
2. Выявить проблему и описать.
3. Исправить проблему, описать, что сделано.
4. Продемонстрировать, что проблема решена.

Запуск манифеста (отсутствуют `namespace` `data` и `web`):

```bash
vagrant@server01:~$ kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
Error from server (NotFound): error when creating "https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml": namespaces "web" not found
Error from server (NotFound): error when creating "https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml": namespaces "data" not found
Error from server (NotFound): error when creating "https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml": namespaces "data" not found
vagrant@server01:~$
```

Создадим манифест `namespaces.yml`

<details> 
<summary>namespaces.yml</summary>
<pre><code class="language-yaml">
kind: Namespace
apiVersion: v1
metadata:
  name: data
  labels:
    name: data
---
kind: Namespace
apiVersion: v1
metadata:
  name: web
  labels:
    name: web
</code></pre>
</details>

Применим манифест `namespaces.yml`

```bash
vagrant@server01:~$ kubectl apply -f ./manifests/namespaces.yml 
namespace/data created
namespace/web created
```

Заново применяем манифест из задания:

```bash
vagrant@server01:~$ kubectl apply -f https://raw.githubusercontent.com/netology-code/kuber-homeworks/main/3.5/files/task.yaml
deployment.apps/web-consumer created
deployment.apps/auth-db created
service/auth-db created
vagrant@server01:~$
```

Проверим `all` в `namespace` `web`:

```bash
vagrant@server01:~$ kubectl get all -n web
NAME                                READY   STATUS    RESTARTS   AGE
pod/web-consumer-84fc79d94d-wdbln   1/1     Running   0          11s
pod/web-consumer-84fc79d94d-j4vf5   1/1     Running   0          11s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/web-consumer   2/2     2            2           11s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/web-consumer-84fc79d94d   2         2         2       11s
vagrant@server01:~$ 
```

Проверим `all` в `namespace` `data`:

```bash
vagrant@server01:~$ kubectl get all -n data
NAME                           READY   STATUS    RESTARTS   AGE
pod/auth-db-864ff9854c-xg99m   1/1     Running   0          40s

NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/auth-db   ClusterIP   10.152.183.87   <none>        80/TCP    40s

NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/auth-db   1/1     1            1           40s

NAME                                 DESIRED   CURRENT   READY   AGE
replicaset.apps/auth-db-864ff9854c   1         1         1       40s
vagrant@server01:~$
```

Проверим логи `svc/auth-db` в `namespace` `data`:

```bash
vagrant@server01:~$ kubectl logs -n data svc/auth-db
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
vagrant@server01:~$
```

Проверим логи `deployment/web-consumer` в `namespace` `web` (нет доступа к хосту `auth-db`):

```bash
vagrant@server01:~$ kubectl logs -n web deployment/web-consumer
Found 2 pods, using pod/web-consumer-84fc79d94d-wdbln
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
vagrant@server01:~$ 
```

Создадим манифест для доступа к `auth-db` с параметром `externalName: auth-db.data.svc.cluster.local` в `namespace` `web`

<details> 
<summary>service.yml</summary>
<pre><code class="language-yaml">
apiVersion: v1
kind: Service
metadata:
  name: auth-db
  namespace: web
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  type: ExternalName
  externalName: auth-db.data.svc.cluster.local
</code></pre>
</details>

Применяем манифест `service.yml`

```bash
vagrant@server01:~$ kubectl apply -f ./manifests/service.yml 
service/auth-db created
vagrant@server01:~$ 
```

Проверим `all` в `namespace` `web`:

```bash
vagrant@server01:~$ kubectl get all -n web
NAME                                READY   STATUS    RESTARTS   AGE
pod/web-consumer-84fc79d94d-wdbln   1/1     Running   0          2m28s
pod/web-consumer-84fc79d94d-j4vf5   1/1     Running   0          2m28s

NAME              TYPE           CLUSTER-IP   EXTERNAL-IP                      PORT(S)   AGE
service/auth-db   ExternalName   <none>       auth-db.data.svc.cluster.local   80/TCP    24s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/web-consumer   2/2     2            2           2m28s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/web-consumer-84fc79d94d   2         2         2       2m28s
vagrant@server01:~$ 
```

Проверим логи `deployment/web-consumer` в `namespace` `web` (появился доступ к хосту `auth-db`):

```bash
vagrant@server01:~$ kubectl logs -n web deployment/web-consumer
Found 2 pods, using pod/web-consumer-84fc79d94d-wdbln
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
curl: (6) Couldn't resolve host 'auth-db'
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0   194k      0 --:--:-- --:--:-- --:--:--  597k
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```