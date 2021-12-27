*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 2.3 Ветвления в Git

## Задание #1

## Подготовка
Каталог `branching` создан в каталоге `02-git-03-branching`, внутри `./02-git-03-branching/branching` созданы два файла `merge.sh` и `rebase.sh` с одинаковым содержимым:
```bash
#!/bin/bash
# display command line options
count=1
for param in "$*"; do
	echo "\$* Parameter #$count = $param"
	count=$(( $count + 1 ))
done
```
Затем был сделан commit с описанием [`prepare for merge and rebase`](https://github.com/bdvme/devops/commit/21aca21eb7f5729286ec301a970f2f0dcc419c6b).

## Файл `merge.sh`
С помощью команды `git checkout -b git-merge` создал новую ветку `git-merge` и перешел на нее.
* Изменил содержимое файла `merge.sh`:
```diff
@@ -2,7 +2,7 @@
 # display command line options

 count=1
- for param in "$*"; do
-	 echo "\$* Parameter #$count = $param"
+ for param in "$@"; do
+	 echo "\$@ Parameter #$count = $param"
	 count=$(( $count + 1 ))
 done
```

* Сделал commit `merge: @ instead *` и отправил его в ветку `git-merge` командой `git push github git-merge`

* Изменил содержимое файла `merge.sh`:
```diff
@@ -2,7 +2,8 @@
 # display command line options

 count=1
- for param in "$@"; do
-	 echo "\$@ Parameter #$count = $param"
+ while [[ -n "$1" ]]; do
+	 echo "Parameter #$count = $1"
	 count=$(( $count + 1 ))
+	 shift
 done
```
* Сделал commit `merge: use shift` и отправил его в ветку `git-merge` командой `git push github git-merge`

## Изменение ветки `main`
С помощью команды `git checkout main` перешел на ветку `main`.
* Изменил содержимое файла `rebase.sh`:
```diff
@@ -2,7 +2,9 @@
 # display command line options

 count=1
- for param in "$*"; do
-	 echo "\$* Parameter #$count = $param"
+ for param in "$@"; do
+	 echo "\$@ Parameter #$count = $param"
	 count=$(( $count + 1 ))
 done
+
+ echo "====="
```
* Сделал commit `main: Change rebase.sh` и отправил его в ветку `main` командой `git push github main`

## Файл `rebase.sh`
* Переключился на commit [`prepare for merge and rebase`](https://github.com/bdvme/devops/commit/21aca21eb7f5729286ec301a970f2f0dcc419c6b)
* С помощью команды `git checkout -b git-rebase` создал новую ветку `git-rebase` и перешел на нее.
* Изменил содержимое файла `rebase.sh`:
```diff
@@ -3,7 +3,7 @@

 count=1
 for param in "$@"; do
-	 echo "\$@ Parameter #$count = $param"
+	 echo "Parameter: $param"
	 count=$(( $count + 1 ))
 done
```
* Сделал commit `git rebase 1` и отправил его в ветку `git-rebase` командой `git push github git-rebase`
* Изменил содержимое файла `rebase.sh`:
```diff
@@ -3,7 +3,7 @@

 count=1
 for param in "$@"; do
-	 echo "Parameter: $param"
+	 echo "Next parameter: $param"
	 count=$(( $count + 1 ))
 done
```
* Сделал commit `git rebase 2` и отправил его в ветку `git-rebase` командой `git push github git-rebase`

## Merge
* Командой `git checkout main` переключился на ветку `main`
* Командой `git merge git-merge` слил ветку `git-merge` в ветку `main`

## Rebase
* Командой `git checkout git-rebase` перехожу на ветку `git-rebase`
* Командой `git rebase -i main` произвожу `Rebase` в интерактивном режиме:
```bash
pick [HASH] git-rebase 1
fixup [HASH] git-rebase 2
```
* Исправляем конфликты:
```bash
#!/bin/bash
# display command line options
count=1
for param in "$@"; do
<<<<<<< HEAD
	echo "\$@ Parameter #$count = $param"
=======
	echo "Parameter: $param"
>>>>>>>  @ instead *
	count=$(( $count + 1 ))
done
```
* Удалил метки `<<<</>>>>/====`, оставив `echo "\$@ Parameter #$count = $param"`
* Командой `git add rebase.sh` сообщил Git'y что конфликт решен и продолжил `Rebase` командой `git rebase --continue`
* Исправил конфликт оставив строчку `echo "Next parameter: $param"`
* Командой `git add rebase.sh` сообщил Git'y что конфликт решен и продолжил `Rebase` командой `git rebase --continue`
* Согласился с commit:
```bash
# This is a combination of 2 commits.
# This is the 1st commit message:

Merge branch 'git-merge'

# The commit message #2 will be skipped:

# git 2.3 rebase @ instead * (2)
```
* Git сообщил об успехе:
`Successfully rebased and updated refs/heads/git-rebase`
* Командой `git push -u github git-rebase -f` отправил локальные изменения в ветку `git-rebase` в GitHub
* Командой `git checkout main` переключился на ветку `main`
* Командой `git merge git-rebase` слил ветку `git-rebase` в ветку `main`
