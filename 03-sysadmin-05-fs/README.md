*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 3.5. Файловые системы

1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.

###### Ответ:

  * Разреженные – это специальные файлы, которые с большей эффективностью используют файловую систему, они не позволяют ФС занимать свободное дисковое пространство носителя, когда разделы не заполнены. То есть, «пустое место» будет задействовано только при необходимости. Пустая информация в виде нулей, будет хранится в блоке метаданных ФС. Поэтому, разреженные файлы изначально занимают меньший объем носителя, чем их реальный объем.


2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?

###### Ответ:

  * Нет, не могут. Из-за того, что Hardlink имеет один и тот же inode, права доступа и владелец будут такими же как и у объекта.

  ```bash
  vagrant@vagrant:~$ touch tst_hl
  vagrant@vagrant:~$ ln tst_hl tst_lnk
  vagrant@vagrant:~$ ls -ilh
  total 0
  131086 -rw-rw-r-- 2 vagrant vagrant 0 Feb 20 15:35 tst_hl
  131086 -rw-rw-r-- 2 vagrant vagrant 0 Feb 20 15:35 tst_lnk
  vagrant@vagrant:~$ chmod 0755 tst_hl
  vagrant@vagrant:~$ ls -ilh
  total 0
  131086 -rwxr-xr-x 2 vagrant vagrant 0 Feb 20 15:35 tst_hl
  131086 -rwxr-xr-x 2 vagrant vagrant 0 Feb 20 15:35 tst_lnk
  ```

