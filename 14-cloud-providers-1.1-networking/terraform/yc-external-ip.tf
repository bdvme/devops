resource "local_file" "yc_external_ip" {
  content = <<-DOC
    {
      "vm1_netology_yc": "${yandex_compute_instance.vm1.network_interface.0.nat_ip_address}"
      "nat-instance_netology_yc": "${yandex_compute_instance.nat-instance.network_interface.0.nat_ip_address}"
    }
    DOC
  filename = "./yc_external_ip.yml"

  depends_on = [
    yandex_compute_instance.vm1,
    yandex_compute_instance.nat-instance
  ]
}
