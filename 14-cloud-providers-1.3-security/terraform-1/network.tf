# Network
resource "yandex_vpc_network" "vpc" {
  name = "local.network_name"
}

resource "yandex_vpc_subnet" "public-subnet" {
  name = "local.subnet_name1"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.vpc.id}"
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "private-subnet" {
  name = "local.subnet_name2"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.vpc.id}"
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id = "${yandex_vpc_route_table.nat-instance-route.id}"
}