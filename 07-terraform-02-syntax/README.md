*Студент: Дмитрий Багрянский*

# Домашняя работа

## Урок 7.2. Облачные провайдеры и синтаксис Terraform.

## Задача 1 (Вариант с Yandex.Cloud). Регистрация в ЯО и знакомство с основами (необязательно, но крайне желательно).

1. Подробная инструкция на русском языке содержится [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
2. Обратите внимание на период бесплатного использования после регистрации аккаунта.
3. Используйте раздел "Подготовьте облако к работе" для регистрации аккаунта. Далее раздел "Настройте провайдер" для подготовки
базового терраформ конфига.
4. Воспользуйтесь [инструкцией](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs) на сайте терраформа, что бы
не указывать авторизационный токен в коде, а терраформ провайдер брал его из переменных окружений.

###### Ответ:

* Подготовил Yandex Cloud к работе.

## Задача 2. Создание aws ec2 или yandex_compute_instance через терраформ.

1. В каталоге `terraform` вашего основного репозитория, который был создан в начале курсе, создайте файл `main.tf` и `versions.tf`.
2. Зарегистрируйте провайдер
   1. для [aws](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). В файл `main.tf` добавьте
   блок `provider`, а в `versions.tf` блок `terraform` с вложенным блоком `required_providers`. Укажите любой выбранный вами регион
   внутри блока `provider`.
   2. либо для [yandex.cloud](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs). Подробную инструкцию можно найти
   [здесь](https://cloud.yandex.ru/docs/solutions/infrastructure-management/terraform-quickstart).
3. Внимание! В гит репозиторий нельзя пушить ваши личные ключи доступа к аккаунту. Поэтому в предыдущем задании мы указывали
их в виде переменных окружения.
4. В файле `main.tf` воспользуйтесь блоком `data "aws_ami` для поиска ami образа последнего Ubuntu.  
5. В файле `main.tf` создайте рессурс
   1. либо [ec2 instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance).
   Постарайтесь указать как можно больше параметров для его определения. Минимальный набор параметров указан в первом блоке
   `Example Usage`, но желательно, указать большее количество параметров.
   2. либо [yandex_compute_image](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_image).
6. Также в случае использования aws:
   1. Добавьте data-блоки `aws_caller_identity` и `aws_region`.
   2. В файл `outputs.tf` поместить блоки `output` с данными об используемых в данный момент:
       * AWS account ID,
       * AWS user ID,
       * AWS регион, который используется в данный момент,
       * Приватный IP ec2 инстансы,
       * Идентификатор подсети в которой создан инстанс.  
7. Если вы выполнили первый пункт, то добейтесь того, что бы команда `terraform plan` выполнялась без ошибок.

###### Ответ:

* Создание ВМ в YC происходит с помощью инструментов Vagrant, Ansible, Packer, Terraform.

* Для создания ВМ нужно перейти в каталог `./src/vagrant`, затем ввести `vagrant up`.

* В ходе развертывания локальной ВМ будет установлен и проинициализирован, для работы с YC, Terraform, будет установлен и подготовлен для работы YC, также будет установлен Packer. Токен авторизации для YC содержится в файле `.env`, который парсится при создании локальной ВМ.

```bash
cat .env
yandex_token=[OAuth_token]
yandex_zone=ru-central1-a
yandex_cloud_id=b1guptrv7v7c8mtp5kof
yandex_folder_id=b1g9s0cv770m9p5ei3n1
yandex_service_acc=service-acc01
```

* Дерево каталогов и файлов

```bash
.
├── .gitignore
├── README.md
└── src
    ├── ansible
    │   ├── inventory
    │   ├── provision.yml
    │   └── stack
    │       ├── etc
    │       │   ├── apt
    │       │   │   ├── apt.conf.d
    │       │   │   │   └── 01proxy
    │       │   │   └── sources.list
    │       │   └── tor
    │       │       └── torrc
    │       └── opt
    │           ├── packer
    │           │   ├── create_image.sh
    │           │   ├── erase.sh
    │           │   └── yc-toolbox.pkr.hcl
    │           └── terraform
    │               ├── .terraformrc
    │               ├── key.json
    │               ├── main.tf
    │               ├── network.tf
    │               ├── node01.tf
    │               ├── output.tf
    │               ├── variables.tf
    │               └── version.tf
    └── vagrant
        ├── .env
        ├── Vagrantfile
        └── ansible.cfg
```

* С помощью инструмента Packer создается образ в YC из файла `./src/ansible/stack/opt/packer/yc-toolbox.pkr.hcl`

* Затем этот образ используется для создания ВМ в YC с помощью Terraform.

* Terraform инфрастуктура `./src/ansible/stack/opt/terraform`
