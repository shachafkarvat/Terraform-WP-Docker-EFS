resource "aws_iam_role" "nginx" {
  name = "nginx-wp-instance"

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

data "aws_iam_policy" "ReadOnlyAccess" {
  arn = "arn:aws:iam::aws:policy/AWSCodeCommitReadOnly"
}

resource "aws_iam_role_policy_attachment" "codecommit-readonly" {
  role       = "${aws_iam_role.nginx.id}"
  policy_arn = "${data.aws_iam_policy.ReadOnlyAccess.arn}"
}
