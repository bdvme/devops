provider "yandex" {
  service_account_key_file = "key_admin.json"
  cloud_id  = "${var.yandex_cloud_id}"
  folder_id = "${var.yandex_folder_id}"
}
