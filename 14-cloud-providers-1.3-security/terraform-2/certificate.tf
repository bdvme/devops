resource "yandex_cm_certificate" "le-certificate" {
  name    = "bdvsun-ru"
  domains = ["${var.dns_domain}", "*.${var.dns_domain}"]

  managed {
  challenge_type = "DNS_CNAME"
  }
}

resource "yandex_dns_recordset" "validation-record" {
  zone_id = "${yandex_dns_zone.zone1.id}"
  name    = "${yandex_cm_certificate.le-certificate.challenges[0].dns_name}"
  type    = "${yandex_cm_certificate.le-certificate.challenges[0].dns_type}"
  data    = [yandex_cm_certificate.le-certificate.challenges[0].dns_value]
  ttl     = 600
}

data "yandex_cm_certificate" "bdvsun-ru" {
  depends_on      = [yandex_dns_recordset.validation-record]
  certificate_id  = "${yandex_cm_certificate.le-certificate.id}"
  wait_validation = true
}

output "cert-id" {
  description = "Certificate ID"
  value       = "${data.yandex_cm_certificate.bdvsun-ru.id}"
}

