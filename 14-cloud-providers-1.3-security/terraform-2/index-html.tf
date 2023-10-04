locals {
  index-html-content = "${data.template_file.index_html_file.rendered}"
}
resource "local_file" "index-file-html" {
  filename = "index.html"
  content  = "${local.index-html-content}"
}
resource "yandex_storage_object" "index-html" {
  access_key = "${yandex_iam_service_account_static_access_key.sa-static-key.access_key}"
  secret_key = "${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"
  bucket     = "${yandex_storage_bucket.bucket01.id}"
  key        = "index.html"
  source     = "index.html"
  acl = "public-read"
  depends_on = [ 
    local_file.index-file-html,
    yandex_resourcemanager_folder_iam_member.sa-storage-editor,
    yandex_storage_bucket.bucket01
  ]
}