output "internal_ip_address_vm1_yandex_cloud" {
  value = "${yandex_compute_instance.vm1.network_interface.0.ip_address}"
}

output "external_ip_address_vm1_yandex_cloud" {
  value = "${yandex_compute_instance.vm1.network_interface.0.nat_ip_address}"
}

output "internal_ip_address_vm2_yandex_cloud" {
  value = "${yandex_compute_instance.vm2.network_interface.0.ip_address}"
}

output "internal_ip_address_nat_instance_yandex_cloud" {
  value = "${yandex_compute_instance.nat-instance.network_interface.0.ip_address}"
}

output "external_ip_address_nat_instance_yandex_cloud" {
  value = "${yandex_compute_instance.nat-instance.network_interface.0.nat_ip_address}"
}

