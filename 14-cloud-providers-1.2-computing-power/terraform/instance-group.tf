resource "yandex_compute_instance_group" "vm-group" {
  name               = "vm-group"
  folder_id          = "${var.yandex_folder_id}"
  service_account_id = "${yandex_iam_service_account.sa-vm.id}"

  depends_on = [
      yandex_resourcemanager_folder_iam_member.sa-storage-editor,
      yandex_resourcemanager_folder_iam_member.sa-vm-editor
    ]
  
  instance_template {
    platform_id = "standard-v3"
    resources {
      memory = 2
      cores  = 2
    }

    boot_disk {
      initialize_params {
        image_id = "${var.yandex_group_image_id}"
      }
    }

    network_interface {
      network_id = "${yandex_vpc_network.vpc.id}"
      security_group_ids = ["${yandex_vpc_security_group.nat-instance-sg.id}"]
      subnet_ids = ["${yandex_vpc_subnet.private-subnet.id}"]
    }

    metadata = {
      user-data = "${template_file.userdata.rendered}"
    }

    labels = {
      group = "net-lb"
    }

    scheduling_policy {
      preemptible = true
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["${var.yandex_zone}"]
  }

  deploy_policy {
    max_creating = 3
    max_deleting = 1
    max_unavailable = 0
    max_expansion = 2
    startup_duration = 30
  }

  health_check {
    interval = 2
    timeout = 1
    healthy_threshold = 5
    unhealthy_threshold = 2
    http_options {
      path = "/"
      port = 80
    }
  }

  load_balancer {
    target_group_name        = "net-lb-group"
    target_group_description = "Group for network balancer"
  }
}