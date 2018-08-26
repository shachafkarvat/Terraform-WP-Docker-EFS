resource "aws_cloudwatch_log_group" "cloudwatch_group" {
  name              = "${var.basename}-${var.regionshort}-logs"
  retention_in_days = "${var.logs_retention_in_days}"
  tags              = "${merge(var.default_tags, map("Name", format("%s-group", var.basename)))}"
}

resource "aws_cloudwatch_log_stream" "nginx_stream" {
  name           = "${var.basename}-${var.regionshort}-nginx"
  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_group.name}"
}

resource "aws_cloudwatch_log_stream" "wordpress_stream" {
  name           = "${var.basename}-${var.regionshort}-wordpress"
  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_group.name}"
}
