# Узнать командой: yc config list | grep cloud-id
variable "yandex_cloud_id" {
  default = "yandex_cloud_id"
}

# Узнать командой: yc config list | grep folder-id
variable "yandex_folder_id" {
  default = "yandex_folder_id"
}

# ID можно узнать с помощью команды yc compute image list --format yaml | grep -w id:
variable "yandex_image_id" {
  default = "yandex_image_id"
}
