*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 12.1.4 «Сетевое взаимодействие в K8S. Часть 1»

### Цель задания

В тестовой среде Kubernetes необходимо обеспечить доступ к приложению, установленному в предыдущем ДЗ и состоящему из двух контейнеров, по разным портам в разные контейнеры как внутри кластера, так и снаружи.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Описание](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) Deployment и примеры манифестов.
2. [Описание](https://kubernetes.io/docs/concepts/services-networking/service/) Описание Service.
3. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера

1. Создать Deployment приложения, состоящего из двух контейнеров (nginx и multitool), с количеством реплик 3 шт.
2. Создать Service, который обеспечит доступ внутри кластера до контейнеров приложения из п.1 по порту 9001 — nginx 80, по 9002 — multitool 8080.
3. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложения из п.1 по разным портам в разные контейнеры.
4. Продемонстрировать доступ с помощью `curl` по доменному имени сервиса.
5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

------

### Задание 2. Создать Service и обеспечить доступ к приложениям снаружи кластера

1. Создать отдельный Service приложения из Задания 1 с возможностью доступа снаружи кластера к nginx, используя тип NodePort.
2. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
3. Предоставить манифест и Service в решении, а также скриншоты или вывод команды п.2.

------
###### Ответ:

### Задание 1. Создать Deployment и обеспечить доступ к контейнерам приложения по разным портам из другого Pod внутри кластера

1. Создать Deployment приложения, состоящего из двух контейнеров (nginx и multitool), с количеством реплик 3 шт.
2. Создать Service, который обеспечит доступ внутри кластера до контейнеров приложения из п.1 по порту 9001 — nginx 80, по 9002 — multitool 8080.
3. Создать отдельный Pod с приложением multitool и убедиться с помощью `curl`, что из пода есть доступ до приложения из п.1 по разным портам в разные контейнеры.
4. Продемонстрировать доступ с помощью `curl` по доменному имени сервиса.
5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

<details> 
<summary>deployment-app</summary>
<pre><code>
apiVersion: apps/v1
kind: Deployment
metadata:
  name: application
spec:
  replicas: 3
  selector:
    matchLabels:
      app: application
  template:
    metadata:
      labels:
        app: application
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
      - name: multitool
        image: wbitt/network-multitool
        env:
        - name: HTTP_PORT
          value: "8080"
        - name: HTTPS_PORT
          value: "8443"
        ports:
        - containerPort: 8080
          name: http-port
        - containerPort: 8443
          name: https-port 
</code></pre>
</details>

```bash
vagrant@server01:~$ kubectl apply -f ./deployment.yml 
deployment.apps/application created
vagrant@server01:~$ kubectl get deployment
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
application   3/3     3            3           2m12s
```

<details> 
<summary>service-app</summary>
<pre><code>
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  selector:
    app: application
  ports:
    - name: nginx-port
      protocol: TCP
      port: 9001
      targetPort: 80
    - name: multitool-port
      protocol: TCP
      port: 9002
      targetPort: 8080
</code></pre>
</details>

```bash
vagrant@server01:~$ kubectl apply -f ./service.yml 
service/app-service created
vagrant@server01:~$ kubectl get service
NAME          TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)             AGE
kubernetes    ClusterIP   10.152.183.1     <none>        443/TCP             30m
app-service   ClusterIP   10.152.183.171   <none>        9001/TCP,9002/TCP   2m29s
```

<details> 
<summary>pod</summary>
<pre><code>
apiVersion: v1
kind: Pod
metadata:
  name: multitool
spec:
  containers:
  - name: multitool
    image: wbitt/network-multitool
</code></pre>
</details>

```bash
vagrant@server01:~$ kubectl apply -f ./pod.yml 
pod/multitool created
vagrant@server01:~$ kubectl get pod
NAME                          READY   STATUS    RESTARTS   AGE
application-894c4b8b8-bd7lq   2/2     Running   0          2m53s
application-894c4b8b8-xkjnq   2/2     Running   0          2m53s
application-894c4b8b8-8g6mp   2/2     Running   0          2m53s
multitool                     1/1     Running   0          2m37s
```

Nginx 

`curl app-service:9001`

```bash
vagrant@server01:~$ kubectl exec -it pod/multitool -- curl app-service:9001
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

WBITT Network MultiTool 

`curl app-service:9002`

```bash
vagrant@server01:~$ kubectl exec -it pod/multitool -- curl app-service:9002
WBITT Network MultiTool (with NGINX) - application-894c4b8b8-bd7lq - 10.1.188.13 - HTTP: 8080 , HTTPS: 8443 . (Formerly praqma/network-multitool)
vagrant@server01:~$ 
```

#### Доступ по доменному имени сервиса

`curl app-service.default.svc.cluster.local:port`

Nginx 

`curl app-service.default.svc.cluster.local:9001`

```bash
vagrant@server01:~$ kubectl exec -it pod/multitool -- curl app-service.default.svc.cluster.local:9001
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

WBITT Network MultiTool 

`curl app-service.default.svc.cluster.local:9002`

```bash
vagrant@server01:~$ kubectl exec -it pod/multitool -- curl app-service.default.svc.cluster.local:9002
WBITT Network MultiTool (with NGINX) - application-894c4b8b8-xkjnq - 10.1.188.14 - HTTP: 8080 , HTTPS: 8443 . (Formerly praqma/network-multitool)
```

### Задание 2. Создать Service и обеспечить доступ к приложениям снаружи кластера

1. Создать отдельный Service приложения из Задания 1 с возможностью доступа снаружи кластера к nginx, используя тип NodePort.
2. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
3. Предоставить манифест и Service в решении, а также скриншоты или вывод команды п.2.

<details> 
<summary>service-node</summary>
<pre><code>
apiVersion: v1
kind: Service
metadata:
  name: app-external-service
spec:
  type: NodePort
  selector:
    app: application
  ports:
    - name: nginx-port
      protocol: TCP
      port: 9001
      targetPort: 80
    - name: multitool-port
      protocol: TCP
      port: 9002
      targetPort: 8080
</code></pre>
</details>

#### VM

```bash
vagrant@server01:~$ kubectl apply -f ./service-node.yml 
service/app-external-service created
vagrant@server01:~$ kubectl get svc
NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                         AGE
kubernetes             ClusterIP   10.152.183.1     <none>        443/TCP                         39m
app-service            ClusterIP   10.152.183.171   <none>        9001/TCP,9002/TCP               11m
app-external-service   NodePort    10.152.183.38    <none>        9001:30372/TCP,9002:31975/TCP   13s
```

#### Local PC

Nginx 

`curl 192.168.99.101:30372`

```bash
❯ curl 192.168.99.101:30372
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

WBITT Network MultiTool 

`curl 192.168.99.101:31975`

```bash
❯ curl 192.168.99.101:31975
WBITT Network MultiTool (with NGINX) - application-894c4b8b8-bd7lq - 10.1.188.13 - HTTP: 8080 , HTTPS: 8443 . (Formerly praqma/network-multitool)
```