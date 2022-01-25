*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 3.3 Операционные системы, лекция 1

1. Какой системный вызов делает команда `cd`? В прошлом ДЗ мы выяснили, что `cd` не является самостоятельной программой, это `shell builtin`, поэтому запустить `strace` непосредственно на `cd` не получится. Тем не менее, вы можете запустить `strace` на `/bin/bash -c 'cd /tmp'`. В этом случае вы увидите полный список системных вызовов, которые делает сам `bash` при старте. Вам нужно найти тот единственный, который относится именно к `cd`. Обратите внимание, что `strace` выдаёт результат своей работы в поток `stderr`, а не в `stdout`.

Команда `cd` встроенного типа. Она встроена в оболочку `bash`, в которой вызывается системная POSIX-функция языка Си `chdir()`.

При запуске команды `strace /bin/bash -c 'cd /tmp'` происходит вызов системной POSIX-функции `chdir("/tmp")`

2. Попробуйте использовать команду `file` на объекты разных типов на файловой системе. Например:

```
vagrant@netology1:~$ file /dev/tty
/dev/tty: character special (5/0)
vagrant@netology1:~$ file /dev/sda
/dev/sda: block special (8/0)
vagrant@netology1:~$ file /bin/bash
/bin/bash: ELF 64-bit LSB shared object, x86-64
```

Используя `strace` выясните, где находится база данных `file` на основании которой она делает свои догадки.

В соответствии с `man 5 magic` в файле `/usr/share/misc/magic.mgc` содержится база данных шаблонов `magic patterns` на основании которых выводится информация.

Проверим это используя `strace`, не забывая, что `strace` выдаёт результат своей работы в поток `stderr`, а не в `stdout`, поменяем местами потоки используя следующую конструкцию `4>&1 1>&2 2>&4`.
Итоговый вывод команды ниже:

```
vagrant@vagrant:~$ strace file /dev/tty 4>&1 1>&2 2>&4 | grep magic
openat(AT_FDCWD, "/lib/x86_64-linux-gnu/libmagic.so.1", O_RDONLY|O_CLOEXEC) = 3
stat("/home/vagrant/.magic.mgc", 0x7ffd4dcff5d0) = -1 ENOENT (No such file or directory)
stat("/home/vagrant/.magic", 0x7ffd4dcff5d0) = -1 ENOENT (No such file or directory)
openat(AT_FDCWD, "/etc/magic.mgc", O_RDONLY) = -1 ENOENT (No such file or directory)
stat("/etc/magic", {st_mode=S_IFREG|0644, st_size=111, ...}) = 0
openat(AT_FDCWD, "/etc/magic", O_RDONLY) = 3
openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3
/dev/tty: character special (5/0)
vagrant@vagrant:~$
```

3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).

Проверим занятое место на диске с помощью команды `df -h`

```
vagrant@vagrant:~$ df -h
Filesystem                         Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv   31G  3.8G   26G  13% /
...
```

Создадим большой файл командой `dd`

```
vagrant@vagrant:~$ dd if=/dev/zero of=file.img bs=2G count=1
0+1 records in
0+1 records out
2147479552 bytes (2.1 GB, 2.0 GiB) copied, 21.0108 s, 102 MB/s
```

Проверим размер файла

```
vagrant@vagrant:~$ du -shc ./*
2.0G	./file.img
2.0G	total
```

Сымитируем блокировку файла командой `less`
```
vagrant@vagrant:~$ less +F ./file.img > /dev/null &
[1] 1890
```

Удалим файл командой `rm`

```
vagrant@vagrant:~$ rm -f file.img
```

Проверим занятое место на диске

```
vagrant@vagrant:~$ df -h
Filesystem                         Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv   31G  5.8G   24G  20% /
```

Место не освободилось.

Посмотрим что происходит с помощью команды `lsof`

```
vagrant@vagrant:~$ lsof | grep deleted
less      1890                        vagrant    3r      REG              253,0 2147479552    1048609 /home/vagrant/file.img (deleted)
```

Командой `echo '' > /proc/1890/fd/3` обнулим удаленный файл и проверим свободное место.

```
vagrant@vagrant:~$ echo '' > /proc/1890/fd/3
vagrant@vagrant:~$ df -h
Filesystem                         Size  Used Avail Use% Mounted on
/dev/mapper/ubuntu--vg-ubuntu--lv   31G  3.8G   26G  13% /
```

