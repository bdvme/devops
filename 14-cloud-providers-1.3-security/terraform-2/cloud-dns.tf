resource "yandex_dns_zone" "zone1" {
  name   = replace(var.dns_domain, ".", "-")
  zone   = join("", [var.dns_domain, "."])
  public = true
}

resource "yandex_dns_recordset" "rs-aname-1" {
  zone_id = "${yandex_dns_zone.zone1.id}"
  name    = "www"
  type    = "ANAME"
  ttl     = 200
  data    = ["www.${var.dns_domain}.website.yandexcloud.net"]
}
/*
resource "yandex_dns_recordset" "rs-cname-2" {
  zone_id = "${yandex_dns_zone.zone1.id}"
  name    = "@"
  type    = "CNAME"
  ttl     = 200
  data    = ["www.${var.dns_domain}.website.yandexcloud.net"]
}
*/