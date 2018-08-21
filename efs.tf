# Creates a new empty file system in EFS.
#
# Although we're not specifying a VPC_ID here, we can't have
# a EFS assigned to subnets in multiple VPCs.
#
# If we wanted to mount in a differente VPC we'd need to first
# remove all the mount points in subnets of one VPC and only 
# then create the new mountpoints in the other VPC.
resource "aws_efs_file_system" "www-root" {
  tags {
    Name = "${var.basename}-${var.regionshort}"
  }
}

# Creates a mount target of EFS in a specified subnet
# such that our instances can connect to it.
resource "aws_efs_mount_target" "www-root-a" {
  file_system_id = "${aws_efs_file_system.www-root.id}"
  subnet_id      = "${aws_subnet.subnet-a.id}"

  security_groups = [
    "${aws_security_group.efs.id}",
  ]
}

resource "aws_efs_mount_target" "www-root-b" {
  file_system_id = "${aws_efs_file_system.www-root.id}"
  subnet_id      = "${aws_subnet.subnet-b.id}"

  security_groups = [
    "${aws_security_group.efs.id}",
  ]
}

resource "aws_efs_mount_target" "www-root-c" {
  file_system_id = "${aws_efs_file_system.www-root.id}"
  subnet_id      = "${aws_subnet.subnet-c.id}"

  security_groups = [
    "${aws_security_group.efs.id}",
  ]
}

# Allow both ingress and egress for port 2049 (NFS)
# such that our instances are able to get to the mount
# target in the AZ.
#
# Additionaly, we set the `cidr_blocks` that are allowed
# such that we restrict the traffic to machines that are
# within the VPC (and not outside).
resource "aws_security_group" "efs" {
  name        = "efs-mnt"
  description = "Allows NFS traffic from instances within the VPC."
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [
      "${var.vpc-cidr}",
    ]
  }

  egress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"

    cidr_blocks = [
      "${var.vpc-cidr}",
    ]
  }

  tags {
    Name = "allow_nfs-ec2"
  }
}
