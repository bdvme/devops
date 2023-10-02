resource "yandex_compute_instance" "nat-instance" {
  name                      = "vmnat"
  zone                      = "${var.yandex_zone}"
  platform_id               = "standard-v3"
  allow_stopping_for_update = true

  resources {
    core_fraction = 20
    cores         = 2
    memory        = 2
  }

  boot_disk {
    initialize_params {
      image_id = "${var.yandex_nat_image_id}"
    }
  }

  network_interface {
    subnet_id          = "${yandex_vpc_subnet.public-subnet.id}"
    security_group_ids = ["${yandex_vpc_security_group.nat-instance-sg.id}"]
    nat                = true
    ipv4      = true
    ip_address = "192.168.10.254"
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm_user_name_nat}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }

  scheduling_policy {
    preemptible = true
  }
  
}