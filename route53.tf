resource "aws_route53_record" "taurak_co_uk" {
  zone_id = "${data.aws_route53_zone.dnszone.zone_id}"
  name    = "${var.r53-zone}"
  type    = "A"

  alias {
    name                   = "${aws_elb.nginx-elb.dns_name}"
    zone_id                = "${aws_elb.nginx-elb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "www_taurak_co_uk" {
  zone_id = "${data.aws_route53_zone.dnszone.zone_id}"
  name    = "www.${var.r53-zone}"
  type    = "CNAME"
  ttl     = 5
  records = ["${aws_route53_record.taurak_co_uk.name}"]
}

resource "aws_route53_record" "bastion" {
  zone_id = "${data.aws_route53_zone.dnszone.zone_id}"
  name    = "bastion.${data.aws_route53_zone.dnszone.name}"
  type    = "A"
  ttl     = "30"
  records = ["${aws_instance.bastion.public_ip}"]
}
