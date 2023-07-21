*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 12.2.2 «Хранение в K8s. Часть 2»

### Цель задания

В тестовой среде Kubernetes нужно создать PV и продемострировать запись и хранение файлов.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке NFS в MicroK8S](https://microk8s.io/docs/nfs). 
2. [Описание Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/). 
3. [Описание динамического провижининга](https://kubernetes.io/docs/concepts/storage/dynamic-provisioning/). 
4. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1

**Что нужно сделать**

Создать Deployment приложения, использующего локальный PV, созданный вручную.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.
3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории. 
4. Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему.
5. Продемонстрировать, что файл сохранился на локальном диске ноды. Удалить PV.  Продемонстрировать что произошло с файлом после удаления PV. Пояснить, почему.
5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

------

### Задание 2

**Что нужно сделать**

Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

1. Включить и настроить NFS-сервер на MicroK8S.
2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.
3. Продемонстрировать возможность чтения и записи файла изнутри пода. 
4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

------
###### Ответ:

### Задание 1

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.
3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории. 
4. Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему.
5. Продемонстрировать, что файл сохранился на локальном диске ноды. Удалить PV.  Продемонстрировать что произошло с файлом после удаления PV. Пояснить, почему.
5. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

<details> 
<summary>deployment</summary>
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
        - name: busybox
          image: busybox
          command:
            - "/bin/sh"
            - "-c"
            - |
              while true; 
              do 
                echo "$(date) Hello Netology!" >> /msg-out-path/test
                sleep 5
              done
          volumeMounts:
            - mountPath: /msg-out-path
              name: msg-volume
        - name: multitool
          image: wbitt/network-multitool
          volumeMounts:
            - mountPath: /msg-in-path
              name: msg-volume
      volumes:
        - name: msg-volume
          persistentVolumeClaim:
            claimName: local-pvc

---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
spec:
  storageClassName: manual
  capacity:
    storage: 100Mi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /home/vagrant/

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-pvc
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
</code></pre>
</details>

Применяем манифест `deployment.yml`

```bash
vagrant@server01:~$ kubectl apply -f ./deployment.yml 
deployment.apps/backend created
persistentvolume/local-pv created
persistentvolumeclaim/local-pvc created
```

Получаем статусы

```bash
vagrant@server01:~$ kubectl get deployment,pods,pv,pvc
NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/backend   1/1     1            1           6m48s

NAME                           READY   STATUS    RESTARTS   AGE
pod/backend-6f594984c4-skqc4   2/2     Running   0          6m48s

NAME                                                        CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                               STORAGECLASS        REASON   AGE
persistentvolume/pvc-33733c0b-3cf9-474c-a1bb-1b536ac7f028   20Gi       RWX            Delete           Bound    container-registry/registry-claim   microk8s-hostpath            33m
persistentvolume/local-pv                                   100Mi      RWO            Retain           Bound    default/local-pvc                   manual                       6m48s

NAME                              STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/local-pvc   Bound    local-pv   100Mi      RWO            manual         6m48s
```

Вывод чтения `multitool` путь для чтения /msg-in-path/test

```bash
vagrant@server01:~$ kubectl exec pod/backend-6f594984c4-skqc4 -c multitool -- tail -f -n 5 /msg-in-path/test
Fri Jul 21 14:46:46 UTC 2023 Hello Netology!
Fri Jul 21 14:46:51 UTC 2023 Hello Netology!
Fri Jul 21 14:46:56 UTC 2023 Hello Netology!
Fri Jul 21 14:47:01 UTC 2023 Hello Netology!
Fri Jul 21 14:47:06 UTC 2023 Hello Netology!
^C
```

Удаляем `deployment` и `pvc`

```bash
vagrant@server01:~$ kubectl delete deployment/backend pvc/local-pvc
deployment.apps "backend" deleted
persistentvolumeclaim "local-pvc" deleted
```

Смотрим статус `PersistentVolume`

```bash
vagrant@server01:~$ kubectl get pv
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM                               STORAGECLASS        REASON   AGE
pvc-33733c0b-3cf9-474c-a1bb-1b536ac7f028   20Gi       RWX            Delete           Bound      container-registry/registry-claim   microk8s-hostpath            39m
local-pv                                   100Mi      RWO            Retain           Released   default/local-pvc                   manual                       13m
```

После удаления `Deployment` и `PVC`, `PV` остается в состоянии `Released`. `PV` сохраняется и может быть повторно использован, несмотря на разрыв связи между ним и `PVC`. Когда `PV` находится в состоянии `Released`, его можно привязать к другому `PVC` или удалить вручную с помощью соответствующих команд.