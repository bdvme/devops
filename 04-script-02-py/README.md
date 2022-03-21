*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 4.2. Использование Python для решения типовых DevOps задач


## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ |
| ------------- | ------------- |
| Какое значение будет присвоено переменной `c`?  | TypeError: unsupported operand type(s) for +: 'int' and 'str'  |
| Как получить для переменной `c` значение 12?  | Нужно заключить в одинарные кавычки значение переменной `a` (a = '1') |
| Как получить для переменной `c` значение 3?  | Нужно убрать одинарные кавычки для значения переменной `b` (b = 2)  |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os

path = "~/netology/sysadm-homeworks"
abs_path = os.path.abspath(os.path.expanduser(path))
bash_command = [f"cd {abs_path}", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(os.path.join(abs_path, prepare_result))
```

### Вывод скрипта при запуске при тестировании:
```
$ python3 main.py
/Volumes/Sun/Users/bdv/netology/sysadm-homeworks/02-git-01-vcs/README.md
/Volumes/Sun/Users/bdv/netology/sysadm-homeworks/03-sysadmin-08-net/README.md
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
import sys
import subprocess

try:
    path = sys.argv[1]
except IndexError:
    print("Warning!\nRun without arguments!\nPlease write path git repository!\nExample: python3 main.py /path/to/git/repository\n")
    path = os.getcwd()

abs_path = os.path.abspath(os.path.expanduser(path))
bash_command = [f"cd {abs_path}", "git status"]
try:
    result_os = subprocess.Popen(["git", "status"], stdout=subprocess.PIPE,
                                 stderr=subprocess.STDOUT, cwd=abs_path, text=True).communicate()[0].split('\n')
except FileNotFoundError:
    print("{result_os} is a wrong path!")
    exit()

for result in result_os:
    if result.find('fatal:') != -1:
        print({path}, " Is a not a git repository!")
        exit()
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(os.path.join(abs_path, prepare_result))
```

### Вывод скрипта при запуске при тестировании:
```
Warning!
Run without arguments!
Please write path git repository!
Example: python3 main.py /path/to/git/repository

{'/Volumes/Sun/Users/bdv/PycharmProjects/netology'}  Is a not a git repository!
```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
#!/usr/bin/env python3

from socket import gethostbyname
from time import sleep
from datetime import datetime

hosts = {"drive.google.com": {"ip": ""}, "mail.google.com": {"ip": ""},
         "google.com": {"ip": ""}}

for host in hosts.keys():
    hosts[host]["ip"] = gethostbyname(host)

while True:
    for host in hosts.keys():
        now = datetime.now()
        dt_string = now.strftime("%d/%m/%Y %H:%M:%S")
        ip_cur = gethostbyname(host)
        ip_prev = hosts[host]["ip"]
        if ip_cur != ip_prev:
            print(f"{dt_string}: [ERROR] <{host}> IP mismatch: <{ip_prev}> <{ip_cur}>")
            hosts[host]["ip"] = ip_cur
        else:
            print(f"{dt_string}: {host} - {ip_cur}")
    sleep(5)
```

### Вывод скрипта при запуске при тестировании:
```
21/03/2022 11:42:40: drive.google.com - 142.251.1.194
21/03/2022 11:42:40: mail.google.com - 108.177.14.18
21/03/2022 11:42:40: google.com - 74.125.205.102
21/03/2022 11:42:45: drive.google.com - 142.251.1.194
21/03/2022 11:42:45: [ERROR] <mail.google.com> IP mismatch: <108.177.14.18> <173.194.221.17>
21/03/2022 11:42:45: google.com - 74.125.205.102
21/03/2022 11:42:50: drive.google.com - 142.251.1.194
21/03/2022 11:42:50: mail.google.com - 173.194.221.17
21/03/2022 11:42:50: google.com - 74.125.205.102
```
