data template_file "index_html_file" {
  template = file("${"./html/index.html"}")
  vars = {
    path = "https://www.${var.dns_domain}/${yandex_storage_object.test-picture.key}"
  }
}