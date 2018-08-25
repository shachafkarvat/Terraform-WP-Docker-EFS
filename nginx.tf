## Creating Launch Configuration
resource "aws_launch_configuration" "nginx-lc" {
  image_id = "${data.aws_ami.ubuntu.id}"

  # image_id                    = "${var.ami}"
  instance_type        = "${var.ec2-size}"
  security_groups      = ["${aws_security_group.nginx-sg.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.nginx.id}"
  key_name             = "${var.keyname}"

  #   name                        = "${var.basename}-lc"
  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/sh
hostname Nginx
apt-get update
apt install -y docker.io awscli docker-compose
while [ ! -S /var/run/docker.sock ] ; do sleep 2; done
aws s3 cp s3://taurak.co.uk-artefacts/debs/amazon-efs-utils-1.3-1.deb /root
apt-get -y install /root/amazon-efs-utils*deb 
chgrp ubuntu /var/run/docker.sock

echo "=== cloning docker ==="
mkdir /usr/SRC
chown ubuntu:ubuntu /usr/SRC
git clone --config credential.helper='!aws --region=eu-wast-1 codecommit credential-helper $@' --config credential.UseHttpPath=true "${var.docker_repo}" /usr/SRC


echo "=== Mounting EFS ==="
mkdir /mnt/WWW
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.www-root.id}.efs.eu-west-1.amazonaws.com:/ /mnt/WWW
# chown ubuntu:ubuntu /mnt/WWW
docker volume create --driver local --opt type=nfs --opt o=addr=${aws_efs_file_system.www-root.id}.efs.eu-west-1.amazonaws.com,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport --opt device=:/WP www
docker volume create --driver local --opt type=nfs --opt o=addr=${aws_efs_file_system.www-root.id}.efs.eu-west-1.amazonaws.com,nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport --opt device=:/conf.d conf

echo "=== Running nginx ==="
/usr/bin/docker run -d -v www:/usr/share/nginx/html -v conf:/etc/nginx/conf.d -p 80:80 --name=nginx nginx
EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Create the wp-config
data "template_file" "wp-config" {
  template = "${file("./wp-config.php.tmpl")}"

  vars {
    DB_NAME          = "${var.DB_NAME}"
    DB_USER          = "${var.DB_USER}"
    DB_PASSWORD      = "${data.aws_ssm_parameter.rds_password.value}"
    DB_HOST          = "${aws_db_instance.WP-RDS.address}"
    AUTH_KEY         = "${random_string.AUTH_KEY.result}"
    SECURE_AUTH_KEY  = "${random_string.SECURE_AUTH_KEY.result}"
    LOGGED_IN_KEY    = "${random_string.LOGGED_IN_KEY.result}"
    NONCE_KEY        = "${random_string.NONCE_KEY.result}"
    AUTH_SALT        = "${random_string.AUTH_SALT.result}"
    SECURE_AUTH_SALT = "${random_string.SECURE_AUTH_SALT.result}"
    LOGGED_IN_SALT   = "${random_string.LOGGED_IN_SALT.result}"
    NONCE_SALT       = "${random_string.NONCE_SALT.result}"
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket  = "${var.artefacts_s3}"
  key     = "wp-config.php"
  content = "${data.template_file.wp-config.rendered}"

  # etag   = "${md5(file("path/to/file"))}"
}

resource "aws_autoscaling_group" "nginx-asg" {
  launch_configuration = "${aws_launch_configuration.nginx-lc.id}"

  # availability_zones   = ["${data.aws_availability_zones.all.names}"]
  vpc_zone_identifier = ["${aws_subnet.subnet-a.id}", "${aws_subnet.subnet-b.id}", "${aws_subnet.subnet-c.id}"]
  min_size            = 1
  max_size            = 3
  load_balancers      = ["${aws_elb.nginx-elb.name}"]
  health_check_type   = "ELB"

  tags = [{
    key                 = "Name"      # "${merge(var.default_tags, map("Name", format("%s-igw", var.basename)))}"
    value               = "nginx-asg"
    propagate_at_launch = true
  },
    {
      key                 = "RG"
      value               = "WWW"
      propagate_at_launch = true
    },
  ]
}

### Creating ELB
resource "aws_elb" "nginx-elb" {
  name            = "${var.basename}-lb"
  security_groups = ["${aws_security_group.elb-sg.id}"]
  subnets         = ["${aws_subnet.subnet-a.id}", "${aws_subnet.subnet-b.id}", "${aws_subnet.subnet-c.id}"]

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }

  # listener {
  #   lb_port           = 443
  #   lb_protocol       = "http"
  #   instance_port     = "443"
  #   instance_protocol = "https"
  # }
}
