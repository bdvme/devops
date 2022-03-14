*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 3.6 Компьютерные сети, лекция 2

1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?

###### Ответ:

* Linux

```bash
vagrant@vagrant:~$ ip -br link
lo               UNKNOWN        00:00:00:00:00:00 <LOOPBACK,UP,LOWER_UP>
eth0             UP             08:00:27:b1:28:5d <BROADCAST,MULTICAST,UP,LOWER_UP>
```

* Windows

```bash
C:\Users\Dmitry>ipconfig

Настройка протокола IP для Windows


Адаптер Ethernet Ethernet:

   DNS-суффикс подключения . . . . . : localdomain
   IPv6-адрес. . . . . . . . . . . . : fdb2:2c26:f4e4:0:9ca0:6579:d364:a5cc
   Временный IPv6-адрес. . . . . . . : fdb2:2c26:f4e4:0:68dc:744a:ab9a:c64f
   Локальный IPv6-адрес канала . . . : fe80::9ca0:6579:d364:a5cc%5
   IPv4-адрес. . . . . . . . . . . . : 10.211.55.10
   Маска подсети . . . . . . . . . . : 255.255.255.0
   Основной шлюз. . . . . . . . . : 10.211.55.1
```

2. Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?

###### Ответ:

- Протокол LLDP
- Пакет `lldpd`
- Команды `lldpd` и `lldpctl`

3. Какая технология используется для разделения L2 коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.

###### Ответ:

- Технология VLAN виртуальный сетей
- Пакет `vlan`
- Команды `vconfig add` и `ip link add`

```bash
vagrant@vagrant:~$ sudo nano /etc/network/interfaces
vagrant@vagrant:~$ cat /etc/network/interfaces
auto eth0.5
iface eth0.5 inet static
address 192.168.1.5
netmask 255.255.255.0
vlan-raw-device eth0
```

- `auto eth0.5` — «поднимать» интерфейс при запуске сетевой службы
- `iface eth0.5` — название интерфейса
- `vlan-raw-device` — указывает на каком физическом интерфейсе создавать VLAN.

4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.

###### Ответ:

- Bonding – это объединение сетевых интерфейсов по определенному типу агрегации, Служит для увеличения пропускной способности и/или отказоустойчивость сети.

- Типы LAG:
  * Статический
  * Динамический
- В Linux есть следующие опции балансировки:
  * Mode-0 (balance-rr)
  * Mode-1 (active-backup)
  * Mode-2 (balance-xor)
  * Mode-3 (broadcast)
  * Mode-4 (802.3ad)
  * Mode-5 (balance-tlb)
  * Mode-6 (balance-alb)

- Пример:

```bash
vagrant@vagrant:~$ cat /etc/network/interfaces
iface bond0 inet static
address 10.11.1.5
netmask 255.255.255.0
network 10.11.1.0
gateway 10.11.1.254
bond_mode balance-tlb
bond_miimon 100
bond_downdelay 200
bond_updelay 200
bond_slaves eth0 eth1
```

5. Сколько IP адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.

###### Ответ:

- В сети с маской /29 - 8 IP адресов, включая адрес подсети и броадкаст. На хосты 6 адресов.

```bash
vagrant@vagrant:~$ ipcalc 10.10.10.0/29
Address:   10.10.10.0           00001010.00001010.00001010.00000 000
Netmask:   255.255.255.248 = 29 11111111.11111111.11111111.11111 000
Wildcard:  0.0.0.7              00000000.00000000.00000000.00000 111
=>
Network:   10.10.10.0/29        00001010.00001010.00001010.00000 000
HostMin:   10.10.10.1           00001010.00001010.00001010.00000 001
HostMax:   10.10.10.6           00001010.00001010.00001010.00000 110
Broadcast: 10.10.10.7           00001010.00001010.00001010.00000 111
Hosts/Net: 6                     Class A, Private Internet
```

- Из сети с маской /24 можно получить 32 подсети с маской /29
- Пример /29 подсети внутри сети с маской /24:

```bash
vagrant@vagrant:~$ ipcalc -b 10.10.10.0/24 /29
Address:   10.10.10.0
Netmask:   255.255.255.0 = 24
Wildcard:  0.0.0.255
=>
Network:   10.10.10.0/24
HostMin:   10.10.10.1
HostMax:   10.10.10.254
Broadcast: 10.10.10.255
Hosts/Net: 254                   Class A, Private Internet

Subnets after transition from /24 to /29

Netmask:   255.255.255.248 = 29
Wildcard:  0.0.0.7

 1.
Network:   10.10.10.0/29
HostMin:   10.10.10.1
HostMax:   10.10.10.6
Broadcast: 10.10.10.7
Hosts/Net: 6                     Class A, Private Internet

 2.
Network:   10.10.10.8/29
HostMin:   10.10.10.9
HostMax:   10.10.10.14
Broadcast: 10.10.10.15
Hosts/Net: 6                     Class A, Private Internet

 3.
Network:   10.10.10.16/29
HostMin:   10.10.10.17
HostMax:   10.10.10.22
Broadcast: 10.10.10.23
Hosts/Net: 6                     Class A, Private Internet

 4.
Network:   10.10.10.24/29
HostMin:   10.10.10.25
HostMax:   10.10.10.30
Broadcast: 10.10.10.31
Hosts/Net: 6                     Class A, Private Internet
```

6. Задача: вас попросили организовать стык между 2-мя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP адреса? Маску выберите из расчета максимум 40-50 хостов внутри подсети.

###### Ответ:

- Можно использовать только IP адреса 10.64.0.0/10.
- Маска с IP адресами на 40-50 хостов - /26:

```bash
vagrant@vagrant:~$ ipcalc -b 100.64.0.0/10 -s 45
Address:   100.64.0.0
Netmask:   255.192.0.0 = 10
Wildcard:  0.63.255.255
=>
Network:   100.64.0.0/10
HostMin:   100.64.0.1
HostMax:   100.127.255.254
Broadcast: 100.127.255.255
Hosts/Net: 4194302               Class A

1. Requested size: 45 hosts
Netmask:   255.255.255.192 = 26
Network:   100.64.0.0/26
HostMin:   100.64.0.1
HostMax:   100.64.0.62
Broadcast: 100.64.0.63
Hosts/Net: 62                    Class A
```

7. Как проверить ARP таблицу в Linux, Windows? Как очистить ARP кеш полностью? Как из ARP таблицы удалить только один нужный IP?

###### Ответ:

- Linux

```bash
vagrant@vagrant:~$ ip neig
10.0.2.3 dev eth0 lladdr 52:54:00:12:35:03 STALE
10.0.2.2 dev eth0 lladdr 52:54:00:12:35:02 REACHABLE
```

- Windows

```bash
C:\Users\Dmitry>arp -a

Интерфейс: 10.211.55.10 --- 0x5
  адрес в Интернете      Физический адрес      Тип
  10.211.55.1           00-1c-42-00-00-18     динамический
  224.0.0.22            01-00-5e-00-00-16     статический
  224.0.0.252           01-00-5e-00-00-fc     статический
```

- Очистить ARP кеш полностью:

```bash
vagrant@vagrant:~$ sudo ip neig flush all
```

- Удалить только один нужный IP из ARP таблицы:

```bash
vagrant@vagrant:~$ sudo ip neig del 10.0.2.2
```
