# db를 위한 subnet group 생성
resource "aws_db_subnet_group" "rds" {
  name        = "dbsubnets-baemin-vpc-10-0-0-0"
  description = "The subnets used for dayone RDS deployments"
  subnet_ids  = [aws_subnet.baemin-sub-pri1-10-0-3-0.id,aws_subnet.baemin-sub-pri2-10-0-4-0.id]
  tags = {
    Name = "dbsubnets-baemin-vpc-10-0-0-0"
  }
}
resource "aws_security_group" "baemin-rds-sg" {
  name        = "baemin-rds-sg"
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
    Name = "baemin-rds-sg"
  }
}
# userinfo 용 rds 생성
resource "aws_db_instance" "baemin-rds" {
  allocated_storage = 50
  max_allocated_storage = 80
  engine = "postgres"
  engine_version = "12"
  instance_class = "db.t2.micro"
  name = "baemin_rds"
  username = "ju"
  password = "baeminRDS"
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [ 
    aws_security_group.baemin-sg.id,
   ]
  tags = {
      "name" = "baemin-rds"
    }
}
