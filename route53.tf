resource "aws_route53_record" "tfl" {
  zone_id = "${data.aws_route53_zone.infrastructure_root_domain_zone.zone_id}"
  name    = "tfl-dashboard.${var.environment}.${var.infrastructure_name}.${var.root_domain_zone}."
  type    = "CNAME"
  ttl     = "3600"

  records = [
    "${module.app-service.lb_dns_name}",
  ]
}
