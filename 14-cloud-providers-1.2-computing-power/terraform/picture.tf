resource "yandex_storage_object" "test-picture" {
  access_key = "${yandex_iam_service_account_static_access_key.sa-static-key.access_key}"
  secret_key = "${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"
  bucket     = "${yandex_storage_bucket.netology-bucket-2023.id}"
  key        = "picture.jpg"
  source     = "${var.picture}"
  content_type = "image/jpg"
  acl = "public-read"
}