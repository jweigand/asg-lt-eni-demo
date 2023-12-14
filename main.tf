data "aws_vpc" "this" {
  id = "vpc-075a0b17bfaf997c5"
}

variable "availability_zone" {
  default = "us-east-1a"
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
  filter {
    name   = "availability-zone"
    values = [var.availability_zone]
  }
}

resource "aws_network_interface" "this" {
  subnet_id = data.aws_subnets.this.ids[0]
}

resource "aws_launch_template" "this" {
  name = "asg_eni_demo"

  image_id      = "ami-0230bd60aa48260c6"
  instance_type = "t3.micro"

  network_interfaces {
    network_interface_id = aws_network_interface.this.id
    network_card_index   = 0
  }
}

resource "aws_autoscaling_group" "this" {
  name_prefix      = "asg_eni"
  desired_capacity = 1
  max_size         = 1
  min_size         = 1

  availability_zones = [var.availability_zone]

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
}
