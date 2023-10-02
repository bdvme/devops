resource "yandex_storage_bucket" "netology-bucket-2023" {
  access_key = "${yandex_iam_service_account_static_access_key.sa-static-key.access_key}"
  secret_key = "${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"
  
  bucket     = "netology-bucket-2023"

  max_size = 0

  anonymous_access_flags {
    read = true
    list = false
  }
}