3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
    ```

    Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.

###### Ответ:

  * Настроил.
  ```bash
  vagrant@vagrant:~$ lsblk
  NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
  sda                    8:0    0   64G  0 disk
  ├─sda1                 8:1    0  512M  0 part /boot/efi
  ├─sda2                 8:2    0    1K  0 part
  └─sda5                 8:5    0 63.5G  0 part
    ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
    └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
  sdb                    8:16   0  2.5G  0 disk
  sdc                    8:32   0  2.5G  0 disk
  ```

4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

###### Ответ:

  * Ввел: `fdisk /dev/sdb`

  ```bash
  vagrant@vagrant:~$ sudo fdisk /dev/sdb
  ```

  * Ввел: `p` для просмотра информации о разделе

  ```bash
  Command (m for help): p
  Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
  Disk model: VBOX HARDDISK
  Units: sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes
  Disklabel type: dos
  Disk identifier: 0xf36dc7bb
  ```
  * Ввел: `g` для создания GPT таблицы разделов

  ```bash
  Command (m for help): g
  Created a new GPT disklabel (GUID: 53843FD3-6782-5C4F-A361-1B3AC02B62CC).
  ```

  * Ввел: `n` для добавления нового раздела

  ```bash
  Command (m for help): n
  Partition number (1-128, default 1): 1
  First sector (2048-5242846, default 2048): 2048
  Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242846, default 5242846): +2G
  Created a new partition 1 of type 'Linux filesystem' and of size 2 GiB.
  ```

  * Ввел: `p` для просмотра информации о разделе

  ```bash
  Command (m for help): p
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 53843FD3-6782-5C4F-A361-1B3AC02B62CC
Device     Start     End Sectors Size Type
/dev/sdb1   2048 4196351 4194304   2G Linux filesystem
  ```

  * Ввел: `n` для добавления нового раздела

  ```bash
  Command (m for help): n
  Partition number (2-128, default 2):
  First sector (4196352-5242846, default 4196352):
  Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242846, default 5242846):
  Created a new partition 2 of type 'Linux filesystem' and of size 511 MiB.
  ```

  * Ввел: `p` для просмотра информации о разделе

  ```bash
  Command (m for help): p
  Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
  Disk model: VBOX HARDDISK
  Units: sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes
  Disklabel type: gpt
  Disk identifier: 53843FD3-6782-5C4F-A361-1B3AC02B62CC
  Device       Start     End Sectors  Size Type
  /dev/sdb1     2048 4196351 4194304    2G Linux filesystem
  /dev/sdb2  4196352 5242846 1046495  511M Linux filesystem
  ```

  * Ввел: `w` для записи изменений на диск

  ```bash
  Command (m for help): w
  The partition table has been altered.
  Calling ioctl() to re-read partition table.
  Syncing disks.
  ```
```bash
vagrant@vagrant:~$ lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
└─sdb2                 8:18   0  511M  0 part
sdc                    8:32   0  2.5G  0 disk
```

5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.

###### Ответ:

  ```bash
  vagrant@vagrant:~$ sudo su
  root@vagrant:/home/vagrant# sfdisk -d /dev/sdb|sfdisk --force /dev/sdc
  Checking that no-one is using this disk right now ... OK

  Disk /dev/sdc: 2.51 GiB, 2684354560 bytes, 5242880 sectors
  Disk model: VBOX HARDDISK
  Units: sectors of 1 * 512 = 512 bytes
  Sector size (logical/physical): 512 bytes / 512 bytes
  I/O size (minimum/optimal): 512 bytes / 512 bytes

  >>> Script header accepted.
  >>> Script header accepted.
  >>> Script header accepted.
  >>> Script header accepted.
  >>> Script header accepted.
  >>> Script header accepted.
  >>> Created a new GPT disklabel (GUID: 53843FD3-6782-5C4F-A361-1B3AC02B62CC).
  /dev/sdc1: Created a new partition 1 of type 'Linux filesystem' and of size 2 GiB.
  /dev/sdc2: Created a new partition 2 of type 'Linux filesystem' and of size 511 MiB.
  /dev/sdc3: Done.

  New situation:
  Disklabel type: gpt
  Disk identifier: 53843FD3-6782-5C4F-A361-1B3AC02B62CC

  Device       Start     End Sectors  Size Type
  /dev/sdc1     2048 4196351 4194304    2G Linux filesystem
  /dev/sdc2  4196352 5242846 1046495  511M Linux filesystem

  The partition table has been altered.
  Calling ioctl() to re-read partition table.
  Syncing disks.
  root@vagrant:/home/vagrant# lsblk
  NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
  sda                    8:0    0   64G  0 disk
  ├─sda1                 8:1    0  512M  0 part /boot/efi
  ├─sda2                 8:2    0    1K  0 part
  └─sda5                 8:5    0 63.5G  0 part
    ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
    └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
  sdb                    8:16   0  2.5G  0 disk
  ├─sdb1                 8:17   0    2G  0 part
  └─sdb2                 8:18   0  511M  0 part
  sdc                    8:32   0  2.5G  0 disk
  ├─sdc1                 8:33   0    2G  0 part
  └─sdc2                 8:34   0  511M  0 part
  ```

6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.

###### Ответ:

  ```bash
  root@vagrant:/home/vagrant# mdadm --create --verbose /dev/md1 -l 1 -n 2 /dev/sd{b1,c1}
  mdadm: Note: this array has metadata at the start and
      may not be suitable as a boot device.  If you plan to
      store '/boot' on this device please ensure that
      your boot-loader understands md/v1.x metadata, or use
      --metadata=0.90
  mdadm: size set to 2094080K
  Continue creating array? y
  mdadm: Defaulting to version 1.2 metadata
  mdadm: array /dev/md1 started.
  root@vagrant:/home/vagrant# lsblk
  NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
  sda                    8:0    0   64G  0 disk
  ├─sda1                 8:1    0  512M  0 part  /boot/efi
  ├─sda2                 8:2    0    1K  0 part
  └─sda5                 8:5    0 63.5G  0 part
    ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
    └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
  sdb                    8:16   0  2.5G  0 disk
  ├─sdb1                 8:17   0    2G  0 part
  │ └─md1                9:1    0    2G  0 raid1
  └─sdb2                 8:18   0  511M  0 part
  sdc                    8:32   0  2.5G  0 disk
  ├─sdc1                 8:33   0    2G  0 part
  │ └─md1                9:1    0    2G  0 raid1
  └─sdc2                 8:34   0  511M  0 part
  ```

7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.

###### Ответ:
  ```bash
root@vagrant:/home/vagrant# mdadm --create --verbose /dev/md0 -l 0 -n 2 /dev/sd{b2,c2}mdadm: chunk size defaults to 512K
mdadm: /dev/sdb2 appears to be part of a raid array:
       level=raid1 devices=2 ctime=Sun Feb 20 16:22:10 2022
mdadm: /dev/sdc2 appears to be part of a raid array:
       level=raid1 devices=2 ctime=Sun Feb 20 16:22:10 2022
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
root@vagrant:/home/vagrant# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
│ └─md1                9:1    0    2G  0 raid1
└─sdb2                 8:18   0  511M  0 part
  └─md0                9:0    0 1017M  0 raid0
sdc                    8:32   0  2.5G  0 disk
├─sdc1                 8:33   0    2G  0 part
│ └─md1                9:1    0    2G  0 raid1
└─sdc2                 8:34   0  511M  0 part
  └─md0                9:0    0 1017M  0 raid0
