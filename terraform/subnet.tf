# Public Subnet (sn1)
resource "aws_subnet" "sn1" {
  vpc_id                  = aws_vpc.docker_vpc.id
  cidr_block              = "10.0.1.0/24"
  # FIX: Change to match sn2's AZ
  availability_zone       = "us-east-1b" 
  map_public_ip_on_launch = true

  tags = {
    Name = "docker-public-sn1"
    Tier = "Public"
  }
}

# Second Public Subnet (sn4 Required for ALB High Availability)
resource "aws_subnet" "sn4" {
  vpc_id                  = aws_vpc.docker_vpc.id
  cidr_block              = "10.0.4.0/24"
  # FIX: Change to match sn3's AZ
  availability_zone       = "us-east-1c" 
  map_public_ip_on_launch = true

  tags = {
    Name = "docker-public-sn4"
    Tier = "Public"
  }
}

# Private Subnet (sn2) - Keep as us-east-1b
resource "aws_subnet" "sn2" {
  vpc_id                  = aws_vpc.docker_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "docker-private-sn2"
    Tier = "Private"
  }
}

# Private Subnet (sn3) - Keep as us-east-1c
resource "aws_subnet" "sn3" {
  vpc_id                  = aws_vpc.docker_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = false

  tags = {
    Name = "docker-private-sn3"
    Tier = "Private"
  }
}