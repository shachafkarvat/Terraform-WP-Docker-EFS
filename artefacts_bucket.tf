resource "aws_s3_bucket" "artefacts" {
  bucket = "${var.artefacts_s3}"
  acl    = "private"

  tags {
    Name        = "My bucket"
    Environment = "PROD"
  }
}
