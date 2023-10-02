# Service account for access to backet
resource "yandex_iam_service_account" "sa-backet" {
  name        = "sa-backet"
  description = "service account for access to basket"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-storage-editor" {
  folder_id = "${var.yandex_folder_id}"
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-backet.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = "${yandex_iam_service_account.sa-backet.id}"
  description        = "static access key for object storage"
}

#Service account for managing a group of VMs
resource "yandex_iam_service_account" "sa-vm" {
  name        = "sa-vm"
  description = "Service account for managing a group of VMs"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-vm-editor" {
  folder_id = "${var.yandex_folder_id}"
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-vm.id}"
}