resource template_file "userdata" {
  template = "${file("./templates/userdata.yml")}"

  vars = {
    username       = "${var.vm_user_name}"
    ssh_public_key = "${file(var.ssh_key_path)}"
    contents       = "${template_file.index_html_file.rendered}"
  }
}


resource template_file "index_html_file" {
  template = file("${"./html/index.html"}")
  vars = {
    path = "${yandex_storage_bucket.netology-bucket-2023.bucket_domain_name}/${yandex_storage_object.test-picture.key}"
  }
}