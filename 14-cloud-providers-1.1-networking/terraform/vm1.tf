resource "yandex_compute_instance" "vm1" {
  name                      = "vm1"
  zone                      = "${var.yandex_zone}"
  hostname                  = "vm1.netology.cloud"
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
    subnet_id = "${yandex_vpc_subnet.public-subnet.id}"
    nat = true
  }

  metadata = {
    user-data = "#cloud-config\nusers:\n  - name: ${var.vm1_user_name}\n    groups: sudo\n    shell: /bin/bash\n    sudo: 'ALL=(ALL) NOPASSWD:ALL'\n    ssh-authorized-keys:\n      - ${file("${var.ssh_key_path}")}"
  }

  scheduling_policy {
    preemptible = true
  }
}
