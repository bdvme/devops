resource "yandex_storage_bucket" "bucket01" {
  access_key = "${yandex_iam_service_account_static_access_key.sa-static-key.access_key}"
  secret_key = "${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"
  
  bucket     = "www.${var.dns_domain}"

  acl        = "public-read"

  anonymous_access_flags {
    read = true
    list = false
  }

  max_size = 0

  https {
    certificate_id = "${yandex_cm_certificate.le-certificate.id}"
  }

  website {
    index_document = "index.html"
  }
  depends_on = [ 
    yandex_resourcemanager_folder_iam_member.sa-storage-editor,
    yandex_cm_certificate.le-certificate
   ]
}