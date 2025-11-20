


# PUBLIC ROUTE TABLE and ASSOCIATION

resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.docker_vpc.id

  # Route all internet traffic (0.0.0.0/0) to the Internet Gateway

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.docker_igw.id
  }

  tags = {
    Name = "docker-public-rt"
  }
}

# Associate Public Route Table with Public Subnet (sn1)

resource "aws_route_table_association" "public_sn_association" {
  subnet_id      = aws_subnet.sn1.id
  route_table_id = aws_route_table.rt_public.id
}

# Associate Second Public Subnet (sn4) with Public Route Table

resource "aws_route_table_association" "public_sn_association_2" {
  subnet_id      = aws_subnet.sn4.id
  route_table_id = aws_route_table.rt_public.id
}

# PRIVATE ROUTE TABLE and ASSOCIATION

resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.docker_vpc.id

  # Route all internet traffic (0.0.0.0/0) to the NAT Gateway

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.docker_nat_gw.id
  }

  tags = {
    Name = "docker-private-rt"
  }
}

# Associate Private Route Table with Private Subnet (sn2)

resource "aws_route_table_association" "private_sn_association" {
  subnet_id      = aws_subnet.sn2.id
  route_table_id = aws_route_table.rt_private.id
}

# New Association for the second private subnet (sn3)

resource "aws_route_table_association" "private_sn_association_2" {
  subnet_id      = aws_subnet.sn3.id
  route_table_id = aws_route_table.rt_private.id
}