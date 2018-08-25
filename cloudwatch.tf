resource "aws_cloudwatch_log_group" "cloudwatch_group" {
  name              = "cloudwatch_group"
  retention_in_days = "${var.logs_retention_in_days}"
  tags              = "${merge(var.default_tags, map("Name", format("%s-group", var.basename)))}"
}

resource "aws_cloudwatch_log_stream" "cloudwatch_stream" {
  name           = "${var.basename}-${var.regionshort}-logs"
  log_group_name = "${aws_cloudwatch_log_group.cloudwatch_group.name}"
}
