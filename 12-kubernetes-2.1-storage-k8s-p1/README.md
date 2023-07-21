*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 12.2.1 «Хранение в K8s. Часть 1»

### Цель задания

В тестовой среде Kubernetes нужно обеспечить обмен файлами между контейнерам пода и доступ к логам ноды.

------

### Чеклист готовности к домашнему заданию

1. Установленное K8s-решение (например, MicroK8S).
2. Установленный локальный kubectl.
3. Редактор YAML-файлов с подключенным GitHub-репозиторием.

------

### Дополнительные материалы для выполнения задания

1. [Инструкция по установке MicroK8S](https://microk8s.io/docs/getting-started).
2. [Описание Volumes](https://kubernetes.io/docs/concepts/storage/volumes/).
3. [Описание Multitool](https://github.com/wbitt/Network-MultiTool).

------

### Задание 1 

**Что нужно сделать**

Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Сделать так, чтобы busybox писал каждые пять секунд в некий файл в общей директории.
3. Обеспечить возможность чтения файла контейнером multitool.
4. Продемонстрировать, что multitool может читать файл, который периодоически обновляется.
5. Предоставить манифесты Deployment в решении, а также скриншоты или вывод команды из п. 4.

------

### Задание 2

**Что нужно сделать**

Создать DaemonSet приложения, которое может прочитать логи ноды.

1. Создать DaemonSet приложения, состоящего из multitool.
2. Обеспечить возможность чтения файла `/var/log/syslog` кластера MicroK8S.
3. Продемонстрировать возможность чтения файла изнутри пода.
4. Предоставить манифесты Deployment, а также скриншоты или вывод команды из п. 2.

------
###### Ответ:

### Задание 1 

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Сделать так, чтобы busybox писал каждые пять секунд в некий файл в общей директории.
3. Обеспечить возможность чтения файла контейнером multitool.
4. Продемонстрировать, что multitool может читать файл, который периодоически обновляется.
5. Предоставить манифесты Deployment в решении, а также скриншоты или вывод команды из п. 4.

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
            - "while true; do echo 'Hello Netology!' >> /msg-out-path/test; sleep 5; done"
          volumeMounts:
            - mountPath: /msg-out-path
              name: msg-volume
        - name: multitool
          image: wbitt/network-multitool
          volumeMounts:
            - mountPath: /msg-in-path
              name: msg-volume
      volumes:
        - emptyDir: {}
          name: msg-volume 
</code></pre>
</details>

Применяем манифест `deployment.yml`

```bash
vagrant@server01:~$ kubectl apply -f deployment.yml 
deployment.apps/backend created
```

Получаем статус от deployments и pods

```bash
vagrant@server01:~$ kubectl get deployments,pods
NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/backend   1/1     1            1           17s

NAME                           READY   STATUS    RESTARTS   AGE
pod/backend-56c7c75657-4br6l   2/2     Running   0          17s
```

Вывод записи `busybox` путь для записи /msg-out-path/test

```bash
vagrant@server01:~$ kubectl exec pod/backend-56c7c75657-4br6l -c busybox -- tail -f /msg-out-path/test
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
^C
```

Вывод чтения `multitool` путь для чтения /msg-in-path/test

```bash
vagrant@server01:~$ kubectl exec pod/backend-56c7c75657-4br6l -c multitool -- tail -f /msg-in-path/test
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
Hello Netology!
^C
```

### Задание 2

1. Создать DaemonSet приложения, состоящего из multitool.
2. Обеспечить возможность чтения файла `/var/log/syslog` кластера MicroK8S.
3. Продемонстрировать возможность чтения файла изнутри пода.
4. Предоставить манифесты Deployment, а также скриншоты или вывод команды из п. 2.

<details> 
<summary>daemonset</summary>
<pre><code>
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: backend
  labels:
    app: backend
  namespace: default
spec:
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
          volumeMounts:
            - mountPath: /logs
              name: log
      volumes:
        - hostPath:
            path: /var/log
          name: log   
</code></pre>
</details>

Применяем манифест `daemonset.yml`

```bash
vagrant@server01:~$ kubectl apply -f daemonset.yml 
daemonset.apps/backend created
```

Получаем статус от daemonset и pods

```bash
vagrant@server01:~$ kubectl get daemonset,pod
NAME                     DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
daemonset.apps/backend   1         1         1       1            1           <none>          27s

NAME                READY   STATUS    RESTARTS   AGE
pod/backend-5j4nd   1/1     Running   0          26s
```

Чтение файла `/var/log/syslog` кластера MicroK8S

```bash
vagrant@server01:~$ kubectl exec pod/backend-5j4nd -c multitool -- tail -f /logs/syslog
Jul 21 09:35:48 vagrant systemd[1]: run-containerd-runc-k8s.io-5d677ca814e1382b9f089d688b89b7e54d0a3a97b72c59c77e69faf951c2ec2a-runc.YJAn8j.mount: Succeeded.
Jul 21 09:35:51 vagrant systemd[140492]: run-containerd-runc-k8s.io-315708ee7aecd75d1c3d20ff2b2c2df42d52eb0f18a95d8967c51aab35eeb4f3-runc.Wdhr6P.mount: Succeeded.
Jul 21 09:35:51 vagrant systemd[1]: run-containerd-runc-k8s.io-315708ee7aecd75d1c3d20ff2b2c2df42d52eb0f18a95d8967c51aab35eeb4f3-runc.Wdhr6P.mount: Succeeded.
Jul 21 09:35:52 vagrant systemd[140492]: run-containerd-runc-k8s.io-5d677ca814e1382b9f089d688b89b7e54d0a3a97b72c59c77e69faf951c2ec2a-runc.o38Sh5.mount: Succeeded.
^C
```