4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?

Зомби не занимают памяти (как процессы-сироты), но блокируют записи в таблице процессов, размер которой ограничен для каждого пользователя и системы в целом.
Зомби-процесс существует до тех пор, пока родительский процесс не прочитает его статус с помощью системного вызова `wait()`, в результате чего запись в таблице процессов будет освобождена.

5. В iovisor BCC есть утилита opensnoop:

```
root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
/usr/sbin/opensnoop-bpfcc
```

На какие файлы вы увидели вызовы группы `open` за первую секунду работы утилиты? Воспользуйтесь пакетом `bpfcc-tools` для `Ubuntu 20.04`.

```
vagrant@vagrant:~$ sudo opensnoop-bpfcc
PID    COMM               FD ERR PATH
657    irqbalance          6   0 /proc/interrupts
657    irqbalance          6   0 /proc/stat
657    irqbalance          6   0 /proc/irq/20/smp_affinity
657    irqbalance          6   0 /proc/irq/0/smp_affinity
657    irqbalance          6   0 /proc/irq/1/smp_affinity
657    irqbalance          6   0 /proc/irq/8/smp_affinity
657    irqbalance          6   0 /proc/irq/12/smp_affinity
657    irqbalance          6   0 /proc/irq/14/smp_affinity
657    irqbalance          6   0 /proc/irq/15/smp_affinity
836    vminfo              4   0 /var/run/utmp
```

6. Какой системный вызов использует `uname -a`? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в `/proc`, где можно узнать версию ядра и релиз ОС.

`uname -a` использует системный вызов `uname({sysname="Linux", nodename="vagrant", ...})`

```
vagrant@vagrant:~$ man 2 uname | grep /proc
       Part of the utsname information is also accessible via /proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}.
```

7. Чем отличается последовательность команд через `;` и через `&&` в `bash`?
Например:

```
root@netology1:~# test -d /tmp/some_dir; echo Hi
Hi
root@netology1:~# test -d /tmp/some_dir && echo Hi
root@netology1:~#
```

Есть ли смысл использовать в `bash` `&&`, если применить `set -e`?

`&&` - условный оператор
`;` - разделитель последовательных команд

`test -d /tmp/some_dir && echo Hi` - `echo` выведет `Hi` только при успешном завершении команды `test`

`set -e` - прерывает сессию при любом, отличном от нуля, значении статуса исполняемых команд.

`set -e test -d /tmp/some_dir && echo Hi` - `echo` выведет `Hi` в любом случае.

8. Из каких опций состоит режим bash set -euxo pipefail и почему его хорошо было бы использовать в сценариях?

`-e` прерывает выполнение команды при любой ошибке в последовательности команд кроме последней  
`-x` вывод команды с их аргументами
`-u` не установленные или не заданные параметры и переменные считаются как ошибки, с выводом в `stderr` текста ошибки и завершением не интерактивного вызова
`-o pipefail` возвращает значение статуса выхода последней (самой правой) команды, завершённой с ненулевым статусом, или ноль — если работа всех команд завершена успешно.

Причина использования `pipefail` заключается в том, что иначе команда, неожиданно завершившаяся с ошибкой и находящаяся где-нибудь в середине конвейера, обычно остаётся незамеченной. Она, при использовании опции `set -e`, не приведёт к аварийному завершению скрипта.

9. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе. В `man ps` ознакомьтесь (`/PROCESS STATE CODES`) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).

Самые частые процессы в системе:

```
vagrant@vagrant:~$ ps -o stat
STAT
Ss
R+
```

`Ss` - Процессы ожидающие (спящие менее 20 секунд)
`R+` - Процессы выполняющиеся в данный момент

PROCESS STATE CODES:

`R` - процесс выполняется в данный момент;
`S` - процесс ожидает (т.е. спит менее 20 секунд);
`I` - процесс бездействует (т.е. спит больше 20 секунд);
`D` - процесс ожидает ввода-вывода (или другого недолгого события), непрерываемый;
`Z` - `zombie` или `defunct` процесс, то есть завершившийся процесс, код возврата которого пока не считан родителем;
`T` - процесс остановлен;
`W` - процесс в свопе;
`<` - процесс в приоритетном режиме;
`N` - процесс в режиме низкого приоритета;
`L` - real-time процесс, имеются страницы, заблокированные в памяти;
`s` - лидер сессии;
`l` - мультипоточный.
