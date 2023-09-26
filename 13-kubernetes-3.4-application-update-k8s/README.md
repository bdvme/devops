*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 13.4 «Обновление приложений»

### Цель задания

Выбрать и настроить стратегию обновления приложения.

### Чеклист готовности к домашнему заданию

1. Кластер K8s.

### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Документация Updating a Deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#updating-a-deployment).
2. [Статья про стратегии обновлений](https://habr.com/ru/companies/flant/articles/471620/).

-----

### Задание 1. Выбрать стратегию обновления приложения и описать ваш выбор

1. Имеется приложение, состоящее из нескольких реплик, которое требуется обновить.
2. Ресурсы, выделенные для приложения, ограничены, и нет возможности их увеличить.
3. Запас по ресурсам в менее загруженный момент времени составляет 20%.
4. Обновление мажорное, новые версии приложения не умеют работать со старыми.
5. Вам нужно объяснить свой выбор стратегии обновления приложения.

### Задание 2. Обновить приложение

1. Создать deployment приложения с контейнерами nginx и multitool. Версию nginx взять 1.19. Количество реплик — 5.
2. Обновить версию nginx в приложении до версии 1.20, сократив время обновления до минимума. Приложение должно быть доступно.
3. Попытаться обновить nginx до версии 1.28, приложение должно оставаться доступным.
4. Откатиться после неудачного обновления.

## Дополнительные задания — со звёздочкой*

Задания дополнительные, необязательные к выполнению, они не повлияют на получение зачёта по домашнему заданию. **Но мы настоятельно рекомендуем вам выполнять все задания со звёздочкой.** Это поможет лучше разобраться в материале.   

### Задание 3*. Создать Canary deployment

1. Создать два deployment'а приложения nginx.
2. При помощи разных ConfigMap сделать две версии приложения — веб-страницы.
3. С помощью ingress создать канареечный деплоймент, чтобы можно было часть трафика перебросить на разные версии приложения.

### Правила приёма работы

1. Домашняя работа оформляется в своем Git-репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд, а также скриншоты результатов.
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md.

----
###### Ответ:

### Задание 1. Выбрать стратегию обновления приложения и описать ваш выбор

1. Имеется приложение, состоящее из нескольких реплик, которое требуется обновить.
2. Ресурсы, выделенные для приложения, ограничены, и нет возможности их увеличить.
3. Запас по ресурсам в менее загруженный момент времени составляет 20%.
4. Обновление мажорное, новые версии приложения не умеют работать со старыми.
5. Вам нужно объяснить свой выбор стратегии обновления приложения.

* Так как обновления приложения мажорные одновременно заменяем все реплики приложения. Исходя из пунктов 3 и 2 проблема с увеличением ресурсов, запас ограничен. Выбираю стратегию обновления - `Recreate`. При такой стратегии не надо использовать дополнительные ресурсы. Старые реплики будут удалены. Необходимо выбрать время когда будет минимальная нагрузка, в основном это ночное время и заранее предупредить о технических работах на кластере.

### Задание 2. Обновить приложение

1. Создать deployment приложения с контейнерами nginx и multitool. Версию nginx взять 1.19. Количество реплик — 5.
2. Обновить версию nginx в приложении до версии 1.20, сократив время обновления до минимума. Приложение должно быть доступно.
3. Попытаться обновить nginx до версии 1.28, приложение должно оставаться доступным.
4. Откатиться после неудачного обновления.

Для выполнения задания использовал ВМ с установленным mikrok8s

Манифест:

<details> 
<summary>deployment.yml</summary>
<pre><code class="language-yaml">
kind: Namespace
apiVersion: v1
metadata:
  name: app
  labels:
    name: app
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: application
  name: application
  namespace: app
spec:
  replicas: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
       maxSurge: 0
       maxUnavailable: 20% 
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
        image: nginx:1.19
        ports:
        - containerPort: 80
      - name: multitool
        image: wbitt/network-multitool
        env:
        - name: HTTP_PORT
          value: "1180"
        - name: HTTPS_PORT
          value: "11443"
        ports:
        - containerPort: 1180
          name: http-port
        - containerPort: 11443
          name: https-port
---
apiVersion: v1
kind: Service
metadata:
  name: application
  namespace: app
spec:
  selector:
    app: application
  ports:
    - name: http
      port: 80
      targetPort: 80
</code></pre>
</details>

Проверим `pods` во всех `namespaces`

```bash
vagrant@server01:~$ kubectl get pods --all-namespaces
NAMESPACE            NAME                                         READY   STATUS    RESTARTS   AGE
kube-system          calico-node-xnmbl                            1/1     Running   0          3m26s
kube-system          calico-kube-controllers-6c99c8747f-z8fjp     1/1     Running   0          3m26s
kube-system          coredns-7745f9f87f-ln6rf                     1/1     Running   0          3m26s
kube-system          metrics-server-7747f8d66b-7rvtr              1/1     Running   0          2m47s
kube-system          kubernetes-dashboard-fc86bcc89-gw7fv         1/1     Running   0          2m45s
kube-system          dashboard-metrics-scraper-5cb4f4bb9c-j52rh   1/1     Running   0          2m44s
kube-system          hostpath-provisioner-58694c9f4b-44tpd        1/1     Running   0          2m42s
container-registry   registry-9865b655c-d4vmj                     1/1     Running   0          2m40s
vagrant@server01:~$ 
```

Применяем манифест:

```bash
vagrant@server01:~$ kubectl apply -f ./manifests/deployment.yml 
namespace/app created
deployment.apps/application created
service/application created
vagrant@server01:~$ 
```

Проверим `all` в `namespace` `app` с флагом `wide`:

```bash
vagrant@server01:~$ kubectl get all -n app -o wide
NAME                               READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
pod/application-68d558cb88-mj8jm   2/2     Running   0          11s   10.1.188.57   server01   <none>           <none>
pod/application-68d558cb88-nllt6   2/2     Running   0          11s   10.1.188.58   server01   <none>           <none>
pod/application-68d558cb88-mvxkx   2/2     Running   0          11s   10.1.188.59   server01   <none>           <none>
pod/application-68d558cb88-fg5m4   2/2     Running   0          11s   10.1.188.60   server01   <none>           <none>
pod/application-68d558cb88-q7nxc   2/2     Running   0          11s   10.1.188.61   server01   <none>           <none>

NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/application   ClusterIP   10.152.183.152   <none>        80/TCP    11s   app=application

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS        IMAGES                               SELECTOR
deployment.apps/application   5/5     5            5           11s   nginx,multitool   nginx:1.19,wbitt/network-multitool   app=application

NAME                                     DESIRED   CURRENT   READY   AGE   CONTAINERS        IMAGES                               SELECTOR
replicaset.apps/application-68d558cb88   5         5         5       11s   nginx,multitool   nginx:1.19,wbitt/network-multitool   app=application,pod-template-hash=68d558cb88 
```

Заменяем версию `nginx` на `1.20`:

```bash
vagrant@server01:~$ kubectl set image deployment/application nginx=nginx:1.20 -n app
deployment.apps/application image updated
vagrant@server01:~$
```

Проверим `all` в `namespace` `app` с флагом `wide` (промежуточный опрос):

```bash
vagrant@server01:~$ kubectl get all -n app -o wide
NAME                               READY   STATUS              RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
pod/application-68d558cb88-mj8jm   2/2     Running             0          50s   10.1.188.57   server01   <none>           <none>
pod/application-68d558cb88-nllt6   2/2     Running             0          50s   10.1.188.58   server01   <none>           <none>
pod/application-68d558cb88-q7nxc   2/2     Running             0          50s   10.1.188.61   server01   <none>           <none>
pod/application-6b6665944d-vp9wp   2/2     Running             0          7s    10.1.188.62   server01   <none>           <none>
pod/application-68d558cb88-mvxkx   2/2     Terminating         0          50s   10.1.188.59   server01   <none>           <none>
pod/application-6b6665944d-htp46   0/2     ContainerCreating   0          2s    <none>        server01   <none>           <none>

NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/application   ClusterIP   10.152.183.152   <none>        80/TCP    50s   app=application

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS        IMAGES                               SELECTOR
deployment.apps/application   4/5     2            4           50s   nginx,multitool   nginx:1.20,wbitt/network-multitool   app=application

NAME                                     DESIRED   CURRENT   READY   AGE   CONTAINERS        IMAGES                               SELECTOR
replicaset.apps/application-68d558cb88   3         3         3       50s   nginx,multitool   nginx:1.19,wbitt/network-multitool   app=application,pod-template-hash=68d558cb88
replicaset.apps/application-6b6665944d   2         2         1       8s    nginx,multitool   nginx:1.20,wbitt/network-multitool   app=application,pod-template-hash=6b6665944d
vagrant@server01:~$
```

Проверим `all` в `namespace` `app` с флагом `wide` (все `pods` обновлены без ошибок):

```bash
vagrant@server01:~$ kubectl get all -n app -o wide
NAME                               READY   STATUS    RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
pod/application-6b6665944d-vp9wp   2/2     Running   0          32s   10.1.188.62   server01   <none>           <none>
pod/application-6b6665944d-htp46   2/2     Running   0          27s   10.1.188.63   server01   <none>           <none>
pod/application-6b6665944d-txhhw   2/2     Running   0          21s   10.1.188.7    server01   <none>           <none>
pod/application-6b6665944d-tjrt9   2/2     Running   0          16s   10.1.188.12   server01   <none>           <none>
pod/application-6b6665944d-cb6tv   2/2     Running   0          11s   10.1.188.10   server01   <none>           <none>

NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE   SELECTOR
service/application   ClusterIP   10.152.183.152   <none>        80/TCP    75s   app=application

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS        IMAGES                               SELECTOR
deployment.apps/application   5/5     5            5           75s   nginx,multitool   nginx:1.20,wbitt/network-multitool   app=application

NAME                                     DESIRED   CURRENT   READY   AGE   CONTAINERS        IMAGES                               SELECTOR
replicaset.apps/application-68d558cb88   0         0         0       75s   nginx,multitool   nginx:1.19,wbitt/network-multitool   app=application,pod-template-hash=68d558cb88
replicaset.apps/application-6b6665944d   5         5         5       33s   nginx,multitool   nginx:1.20,wbitt/network-multitool   app=application,pod-template-hash=6b6665944d
vagrant@server01:~$ 
```

Проверим описание `Deployment` `application` в `namespace` `app`:

```bash
vagrant@server01:~$ kubectl describe deployment application -n app
Name:                   application
Namespace:              app
CreationTimestamp:      Tue, 26 Sep 2023 12:33:42 +0000
Labels:                 app=application
Annotations:            deployment.kubernetes.io/revision: 2
Selector:               app=application
Replicas:               5 desired | 5 updated | 5 total | 5 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  20% max unavailable, 0 max surge
Pod Template:
  Labels:  app=application
  Containers:
   nginx:
    Image:        nginx:1.20
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
   multitool:
    Image:       wbitt/network-multitool
    Ports:       1180/TCP, 11443/TCP
    Host Ports:  0/TCP, 0/TCP
    Environment:
      HTTP_PORT:   1180
      HTTPS_PORT:  11443
    Mounts:        <none>
  Volumes:         <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  application-68d558cb88 (0/0 replicas created)
NewReplicaSet:   application-6b6665944d (5/5 replicas created)
Events:
  Type    Reason             Age                From                   Message
  ----    ------             ----               ----                   -------
  Normal  ScalingReplicaSet  100s               deployment-controller  Scaled up replica set application-68d558cb88 to 5
  Normal  ScalingReplicaSet  58s                deployment-controller  Scaled down replica set application-68d558cb88 to 4 from 5
  Normal  ScalingReplicaSet  57s                deployment-controller  Scaled up replica set application-6b6665944d to 1 from 0
  Normal  ScalingReplicaSet  53s                deployment-controller  Scaled down replica set application-68d558cb88 to 3 from 4
  Normal  ScalingReplicaSet  52s                deployment-controller  Scaled up replica set application-6b6665944d to 2 from 1
  Normal  ScalingReplicaSet  46s                deployment-controller  Scaled down replica set application-68d558cb88 to 2 from 3
  Normal  ScalingReplicaSet  46s                deployment-controller  Scaled up replica set application-6b6665944d to 3 from 2
  Normal  ScalingReplicaSet  41s                deployment-controller  Scaled down replica set application-68d558cb88 to 1 from 2
  Normal  ScalingReplicaSet  41s                deployment-controller  Scaled up replica set application-6b6665944d to 4 from 3
  Normal  ScalingReplicaSet  36s (x2 over 36s)  deployment-controller  (combined from similar events): Scaled up replica set application-6b6665944d to 5 from 4
vagrant@server01:~$
```

Заменяем версию `nginx` на `1.28`:

```bash
vagrant@server01:~$ kubectl set image deployment/application nginx=nginx:1.28 -n app
deployment.apps/application image updated
vagrant@server01:~$
```

Проверим `all` в `namespace` `app` с флагом `wide` (обнаружены ошибки):

```bash
vagrant@server01:~$ kubectl get all -n app -o wide
NAME                               READY   STATUS             RESTARTS   AGE    IP            NODE       NOMINATED NODE   READINESS GATES
pod/application-6b6665944d-vp9wp   2/2     Running            0          102s   10.1.188.62   server01   <none>           <none>
pod/application-6b6665944d-htp46   2/2     Running            0          97s    10.1.188.63   server01   <none>           <none>
pod/application-6b6665944d-txhhw   2/2     Running            0          91s    10.1.188.7    server01   <none>           <none>
pod/application-6b6665944d-tjrt9   2/2     Running            0          86s    10.1.188.12   server01   <none>           <none>
pod/application-679b896868-gbrh9   1/2     ImagePullBackOff   0          12s    10.1.188.9    server01   <none>           <none>

NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/application   ClusterIP   10.152.183.152   <none>        80/TCP    2m25s   app=application

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS        IMAGES                               SELECTOR
deployment.apps/application   4/5     1            4           2m25s   nginx,multitool   nginx:1.28,wbitt/network-multitool   app=application

NAME                                     DESIRED   CURRENT   READY   AGE     CONTAINERS        IMAGES                               SELECTOR
replicaset.apps/application-68d558cb88   0         0         0       2m25s   nginx,multitool   nginx:1.19,wbitt/network-multitool   app=application,pod-template-hash=68d558cb88
replicaset.apps/application-6b6665944d   4         4         4       103s    nginx,multitool   nginx:1.20,wbitt/network-multitool   app=application,pod-template-hash=6b6665944d
replicaset.apps/application-679b896868   1         1         0       13s     nginx,multitool   nginx:1.28,wbitt/network-multitool   app=application,pod-template-hash=679b896868
vagrant@server01:~$ 
```

Проверим описание `Deployment` `application` в `namespace` `app`:

```bash
vagrant@server01:~$ kubectl describe deployment application -n app
Name:                   application
Namespace:              app
CreationTimestamp:      Tue, 26 Sep 2023 12:33:42 +0000
Labels:                 app=application
Annotations:            deployment.kubernetes.io/revision: 3
Selector:               app=application
Replicas:               5 desired | 1 updated | 5 total | 4 available | 1 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  20% max unavailable, 0 max surge
Pod Template:
  Labels:  app=application
  Containers:
   nginx:
    Image:        nginx:1.28
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
   multitool:
    Image:       wbitt/network-multitool
    Ports:       1180/TCP, 11443/TCP
    Host Ports:  0/TCP, 0/TCP
    Environment:
      HTTP_PORT:   1180
      HTTPS_PORT:  11443
    Mounts:        <none>
  Volumes:         <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    ReplicaSetUpdated
OldReplicaSets:  application-68d558cb88 (0/0 replicas created), application-6b6665944d (4/4 replicas created)
NewReplicaSet:   application-679b896868 (1/1 replicas created)
Events:
  Type    Reason             Age                 From                   Message
  ----    ------             ----                ----                   -------
  Normal  ScalingReplicaSet  2m47s               deployment-controller  Scaled up replica set application-68d558cb88 to 5
  Normal  ScalingReplicaSet  2m5s                deployment-controller  Scaled down replica set application-68d558cb88 to 4 from 5
  Normal  ScalingReplicaSet  2m4s                deployment-controller  Scaled up replica set application-6b6665944d to 1 from 0
  Normal  ScalingReplicaSet  2m                  deployment-controller  Scaled down replica set application-68d558cb88 to 3 from 4
  Normal  ScalingReplicaSet  119s                deployment-controller  Scaled up replica set application-6b6665944d to 2 from 1
  Normal  ScalingReplicaSet  113s                deployment-controller  Scaled down replica set application-68d558cb88 to 2 from 3
  Normal  ScalingReplicaSet  113s                deployment-controller  Scaled up replica set application-6b6665944d to 3 from 2
  Normal  ScalingReplicaSet  108s                deployment-controller  Scaled down replica set application-68d558cb88 to 1 from 2
  Normal  ScalingReplicaSet  108s                deployment-controller  Scaled up replica set application-6b6665944d to 4 from 3
  Normal  ScalingReplicaSet  35s (x4 over 103s)  deployment-controller  (combined from similar events): Scaled up replica set application-679b896868 to 1 from 0
vagrant@server01:~$ 
```

Откатимся на предыдущюю версию:

```bash
vagrant@server01:~$ kubectl rollout undo deployment application -n app
deployment.apps/application rolled back
vagrant@server01:~$
```

Проверим `all` в `namespace` `app` с флагом `wide`:

```bash
vagrant@server01:~$ kubectl get all -n app -o wide
NAME                               READY   STATUS    RESTARTS   AGE     IP            NODE       NOMINATED NODE   READINESS GATES
pod/application-6b6665944d-vp9wp   2/2     Running   0          3m13s   10.1.188.62   server01   <none>           <none>
pod/application-6b6665944d-htp46   2/2     Running   0          3m8s    10.1.188.63   server01   <none>           <none>
pod/application-6b6665944d-txhhw   2/2     Running   0          3m2s    10.1.188.7    server01   <none>           <none>
pod/application-6b6665944d-tjrt9   2/2     Running   0          2m57s   10.1.188.12   server01   <none>           <none>
pod/application-6b6665944d-qqnt8   2/2     Running   0          18s     10.1.188.11   server01   <none>           <none>

NAME                  TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE     SELECTOR
service/application   ClusterIP   10.152.183.152   <none>        80/TCP    3m56s   app=application

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS        IMAGES                               SELECTOR
deployment.apps/application   5/5     5            5           3m56s   nginx,multitool   nginx:1.20,wbitt/network-multitool   app=application

NAME                                     DESIRED   CURRENT   READY   AGE     CONTAINERS        IMAGES                               SELECTOR
replicaset.apps/application-68d558cb88   0         0         0       3m56s   nginx,multitool   nginx:1.19,wbitt/network-multitool   app=application,pod-template-hash=68d558cb88
replicaset.apps/application-679b896868   0         0         0       104s    nginx,multitool   nginx:1.28,wbitt/network-multitool   app=application,pod-template-hash=679b896868
replicaset.apps/application-6b6665944d   5         5         5       3m14s   nginx,multitool   nginx:1.20,wbitt/network-multitool   app=application,pod-template-hash=6b6665944d
vagrant@server01:~$ 
```

Проверим описание `Deployment` `application` в `namespace` `app`:

```bash
vagrant@server01:~$ kubectl describe deployment application -n app
Name:                   application
Namespace:              app
CreationTimestamp:      Tue, 26 Sep 2023 12:33:42 +0000
Labels:                 app=application
Annotations:            deployment.kubernetes.io/revision: 4
Selector:               app=application
Replicas:               5 desired | 5 updated | 5 total | 5 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  20% max unavailable, 0 max surge
Pod Template:
  Labels:  app=application
  Containers:
   nginx:
    Image:        nginx:1.20
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
   multitool:
    Image:       wbitt/network-multitool
    Ports:       1180/TCP, 11443/TCP
    Host Ports:  0/TCP, 0/TCP
    Environment:
      HTTP_PORT:   1180
      HTTPS_PORT:  11443
    Mounts:        <none>
  Volumes:         <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  application-68d558cb88 (0/0 replicas created), application-679b896868 (0/0 replicas created)
NewReplicaSet:   application-6b6665944d (5/5 replicas created)
Events:
  Type    Reason             Age                  From                   Message
  ----    ------             ----                 ----                   -------
  Normal  ScalingReplicaSet  4m28s                deployment-controller  Scaled up replica set application-68d558cb88 to 5
  Normal  ScalingReplicaSet  3m46s                deployment-controller  Scaled down replica set application-68d558cb88 to 4 from 5
  Normal  ScalingReplicaSet  3m45s                deployment-controller  Scaled up replica set application-6b6665944d to 1 from 0
  Normal  ScalingReplicaSet  3m41s                deployment-controller  Scaled down replica set application-68d558cb88 to 3 from 4
  Normal  ScalingReplicaSet  3m40s                deployment-controller  Scaled up replica set application-6b6665944d to 2 from 1
  Normal  ScalingReplicaSet  3m34s                deployment-controller  Scaled down replica set application-68d558cb88 to 2 from 3
  Normal  ScalingReplicaSet  3m34s                deployment-controller  Scaled up replica set application-6b6665944d to 3 from 2
  Normal  ScalingReplicaSet  3m29s                deployment-controller  Scaled down replica set application-68d558cb88 to 1 from 2
  Normal  ScalingReplicaSet  3m29s                deployment-controller  Scaled up replica set application-6b6665944d to 4 from 3
  Normal  ScalingReplicaSet  51s (x6 over 3m24s)  deployment-controller  (combined from similar events): Scaled up replica set application-6b6665944d to 5 from 4
vagrant@server01:~$ 
```