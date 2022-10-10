#vpc.tf
# 1.VPC 생성
resource "aws_vpc" "baemin-vpc-10-0-0-0" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  # enable_dns_support 는 default 가 true

  tags = {
    Name = "baemin-vpc-10-0-0-0"
  }
}
# 2. Public subnet(1) 및 Private subnet(2) 생성
# 2-1) Public subnet CIDR : 10.0.1.0/24 일단 하나로 ..
resource "aws_subnet" "baemin-sub-pub1-10-0-1-0" { 
  vpc_id     = aws_vpc.baemin-vpc-10-0-0-0.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-2a" # 1. subnet 어느 가용 영역에 배치?
  map_public_ip_on_launch = true # 2.인스턴스 실행될 때 public ip 할당 받도록 하겠다.(option)

  tags = {
    Name = "baemin-sub-pub1-10-0-1-0"
  }
}
resource "aws_subnet" "baemin-sub-pub2-10-0-2-0" { 
  vpc_id     = aws_vpc.baemin-vpc-10-0-0-0.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-2c" # 1. subnet 어느 가용 영역에 배치?
  map_public_ip_on_launch = true # 2.인스턴스 실행될 때 public ip 할당 받도록 하겠다.(option)

  tags = {
    Name = "baemin-sub-pub2-10-0-2-0"
  }
}
#2-2) Private subnet CIDR : 10.0.3.0/24, 10.0.4.0/24
resource "aws_subnet" "baemin-sub-pri1-10-0-3-0" { 
  vpc_id     = aws_vpc.baemin-vpc-10-0-0-0.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-2a" 

  tags = {
    Name = "baemin-sub-pri1-10-0-3-0"
  }
}
resource "aws_subnet" "baemin-sub-pri2-10-0-4-0" { 
  vpc_id     = aws_vpc.baemin-vpc-10-0-0-0.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "baemin-sub-pri2-10-0-4-0"
  }
}

# 3. Internet gateway 생성
resource "aws_internet_gateway" "igw-baemin-vpc-10-0-0-0" { 
  vpc_id = aws_vpc.baemin-vpc-10-0-0-0.id

  tags = {
    Name = "igw-baemin-vpc-10-0-0-0"
  }
}

# 4. Route table 생성 및 associate
# 4-1) public 1개
resource "aws_route_table" "rt-pub-baemin-vpc-10-0-0-0" { # public 용 하나 생성, vpc 명시
  vpc_id = aws_vpc.baemin-vpc-10-0-0-0.id

  route {
    cidr_block = "0.0.0.0/0" # 모든 routing은 internet gateway 로 가라
    gateway_id = aws_internet_gateway.igw-baemin-vpc-10-0-0-0.id
  }

  tags = {
    Name = "rt-pub-baemin-vpc-10-0-0-0"
  }
}
#  rout table 잘 작동하는 지 확인하기 위해 associate
resource "aws_route_table_association" "rt-pub-as1-baemin-vpc-10-0-0-0" {
  subnet_id      = aws_subnet.baemin-sub-pub1-10-0-1-0.id
  route_table_id = aws_route_table.rt-pub-baemin-vpc-10-0-0-0.id
}
resource "aws_route_table_association" "rt-pub-as2-baemin-vpc-10-0-0-0" {
  subnet_id      = aws_subnet.baemin-sub-pub2-10-0-2-0.id
  route_table_id = aws_route_table.rt-pub-baemin-vpc-10-0-0-0.id # 퍼블릭용 라우팅 테이블 사용
}
# 4-2) private 1,2 2개
resource "aws_route_table" "rt-pri1-baemin-vpc-10-0-0-0" { 
  vpc_id = aws_vpc.baemin-vpc-10-0-0-0.id

  route {
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_nat_gateway.natgw-2a.id
  }
  tags = {
    Name = "rt-pri1-baemin-vpc-10-0-0-0"
  }
}
resource "aws_route_table" "rt-pri2-baemin-vpc-10-0-0-0" { 
  vpc_id = aws_vpc.baemin-vpc-10-0-0-0.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.natgw-2a.id
  }
  tags = {
    Name = "rt-pri2-baemin-vpc-10-0-0-0"
  }
}
resource "aws_route_table_association" "rt-pri1-as1-baemin-vpc-10-0-0-0" {
  subnet_id      = aws_subnet.baemin-sub-pri1-10-0-3-0.id
  route_table_id = aws_route_table.rt-pri1-baemin-vpc-10-0-0-0.id
}
resource "aws_route_table_association" "rt-pri2-as2-baemin-vpc-10-0-0-0" {
  subnet_id      = aws_subnet.baemin-sub-pri2-10-0-4-0.id
  route_table_id = aws_route_table.rt-pri2-baemin-vpc-10-0-0-0.id # 퍼블릭용 라우팅 테이블 사용
}
# 5. Elastic IP 및 NAT Gateway 생성
resource "aws_eip" "nat-2a" {
  vpc      = true
}
resource "aws_eip" "nat-2c" {
  vpc      = true
}
#  NAT Gateway
resource "aws_nat_gateway" "natgw-2a" {
  allocation_id = aws_eip.nat-2a.id
  subnet_id     = aws_subnet.baemin-sub-pub1-10-0-1-0.id

  tags = {
    Name = "gw NAT-2a"
  }
  
}
resource "aws_nat_gateway" "natgw-2c" {
  allocation_id = aws_eip.nat-2c.id
  subnet_id     = aws_subnet.baemin-sub-pub2-10-0-2-0.id

  tags = {
    Name = "gw NAT-2c"
  }
  
}