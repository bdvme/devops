resource "yandex_compute_instance" "vm2" {
  name                      = "vm2"
  zone                      = "${var.yandex_zone}"
  hostname                  = "vm2.netology.cloud"
  platform_id               = "standard-v3"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "${var.yandex_image_id}"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.private-subnet.id}"
    security_group_ids = ["${yandex_vpc_security_group.nat-instance-sg.id}"]
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm2_user_name}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }

  scheduling_policy {
    preemptible = true
  }
}
