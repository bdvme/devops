resource "yandex_storage_bucket" "netology-bucket-2023" {
  access_key = "${yandex_iam_service_account_static_access_key.sa-static-key.access_key}"
  secret_key = "${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"
  
  bucket     = "netology-bucket-2023"

  max_size = 0

  anonymous_access_flags {
    read = true
    list = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${yandex_kms_symmetric_key.key-a.id}"
        sse_algorithm     = "aws:kms"
      }
    }
  }

  depends_on = [ 
    yandex_resourcemanager_folder_iam_member.sa-storage-editor, 
    yandex_resourcemanager_folder_iam_member.sa-storage-enc-dec
  ]
}