*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 2.2 Основы Git

## Задание #1 (Знакомство с GitLab и BitBucket)

Подключил GitLab и Bitbucket
- [GitLab](https://gitlab.com/bdvme/devops)
- [BitBucket](https://bitbucket.com/bdvme/devops)

В этом задании использовал:
- `git remote add [name_repo] [link]` - подключение удаленного репозитория
- `git remote -v` - вывод подключенных репозиториев
- `git push -u [name_repo] [name_branch]` - отправка локальных изменений в удаленные репозитории

 ## Задание #2 (Теги)

 Создал теги [v0.0](https://github.com/bdvme/devops/releases/tag/v0.0) (легковесный), [v1.0](https://github.com/bdvme/devops/releases/tag/v1.0) (с аннотацией) и добавил их в репозитории [GitHub](https://github.com/bdvme), [GitLab](https://gitlab.com/bdvme), [BitBucket](https://bitbucket.com/bdvme)

 Для этого использовал следующие команды:
 - `git tag [name_tag]` - создание _"легковесного тега"_
 - `git tag -a [name_tag] -m [annotation]` - добавление тега с аннотацией
 - `git push [name_repo] [name_tag]` - отправка тега в удаленные репозитории
 - `git push [name_repo] --tags` - отправка всех тегов

 ## Задание #3 (Ветки)

 Переключился на commit [Prepare to delete and move](https://github.com/bdvme/devops/commit/245279373705200be0b315915fbd9beaf5017b25)<br/>
 Создал ветку [fix](https://github.com/bdvme/devops/tree/fix)<br/>
 Внес изменения в файл README.md и отправил изменения в репозиторий.<br/>

 В задании использовал:
 - `git log` - вывод log по commit
 - `git checkout [commit]` - переключение на commit
 - `git checkout -b [name_branch]` - создание и переключение на новую ветку

 ## Задание #4 (PyCharm)

 Задание 4 выполнил в PyCharm и отправил в ветку main [GitHub](https://github.com/bdvme/devops/commit/50b16f15f5b8eec2c98217a42562f43582048d06)
