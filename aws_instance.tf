data "aws_ami" "ubuntuBionic" {
  owners           = ["099720109477"]
  most_recent      = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200408"]
  }

}

resource "aws_launch_template" "templateBackend" {
  name_prefix   = "templateBackend"
  image_id      = data.aws_ami.ubuntuBionic.id
  instance_type = var.autoScalingGroup["type"]
  user_data = filebase64(var.autoScalingGroup["userdata"])
  vpc_security_group_ids = [aws_security_group.sgBackend.id]
}

resource "aws_autoscaling_group" "autoScalingGroup" {
  vpc_zone_identifier = ["${aws_subnet.subnetBackend[0].id}", "${aws_subnet.subnetBackend[1].id}"]
  desired_capacity   = 0
  max_size           = 3
  min_size           = 0

  launch_template {
    id      = aws_launch_template.templateBackend.id
    version = "$Latest"
  }

}
