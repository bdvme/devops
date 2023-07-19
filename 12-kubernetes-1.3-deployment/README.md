*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 12.1.3 «Запуск приложений в K8S»

### Цель задания

В тестовой среде для работы с Kubernetes, установленной в предыдущем ДЗ, необходимо развернуть Deployment с приложением, состоящим из нескольких контейнеров, и масштабировать его.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) Init-контейнеров.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

1. Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Решить возникшую ошибку.
2. После запуска увеличить количество реплик работающего приложения до 2.
3. Продемонстрировать количество подов до и после масштабирования.
4. Создать Service, который обеспечит доступ до реплик приложений из п.1.
5. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложений из п.1.

------

### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения.
2. Убедиться, что nginx не стартует. В качестве Init-контейнера взять busybox.
3. Создать и запустить Service. Убедиться, что Init запустился.
4. Продемонстрировать состояние пода до и после запуска сервиса.

------
###### Ответ:

### Задание 1. Создать Deployment и обеспечить доступ к репликам приложения из другого Pod

1. Создать Deployment приложения, состоящего из двух контейнеров — nginx и multitool. Решить возникшую ошибку.
2. После запуска увеличить количество реплик работающего приложения до 2.
3. Продемонстрировать количество подов до и после масштабирования.
4. Создать Service, который обеспечит доступ до реплик приложений из п.1.
5. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложений из п.1.

[deployment.yml](./src/deployment.yml)

```bash
vagrant@server01:~$ kubectl apply -f ./deployment.yml
deployment.apps/application created
```

Ошибка в том, что оба контейнера по умолчанию используют порт 80.
С помощью переменных окружения поменяв стандартный порт 80 на 1180 в контейнере network-multitool, проблема была решена.

```yaml
env:
  - name: HTTP_PORT
    value: "1180"
  - name: HTTPS_PORT
    value: "11443"
```

Количество Pod до масштабирования

```bash
vagrant@server01:~$ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
application-77b96545c6-r2gtd   2/2     Running   0          6m6s
```


Меняем количество реплик командой:

```bash
vagrant@server01:~$ kubectl scale deployment application --replicas=2
deployment.apps/application scaled
```

Количество Pod после масштабирования

```bash
vagrant@server01:~$ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
application-77b96545c6-r2gtd   2/2     Running   0          15m
application-77b96545c6-jh897   2/2     Running   0          27s
```

сервис для доступа к репликам приложений из п.1

[service](./src/service.yml)

```bash
vagrant@server01:~$ kubectl apply -f ./service.yml
service/app-service created
vagrant@server01:~$ kubectl get services
NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
kubernetes    ClusterIP   10.152.183.1     <none>        443/TCP   38m
app-service   ClusterIP   10.152.183.136   <none>        80/TCP    6m48s
vagrant@server01:~$ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
application-77b96545c6-r2gtd   2/2     Running   0          37m
application-77b96545c6-jh897   2/2     Running   0          21m
```

Отдельный Pod с приложением multitool

```bash
vagrant@server01:~$ kubectl run multitool --image=wbitt/network-multitool --restart=Never
pod/multitool created
vagrant@server01:~$ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
application-77b96545c6-r2gtd   2/2     Running   0          37m
application-77b96545c6-jh897   2/2     Running   0          22m
multitool                      1/1     Running   0          5s
```

Проверяем что есть доступ до приложений из п.1

```bash
vagrant@server01:~$ kubectl exec -it multitool -- curl app-service
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
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

### Задание 2. Создать Deployment и обеспечить старт основного контейнера при выполнении условий

1. Создать Deployment приложения nginx и обеспечить старт контейнера только после того, как будет запущен сервис этого приложения.
2. Убедиться, что nginx не стартует. В качестве Init-контейнера взять busybox.
3. Создать и запустить Service. Убедиться, что Init запустился.
4. Продемонстрировать состояние пода до и после запуска сервиса.

[nginx-deployment](./src/nginx-dep.yml)

```bash
vagrant@server01:~$ kubectl apply -f nginx-dep.yml
deployment.apps/nginx-deployment created
vagrant@server01:~$ kubectl get pods
NAME                               READY   STATUS     RESTARTS   AGE
nginx-deployment-6cdbd56f4-kmnd5   0/1     Init:0/1   0          4m50s
```

создаем и запускаем service

[nginx-service](./src/nginx-service.yml)

```bash
vagrant@server01:~$ kubectl apply -f ./nginx-service.yml
service/nginx-service created
vagrant@server01:~$ kubectl get pods
NAME                               READY   STATUS            RESTARTS   AGE
nginx-deployment-6cdbd56f4-kmnd5   0/1     PodInitializing   0          6m2s
vagrant@server01:~$ kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
nginx-deployment-6cdbd56f4-kmnd5   1/1     Running   0          6m10s
```
