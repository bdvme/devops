*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 12.1.5 «Сетевое взаимодействие в K8S. Часть 2»

### Цель задания

В тестовой среде Kubernetes необходимо обеспечить доступ к двум приложениям снаружи кластера по разным путям.

------

### Чеклист готовности к домашнему заданию

1. Установленное k8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключённым Git-репозиторием.

------

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция](https://microk8s.io/docs/getting-started) по установке MicroK8S.
2. [Описание](https://kubernetes.io/docs/concepts/services-networking/service/) Service.
3. [Описание](https://kubernetes.io/docs/concepts/services-networking/ingress/) Ingress.
4. [Описание](https://github.com/wbitt/Network-MultiTool) Multitool.

------

### Задание 1. Создать Deployment приложений backend и frontend

1. Создать Deployment приложения _frontend_ из образа nginx с количеством реплик 3 шт.
2. Создать Deployment приложения _backend_ из образа multitool. 
3. Добавить Service, которые обеспечат доступ к обоим приложениям внутри кластера. 
4. Продемонстрировать, что приложения видят друг друга с помощью Service.
5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

------

### Задание 2. Создать Ingress и обеспечить доступ к приложениям снаружи кластера

1. Включить Ingress-controller в MicroK8S.
2. Создать Ingress, обеспечивающий доступ снаружи по IP-адресу кластера MicroK8S так, чтобы при запросе только по адресу открывался _frontend_ а при добавлении /api - _backend_.
3. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
4. Предоставить манифесты и скриншоты или вывод команды п.2.

------
###### Ответ:

### Задание 1. Создать Deployment приложений backend и frontend

1. Создать Deployment приложения _frontend_ из образа nginx с количеством реплик 3 шт.
2. Создать Deployment приложения _backend_ из образа multitool. 
3. Добавить Service, которые обеспечат доступ к обоим приложениям внутри кластера. 
4. Продемонстрировать, что приложения видят друг друга с помощью Service.
5. Предоставить манифесты Deployment и Service в решении, а также скриншоты или вывод команды п.4.

<details> 
<summary>deployment-front</summary>
<pre><code>
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: frontend
  namespace: default
spec:
  replicas: 3
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: nginx
          image: nginx
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  selector:
    app: frontend
  ports:
    - name: frontend-port
      protocol: TCP
      port: 9001
      targetPort: 80
</code></pre>
</details> 

<details> 
<summary>deployment-back</summary>
<pre><code>
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels:
    app: backend
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
        - name: multitool
          image: wbitt/network-multitool
---
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  selector:
    app: backend
  ports:
    - name: backend-port
      protocol: TCP
      port: 9002
      targetPort: 80        
</code></pre>
</details>

Применяем манифесты

```bash
vagrant@server01:~$ kubectl apply -f deployment-back.yml,deployment-front.yml 
deployment.apps/backend created
service/backend created
deployment.apps/frontend created
service/frontend created
```

Проверяем статусы

```bash
vagrant@server01:~$ kubectl get deployment,svc,pods
NAME                       READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/backend    1/1     1            1           45s
deployment.apps/frontend   3/3     3            3           44s

NAME                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
service/kubernetes   ClusterIP   10.152.183.1     <none>        443/TCP    3h2m
service/backend      ClusterIP   10.152.183.188   <none>        9002/TCP   45s
service/frontend     ClusterIP   10.152.183.190   <none>        9001/TCP   44s

NAME                          READY   STATUS    RESTARTS   AGE
pod/backend-6c666c55f-x9kh4   1/1     Running   0          44s
pod/frontend-bcc4d676-p9klc   1/1     Running   0          44s
pod/frontend-bcc4d676-48f28   1/1     Running   0          44s
pod/frontend-bcc4d676-hvp5s   1/1     Running   0          44s
```

Доступность к приложению `backend`

```bash
vagrant@server01:~$ kubectl exec pod/backend-6c666c55f-x9kh4 -- curl backend:9002
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
  WBITT Network MultiTool (with NGINX) - backend-6c666c55f-x9kh4 - 10.1.188.43 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
100   139  100   139    0     0  20414      0 --:--:-- --:--:-- --:--:-- 23166
```

Доступность к приложению `frontend`

```bash
vagrant@server01:~$ kubectl exec pod/frontend-bcc4d676-p9klc -- curl frontend:9001
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0<!DOCTYPE html>
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
100   615  100   615    0     0  26082      0 --:--:-- --:--:-- --:--:-- 26739
```

### Задание 2. Создать Ingress и обеспечить доступ к приложениям снаружи кластера

1. Включить Ingress-controller в MicroK8S.
2. Создать Ingress, обеспечивающий доступ снаружи по IP-адресу кластера MicroK8S так, чтобы при запросе только по адресу открывался _frontend_ а при добавлении /api - _backend_.
3. Продемонстрировать доступ с помощью браузера или `curl` с локального компьютера.
4. Предоставить манифесты и скриншоты или вывод команды п.2.

<details> 
<summary>ingress</summary>
<pre><code>
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
  - host:
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              name: frontend-port
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: backend
            port:
              name: backend-port        
</code></pre>
</details>

Включаем ingress-controller

```bash
vagrant@server01:~$ microk8s enable ingress
```

Применяем манифест

```bash
vagrant@server01:~$ kubectl apply -f ingress.yml
ingress.networking.k8s.io/example-ingress created
vagrant@server01:~$ kubectl get ingress
NAME              CLASS    HOSTS   ADDRESS     PORTS   AGE
example-ingress   public   *       127.0.0.1   80      14m
```

#### VM

Доступность `frontend`

```bash
vagrant@server01:~$ curl localhost
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

Доступность `backend`

```bash
vagrant@server01:~$ curl localhost/api
WBITT Network MultiTool (with NGINX) - backend-6c666c55f-x9kh4 - 10.1.188.43 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
```

#### Local PC

Доступность `frontend`

```bash
❯ curl 192.168.99.101
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

Доступность `backend`

```bash
❯ curl 192.168.99.101/api
WBITT Network MultiTool (with NGINX) - backend-6c666c55f-x9kh4 - 10.1.188.43 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
```