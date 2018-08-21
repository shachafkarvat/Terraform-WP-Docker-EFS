resource "aws_iam_role" "nginx" {
  name = "nginx-s3-ro"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "nginx" {
  name = "${var.basename}-nginx"

  role = "${aws_iam_role.nginx.name}"

  #   depends_on = [
  #     "aws_iam_role.nginx",
  #   ]
}

resource "aws_iam_role_policy" "s3-ro" {
  name = "nginx-s3-readonly"

  #   description = "Nginx instances ro access to atrtefacts bucket"
  role = "${aws_iam_role.nginx.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["s3:ListBucket"],
            "Resource": ["${aws_s3_bucket.artefacts.arn}"]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject"
            ],
            "Resource": ["${aws_s3_bucket.artefacts.arn}/*"]
        }
    ]
}
EOF
}
