# Заменить на ID своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
# Узнать командой: yc config list | grep cloud-id
variable "yandex_cloud_id" {
  default = "b1guptrv7v7c8mtp5kof"
}

# Заменить на Folder своего облака
# https://console.cloud.yandex.ru/cloud?section=overview
# Узнать командой: yc config list | grep folder-id
variable "yandex_folder_id" {
  default = "b1g9s0cv770m9p5ei3n1"
}

# Заменить на ID своего образа
# ID можно узнать с помощью команды yc compute image list --format yaml | grep -w id:
variable "centos-7-base" {
  default = "fd8juo8ak9e5bdsbduu8"
}
