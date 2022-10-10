# security group
resource "aws_security_group" "baemin-sg" {
  name        = "baemin-sg"
  description = "Allow baemin inbound traffic"
  vpc_id      = aws_vpc.baemin-vpc-10-0-0-0.id # 생성한 vpc

  ingress {
    description      = "web from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1" 
    cidr_blocks      = ["0.0.0.0/0"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "baemin-sg"
  }
}
#auto scaling 위한 template
resource "aws_launch_configuration" "ec2-autoscaling" {
  name_prefix = "ec2-"

  image_id = "ami-01d87646ef267ccd7" # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"
  key_name = "terraform-baemin"

  security_groups = [ aws_security_group.baemin-sg.id]
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }
}
# auto scaling group 생성
resource "aws_autoscaling_group" "baemin-delivery" {
  name = "baemin-delivery"

  min_size             = 1
  desired_capacity     = 2
  max_size             = 4
  
  health_check_type    = "ELB"
  

  launch_configuration = aws_launch_configuration.ec2-autoscaling.name

  vpc_zone_identifier  = [
   aws_subnet.baemin-sub-pub1-10-0-1-0.id,aws_subnet.baemin-sub-pub2-10-0-2-0.id
  ]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "baemin-delivery"
    propagate_at_launch = true
  }
}
resource "aws_autoscaling_group" "baemin-order" {
  name = "baemin-order"

  min_size             = 1
  desired_capacity     = 2
  max_size             = 4
  
  health_check_type    = "ELB"
 
  launch_configuration = aws_launch_configuration.ec2-autoscaling.name

  vpc_zone_identifier  = [
   aws_subnet.baemin-sub-pub1-10-0-1-0.id,aws_subnet.baemin-sub-pub2-10-0-2-0.id
  ]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "baemin-order"
    propagate_at_launch = true
  }
}
resource "aws_autoscaling_group" "baemin-payment" {
  name = "baemin-payment"

  min_size             = 1
  desired_capacity     = 2
  max_size             = 4
  
  health_check_type    = "ELB"

  launch_configuration = aws_launch_configuration.ec2-autoscaling.name

  vpc_zone_identifier  = [
   aws_subnet.baemin-sub-pub1-10-0-1-0.id,aws_subnet.baemin-sub-pub2-10-0-2-0.id
  ]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "baemin-payment"
    propagate_at_launch = true
  }
}

# asg alb에 붙이기
resource "aws_autoscaling_attachment" "delivery_attach" {
  autoscaling_group_name = aws_autoscaling_group.baemin-delivery.id
  alb_target_group_arn   = aws_lb_target_group.alb-tg.arn
}
resource "aws_autoscaling_attachment" "order_attach" {
  autoscaling_group_name = aws_autoscaling_group.baemin-order.id
  alb_target_group_arn   = aws_lb_target_group.alb-tg.arn
}
resource "aws_autoscaling_attachment" "payment_attach" {
  autoscaling_group_name = aws_autoscaling_group.baemin-payment.id
  alb_target_group_arn   = aws_lb_target_group.alb-tg.arn
}