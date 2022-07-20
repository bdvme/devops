resource "local_file" "yc_external_ip" {
  content = <<-DOC
    {
      "node01_netology_yc": "${yandex_compute_instance.node01.network_interface.0.nat_ip_address}"
    }
    DOC
  filename = "./yc_external_ip.yml"

  depends_on = [
    yandex_compute_instance.node01
  ]
}
