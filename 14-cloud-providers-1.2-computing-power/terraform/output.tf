output "internal_ip_address_group_instance_yandex_cloud" {
  value = "${yandex_compute_instance_group.vm-group.instances.*.network_interface.0.ip_address}"
}

output "external_ip_address_vm1_yandex_cloud" {
  value = "${yandex_compute_instance.vm1.network_interface.0.nat_ip_address}"
}

output "net-lb-address" {
  value = "${yandex_lb_network_load_balancer.net-lb.listener.*.external_address_spec[0].*.address}"
}

output "userdata" {
  value = "${template_file.userdata.rendered}"
}