*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 4.3 Языки разметки JSON и YAML


## Обязательная задача 1
Мы выгрузили JSON, который получили через API запрос к нашему сервису:
```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис

###### Ответ:

| Ошибка  | Исправление | Комментарий |
| ------------- | ------------- | ------------- |
| "elements" :[  | "elements" : [  | Должен быть пробел между двоеточием и скобкой
| "ip" : 7175   | "ip" : "71.75.22.43"  | Не дописан IP адрес и его нужно заключить в кавычки
| "ip : 71.78.22.43  | "ip" : "71.78.22.43"  | Не хватает кавычек
| } { | }, { | Нужно добавить запятую между объектами в массиве

## Обязательная задача 2
В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML файлов, описывающих наши сервисы. Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`. Формат записи YAML по одному сервису: `- имя сервиса: его IP`. Если в момент исполнения скрипта меняется IP у сервиса - он должен так же поменяться в yml и json файле.

### Ваш скрипт:
```python
#!/usr/bin/env python3

from socket import gethostbyname
from datetime import datetime
from time import sleep
import json
import yaml


hosts = {"drive.google.com": "", "mail.google.com": "", "google.com": ""}

for host in hosts.keys():
    hosts[host] = gethostbyname(host)

while True:
    try:
        with open('./srv.json', 'r+') as srv_json, open('./srv.yaml', 'r+') as srv_yaml:
            try:
                hosts_json = json.load(srv_json)
                print(f"Load ./srv.json")
            except json.decoder.JSONDecodeError as e:
                print(f"Wrong format ./srv.json.")
                exit(1)
            try:
                hosts_yaml = yaml.load(srv_yaml.read(), Loader=yaml.SafeLoader)
                print(f"Load ./srv.yaml")
            except yaml.scanner.ScannerError as e:
                print(f"Wrong format ./srv.yaml .")
                exit(1)
            else:
                try:
                    hosts = hosts_yaml
                    while True:
                        for host in hosts:
                            now = datetime.now()
                            dt_string = now.strftime("%d/%m/%Y %H:%M:%S")
                            ip_prev = hosts[host]
                            ip_cur = gethostbyname(host)
                            if ip_cur != ip_prev:
                                print(f"{dt_string}: [ERROR] <{host}> IP mismatch: <{ip_prev}> <{ip_cur}>")
                                hosts[host] = ip_cur
                                with open("./srv.json", 'w+') as write_json, open("./srv.yaml", 'w+') as write_yaml:
                                    write_json.write(json.dumps(hosts, indent=4))
                                    write_yaml.write(yaml.dump(hosts, indent=4))
                            else:
                                print(f"{dt_string}: {host} - {ip_cur}")
                        sleep(5)
                except KeyboardInterrupt:
                    srv_json.close()
                    srv_yaml.close()
                    break
    except FileNotFoundError as e:
        print(f'File not found! Make {e.filename}')
        srv = open(e.filename, 'w+')
        if srv.name.endswith('.json'):
            try:
                srv_yaml = open('./srv.yaml', 'r+').read()
                hosts_yaml = yaml.load(
                    srv_yaml, Loader=yaml.SafeLoader)
                srv.write(json.dumps(hosts_yaml, indent=4))
            except FileNotFoundError:
                srv.write(json.dumps(hosts, indent=4))
            except:
                print('Error!')
                exit(1)
        elif srv.name.endswith('yaml') or e.filename.endswith('yml'):
            try:
                srv_json = open('./srv.json', 'r+')
                hosts_json = json.load(srv_json)
                srv.write(yaml.dump(hosts_json, indent=4))
            except FileNotFoundError:
                srv.write(json.dumps(hosts, indent=4))
            except:
                print('Error!')
                exit(1)
        srv.read()
```

### Вывод скрипта при запуске при тестировании:
```
File not found! Make ./srv.json
File not found! Make ./srv.yaml
Load ./srv.json
Load ./srv.yaml
21/03/2022 15:44:54: drive.google.com - 64.233.165.194
21/03/2022 15:44:54: google.com - 64.233.162.113
21/03/2022 15:44:54: mail.google.com - 108.177.14.83
```

### json-файл(ы), который(е) записал ваш скрипт:
```json
{
    "drive.google.com": "64.233.165.194",
    "mail.google.com": "108.177.14.83",
    "google.com": "64.233.162.113"
}
```

### yml-файл(ы), который(е) записал ваш скрипт:
```yaml
drive.google.com: 64.233.165.194
google.com: 64.233.162.113
mail.google.com: 108.177.14.83
```
