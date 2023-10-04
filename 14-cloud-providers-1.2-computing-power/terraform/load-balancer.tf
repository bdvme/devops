resource "yandex_lb_network_load_balancer" "net-lb" {
  name = "net-lb"

  listener {
    name = "net-lb-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = "${yandex_compute_instance_group.vm-group.load_balancer.0.target_group_id}"

    healthcheck {
      name = "http"
      interval = 2
      timeout = 1
      unhealthy_threshold = 2
      healthy_threshold = 5
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}