```

8. Создайте 2 независимых PV на получившихся md-устройствах.

###### Ответ:

  ```bash
  root@vagrant:/home/vagrant# pvcreate /dev/md1 /dev/md0
    Physical volume "/dev/md1" successfully created.
    Physical volume "/dev/md0" successfully created.
  ```

9. Создайте общую volume-group на этих двух PV.

###### Ответ:

  ```bash
  root@vagrant:/home/vagrant# vgcreate volGrp /dev/md1 /dev/md0
    Volume group "volGrp" successfully created
  root@vagrant:/home/vagrant# vgdisplay
    --- Volume group ---
    VG Name               vgvagrant
    System ID
    Format                lvm2
    Metadata Areas        1
    Metadata Sequence No  3
    VG Access             read/write
    VG Status             resizable
    MAX LV                0
    Cur LV                2
    Open LV               2
    Max PV                0
    Cur PV                1
    Act PV                1
    VG Size               <63.50 GiB
    PE Size               4.00 MiB
    Total PE              16255
    Alloc PE / Size       16255 / <63.50 GiB
    Free  PE / Size       0 / 0
    VG UUID               PaBfZ0-3I0c-iIdl-uXKt-JL4K-f4tT-kzfcyE

    --- Volume group ---
    VG Name               volGrp
    System ID
    Format                lvm2
    Metadata Areas        2
    Metadata Sequence No  1
    VG Access             read/write
    VG Status             resizable
    MAX LV                0
    Cur LV                0
    Open LV               0
    Max PV                0
    Cur PV                2
    Act PV                2
    VG Size               <2.99 GiB
    PE Size               4.00 MiB
    Total PE              765
    Alloc PE / Size       0 / 0
    Free  PE / Size       765 / <2.99 GiB
    VG UUID               xRARDg-CGvd-9BM6-Aro5-5VWv-TMuv-NRUQD9
  ```

10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.

###### Ответ:

  ```bash
  root@vagrant:/home/vagrant# lvcreate -L 100M volGrp /dev/md0
    Logical volume "lvol0" created.
    root@vagrant:/home/vagrant# lsblk
  NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
  sda                    8:0    0   64G  0 disk
  ├─sda1                 8:1    0  512M  0 part  /boot/efi
  ├─sda2                 8:2    0    1K  0 part
  └─sda5                 8:5    0 63.5G  0 part
    ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
    └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
  sdb                    8:16   0  2.5G  0 disk
  ├─sdb1                 8:17   0    2G  0 part
  │ └─md1                9:1    0    2G  0 raid1
  └─sdb2                 8:18   0  511M  0 part
    └─md0                9:0    0 1017M  0 raid0
      └─volGrp-lvol0   253:2    0  100M  0 lvm
  sdc                    8:32   0  2.5G  0 disk
  ├─sdc1                 8:33   0    2G  0 part
  │ └─md1                9:1    0    2G  0 raid1
  └─sdc2                 8:34   0  511M  0 part
    └─md0                9:0    0 1017M  0 raid0
      └─volGrp-lvol0   253:2    0  100M  0 lvm
  ```

11. Создайте `mkfs.ext4` ФС на получившемся LV.

###### Ответ:

  ```bash
  root@vagrant:/home/vagrant# mkfs.ext4 /dev/volGrp/lvol0
  mke2fs 1.45.5 (07-Jan-2020)
  Creating filesystem with 25600 4k blocks and 25600 inodes

  Allocating group tables: done
  Writing inode tables: done
  Creating journal (1024 blocks): done
  Writing superblocks and filesystem accounting information: done
  ```

12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.

###### Ответ:

  ```bash
  root@vagrant:/home/vagrant# mkdir /tmp/new
  root@vagrant:/home/vagrant# mount /dev/volGrp/lvol0 /tmp/new/
  ```

13. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.

###### Ответ:

  ```bash
  root@vagrant:/home/vagrant# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
--2022-02-20 16:39:00--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183, 2a02:6b8::183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 22279464 (21M) [application/octet-stream]
Saving to: ‘/tmp/new/test.gz’
/tmp/new/test.gz      100%[=======================>]  21.25M  1.72MB/s    in 27s
2022-02-20 16:39:27 (794 KB/s) - ‘/tmp/new/test.gz’ saved [22279464/22279464]
root@vagrant:/home/vagrant# ls -l /tmp/new
total 21776
drwx------ 2 root root    16384 Feb 20 16:36 lost+found
-rw-r--r-- 1 root root 22279464 Feb 20 15:17 test.gz
  ```

14. Прикрепите вывод `lsblk`.

###### Ответ:

  ```bash
  root@vagrant:/home/vagrant# lsblk
  NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
  sda                    8:0    0   64G  0 disk
  ├─sda1                 8:1    0  512M  0 part  /boot/efi
  ├─sda2                 8:2    0    1K  0 part
  └─sda5                 8:5    0 63.5G  0 part
    ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
    └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
  sdb                    8:16   0  2.5G  0 disk
  ├─sdb1                 8:17   0    2G  0 part
  │ └─md1                9:1    0    2G  0 raid1
  └─sdb2                 8:18   0  511M  0 part
    └─md0                9:0    0 1017M  0 raid0
      └─volGrp-lvol0   253:2    0  100M  0 lvm   /tmp/new
  sdc                    8:32   0  2.5G  0 disk
  ├─sdc1                 8:33   0    2G  0 part
  │ └─md1                9:1    0    2G  0 raid1
  └─sdc2                 8:34   0  511M  0 part
    └─md0                9:0    0 1017M  0 raid0
      └─volGrp-lvol0   253:2    0  100M  0 lvm   /tmp/new
  ```

15. Протестируйте целостность файла:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```

