# db를 위한 subnet group 생성
resource "aws_db_subnet_group" "rds" {
  name        = "dbsubnets-baemin-vpc-10-0-0-0"
  description = "The subnets used for dayone RDS deployments"
  subnet_ids  = [aws_subnet.baemin-sub-pri1-10-0-3-0.id,aws_subnet.baemin-sub-pri2-10-0-4-0.id]
  tags = {
    Name = "dbsubnets-baemin-vpc-10-0-0-0"
  }
}
# RDS는 private subne에 위치, 인터넷 통해 접근 불가
# EC2만 RDS에 접근 가능
resource "aws_security_group" "baemin-rds-sg" {
  name        = "baemin-rds-sg"
  description = "Allow baemin inbound traffic"
  vpc_id      = aws_vpc.baemin-vpc-10-0-0-0.id # 생성한 vpc

  ingress {
    description      = "Allow rds traffic from only ec2 sg"
    from_port        =  "3306"
    to_port          =  "3306"
    protocol         =  "tcp" 
    security_groups = [aws_security_group.baemin-sg.id]

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
  db_name = "baemin-rds"
  username = "ju"
  password = "baeminRDS"
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  skip_final_snapshot = true # 삭제되기전 snapshot 생성되지 않도록
  vpc_security_group_ids = [ 
    aws_security_group.baemin-sg.id,
   ]
  tags = {
      Name = "baemin-rds"
  }
}
