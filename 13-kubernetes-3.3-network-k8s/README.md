*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 13.3 «Как работает сеть в K8s»

### Цель задания

Настроить сетевую политику доступа к подам.

### Чеклист готовности к домашнему заданию

1. Кластер K8s с установленным сетевым плагином Calico.

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация Calico](https://www.tigera.io/project-calico/).
2. [Network Policy](https://kubernetes.io/docs/concepts/services-networking/network-policies/).
3. [About Network Policy](https://docs.projectcalico.org/about/about-network-policy).

-----

### Задание 1. Создать сетевую политику или несколько политик для обеспечения доступа

1. Создать deployment'ы приложений frontend, backend и cache и соответсвующие сервисы.
2. В качестве образа использовать network-multitool.
3. Разместить поды в namespace App.
4. Создать политики, чтобы обеспечить доступ frontend -> backend -> cache. Другие виды подключений должны быть запрещены.
5. Продемонстрировать, что трафик разрешён и запрещён.

### Правила приёма работы

1. Домашняя работа оформляется в своём Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

----
###### Ответ:

### Задание 1. Создать сетевую политику или несколько политик для обеспечения доступа

1. Создать deployment'ы приложений frontend, backend и cache и соответсвующие сервисы.
2. В качестве образа использовать network-multitool.
3. Разместить поды в namespace App.
4. Создать политики, чтобы обеспечить доступ frontend -> backend -> cache. Другие виды подключений должны быть запрещены.
5. Продемонстрировать, что трафик разрешён и запрещён.

Для выполнения задания использовал ВМ с установленным mikrok8s

Манифесты:

<details> 
<summary>namespace.yml</summary>
<pre><code class="language-yaml">
kind: Namespace
apiVersion: v1
metadata:
  name: app
  labels:
    name: app
</code></pre>
</details>

<details> 
<summary>deployment-frontend.yml</summary>
<pre><code>
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels:
    app: frontend
  namespace: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: multitool
          image: wbitt/network-multitool
          imagePullPolicy: IfNotPresent
      terminationGracePeriodSeconds: 30
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: app
spec:
  selector:
    app: frontend
  ports:
    - name: frontend-port
      protocol: TCP
      port: 80    
</code></pre>
</details>

<details> 
<summary>deployment-backend.yml</summary>
<pre><code>
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels:
    app: backend
  namespace: app
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
          imagePullPolicy: IfNotPresent
      terminationGracePeriodSeconds: 30
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: app
spec:
  selector:
    app: backend
  ports:
    - name: backend-port
      protocol: TCP
      port: 80
</code></pre>
</details>

<details> 
<summary>deployment-cache.yml</summary>
<pre><code>
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cache
  labels:
    app: cache
  namespace: app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: cache
  template:
    metadata:
      labels:
        app: cache
    spec:
      containers:
        - name: multitool
          image: wbitt/network-multitool
          imagePullPolicy: IfNotPresent
      terminationGracePeriodSeconds: 30
---
apiVersion: v1
kind: Service
metadata:
  name: cache
  namespace: app
spec:
  selector:
    app: cache
  ports:
    - name: cache-port
      protocol: TCP
      port: 80    
</code></pre>
</details>

<details> 
<summary>network-policy.yml</summary>
<pre><code>
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
  namespace: app
spec:
  podSelector: {}
  policyTypes:
    - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: front-to-back
  namespace: app
spec:
  podSelector: 
    matchLabels:
      app: backend
  policyTypes:
    - Ingress
  ingress:
    - from:
      - podSelector:
          matchLabels:
            app: frontend
      ports:
        - protocol: TCP
          port: 80
        - protocol: TCP
          port: 443
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: back-to-cache
  namespace: app
spec:
  podSelector: 
    matchLabels:
      app: cache
  policyTypes:
    - Ingress
  ingress:
    - from:
      - podSelector:
          matchLabels:
            app: backend
      ports:
        - protocol: TCP
          port: 80
        - protocol: TCP
          port: 443
</code></pre>
</details>

Проверим `pods` во всех `namespaces`

```bash
vagrant@server01:~$ kubectl get pods --all-namespaces
NAMESPACE            NAME                                         READY   STATUS    RESTARTS       AGE
kube-system          dashboard-metrics-scraper-5cb4f4bb9c-cm8bz   1/1     Running   1 (29m ago)    40m
container-registry   registry-9865b655c-wdbx6                     1/1     Running   1 (29m ago)    40m
kube-system          kubernetes-dashboard-fc86bcc89-w2fqg         1/1     Running   1 (29m ago)    40m
kube-system          calico-kube-controllers-6c99c8747f-s29cz     1/1     Running   1 (29m ago)    41m
kube-system          coredns-7745f9f87f-m49x9                     1/1     Running   1 (29m ago)    41m
kube-system          calico-node-gmckg                            1/1     Running   1 (29m ago)    41m
kube-system          metrics-server-7747f8d66b-phvrt              1/1     Running   2 (28m ago)    40m
kube-system          hostpath-provisioner-58694c9f4b-6bk96        1/1     Running   3 (108s ago)   40m
vagrant@server01:~$ 
```

Применяем манифесты:

```bash
vagrant@server01:~$ kubectl apply -f ./manifests/namespace.yml 
namespace/app created
vagrant@server01:~$ kubectl apply -f ./manifests/deployment-back.yml 
deployment.apps/backend created
service/backend created
vagrant@server01:~$ kubectl apply -f ./manifests/deployment-front.yml 
deployment.apps/frontend created
service/frontend created
vagrant@server01:~$ kubectl apply -f ./manifests/deployment-cache.yml 
deployment.apps/cache created
service/cache created
vagrant@server01:~$ 
```

Применяем сетевую политику:

```bash
vagrant@server01:~$ kubectl apply -f ./manifests/network-policy.yml 
networkpolicy.networking.k8s.io/default-deny-ingress created
networkpolicy.networking.k8s.io/front-to-back created
networkpolicy.networking.k8s.io/back-to-cache created
vagrant@server01:~$
```

Проверяем сетевые политики в `namespace` `app`

```bash
vagrant@server01:~$ kubectl get networkpolicy -n app
NAME                   POD-SELECTOR   AGE
default-deny-ingress   <none>         8s
front-to-back          app=backend    8s
back-to-cache          app=cache      8s
vagrant@server01:~$
```

Проверим `pods` в `namespace` `app` с флагом `wide`:

```bash
vagrant@server01:~$ kubectl get pods -n app -o wide
NAME                        READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
cache-5f667f6675-mjspf      1/1     Running   0          40s   10.1.188.24   server01   <none>           <none>
backend-58979d9689-s8z4w    1/1     Running   0          40s   10.1.188.22   server01   <none>           <none>
frontend-58767476c7-ng7rd   1/1     Running   0          40s   10.1.188.23   server01   <none>           <none>
vagrant@server01:~$ 
```

Проверим `service` в `namespace` `app`:

```bash
vagrant@server01:~$ kubectl get svc -n app
NAME       TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
frontend   ClusterIP   10.152.183.121   <none>        80/TCP    84s
backend    ClusterIP   10.152.183.186   <none>        80/TCP    78s
cache      ClusterIP   10.152.183.34    <none>        80/TCP    73s
vagrant@server01:~$ 
```

Проверим доступность сервисов по маршруту `frontend -> backend -> cache`:

```bash
vagrant@server01:~$ kubectl exec -n app svc/frontend -- curl backend
WBITT Network MultiTool (with NGINX) - backend-58979d9689-s8z4w - 10.1.188.22 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   140  100   140    0     0  79863      0 --:--:-- --:--:-- --:--:--  136k
```

```bash
vagrant@server01:~$ kubectl exec -n app svc/backend -- curl cache
WBITT Network MultiTool (with NGINX) - cache-5f667f6675-mjspf - 10.1.188.24 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   138  100   138    0     0  17166      0 --:--:-- --:--:-- --:--:-- 23000
vagrant@server01:~$
```

Проверим запрет на доступ к сервисам по другим маршрутам:

`frontend -> cache`:

```bash
vagrant@server01:~$ kubectl exec -n app svc/frontend -- curl cache
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:04 --:--:--     0^C
vagrant@server01:~$ 
```

`backend -> frontend`:

```bash
vagrant@server01:~$ kubectl exec -n app svc/backend -- curl frontend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:04 --:--:--     0^C
vagrant@server01:~$
```

`cache -> frontend`:

```bash
vagrant@server01:~$ kubectl exec -n app svc/cache -- curl frontend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:03 --:--:--     0^C
vagrant@server01:~$
```

`cache -> backend`:

```bash
vagrant@server01:~$ kubectl exec -n app svc/cache -- curl backend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:03 --:--:--     0^C
vagrant@server01:~$ 
```