###### Ответ:

  ```bash
  root@vagrant:/home/vagrant# gzip -t /tmp/new/test.gz
  root@vagrant:/home/vagrant# echo $?
  0
  ```

16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.

###### Ответ:

  ```bash
  root@vagrant:/home/vagrant# pvmove /dev/md0
    /dev/md0: Moved: 28.00%
    /dev/md0: Moved: 100.00%
  root@vagrant:/home/vagrant# lsblk
  NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
  sda                    8:0    0   64G  0 disk
  ├─sda1                 8:1    0  512M  0 part  /boot/efi
  ├─sda2                 8:2    0    1K  0 part
  └─sda5                 8:5    0 63.5G  0 part
    ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
    └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
  sdb                    8:16   0  2.5G  0 disk
  ├─sdb1                 8:17   0    2G  0 part
  │ └─md1                9:1    0    2G  0 raid1
  │   └─volGrp-lvol0   253:2    0  100M  0 lvm   /tmp/new
  └─sdb2                 8:18   0  511M  0 part
    └─md0                9:0    0 1017M  0 raid0
  sdc                    8:32   0  2.5G  0 disk
  ├─sdc1                 8:33   0    2G  0 part
  │ └─md1                9:1    0    2G  0 raid1
  │   └─volGrp-lvol0   253:2    0  100M  0 lvm   /tmp/new
  └─sdc2                 8:34   0  511M  0 part
    └─md0                9:0    0 1017M  0 raid0
  ```

17. Сделайте `--fail` на устройство в вашем RAID1 md.

###### Ответ:

  ```bash
  root@vagrant:/home/vagrant# mdadm /dev/md1 --fail /dev/sdb1
  mdadm: set /dev/sdb1 faulty in /dev/md1
  root@vagrant:/home/vagrant# mdadm -D /dev/md1
  /dev/md1:
             Version : 1.2
       Creation Time : Sun Feb 20 16:20:27 2022
          Raid Level : raid1
          Array Size : 2094080 (2045.00 MiB 2144.34 MB)
       Used Dev Size : 2094080 (2045.00 MiB 2144.34 MB)
        Raid Devices : 2
       Total Devices : 2
         Persistence : Superblock is persistent

         Update Time : Sun Feb 20 16:52:29 2022
               State : clean, degraded
      Active Devices : 1
     Working Devices : 1
      Failed Devices : 1
       Spare Devices : 0

  Consistency Policy : resync

                Name : vagrant:1  (local to host vagrant)
                UUID : d646be1a:a1d820fd:b015a16b:772eee25
              Events : 19

      Number   Major   Minor   RaidDevice State
         -       0        0        0      removed
         1       8       33        1      active sync   /dev/sdc1

         0       8       17        -      faulty   /dev/sdb1
  ```

18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.

###### Ответ:

  ```bash
  root@vagrant:/home/vagrant# dmesg |grep md1
  [ 1967.544299] md/raid1:md1: not clean -- starting background reconstruction
  [ 1967.544302] md/raid1:md1: active with 2 out of 2 mirrors
  [ 1967.544407] md1: detected capacity change from 0 to 2144337920
  [ 1967.545174] md: resync of RAID array md1
  [ 1978.060699] md: md1: resync done.
  [ 3888.866373] md/raid1:md1: Disk failure on sdb1, disabling device.
                 md/raid1:md1: Operation continuing on 1 devices.
  ```

19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```

###### Ответ:

  ```bash
  root@vagrant:/home/vagrant# gzip -t /tmp/new/test.gz
  root@vagrant:/home/vagrant# echo $?
  0
  ```

20. Погасите тестовый хост, `vagrant destroy`.

###### Ответ:

  ```bash
  vagrant@vagrant:~$ exit
  logout
  Connection to 127.0.0.1 closed.
  ❯ vagrant destroy
      default: Are you sure you want to destroy the 'default' VM? [y/N] y
  ==> default: Forcing shutdown of VM...
  ==> default: Destroying VM and associated drives...
  ```
