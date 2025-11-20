

# ELASTIC IP (EIP) and NAT GATEWAY

resource "aws_eip" "nat_gw_eip" {
  domain = "vpc"

  tags = {
    Name = "docker-nat-gw-eip"
  }
}

# The NAT Gateway is placed in the Public Subnet (sn1)

resource "aws_nat_gateway" "docker_nat_gw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.sn1.id

  tags = {
    Name = "docker-nat-gw"
  }
}