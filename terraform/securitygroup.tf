
# Security Group for the Application Load Balancer (ALB)

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allows HTTP/HTTPS access from the internet to the ALB"
  vpc_id      = aws_vpc.docker_vpc.id

  tags = {
    Name = "alb-security-group"
  }
}

# ALB Ingress Rule: Allow traffic from the internet on 80 and 443

resource "aws_vpc_security_group_ingress_rule" "alb_ingress" {
  for_each = {
    http  = 80
    https = 443
  }

  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow ${each.key} from the Internet"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = each.value
  to_port           = each.value
  ip_protocol       = "tcp"
}

# ALB Egress Rule: Allow all outbound traffic (to talk to the app and the internet)

resource "aws_vpc_security_group_egress_rule" "alb_egress_all" {
  security_group_id = aws_security_group.alb_sg.id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}




# Security Group for the ECS Application Tasks 

resource "aws_security_group" "app_sg" {
  name        = "app_sg"
  description = "Security group for ECS Tasks (application containers)"
  vpc_id      = aws_vpc.docker_vpc.id

  tags = {
    Name = "application-security-group"
  }
}

# Application Ingress Rule: ONLY allow traffic from the ALB

resource "aws_vpc_security_group_ingress_rule" "app_ingress_from_alb" {
  security_group_id = aws_security_group.app_sg.id
  description       = "Allow traffic from ALB on app port (e.g., 80)"


  referenced_security_group_id = aws_security_group.alb_sg.id
  from_port                    = 80 # *CHANGE THIS PORT to  application's exposed port*
  to_port                      = 80 # *CHANGE THIS PORT to  application's exposed port*
  ip_protocol                  = "tcp"
}

# Application Egress Rule: Allow all outbound traffic

resource "aws_vpc_security_group_egress_rule" "app_egress_all" {
  security_group_id = aws_security_group.app_sg.id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Name = "allow-all-outbound"
  }
}

# SECURITY GROUP FOR ENDPOINTS

resource "aws_security_group" "endpoint_sg" {
  name        = "endpoint_sg"
  description = "Allows inbound traffic to VPC Endpoints (ECR/CloudWatch) from App Tasks"
  vpc_id      = aws_vpc.docker_vpc.id

  tags = {
    Name = "endpoint-security-group"
  }
}

# Ingress Rule for Endpoints: Allow 443 (HTTPS) from the ECS Application Security Group

resource "aws_vpc_security_group_ingress_rule" "endpoint_sg_ingress" {
  security_group_id = aws_security_group.endpoint_sg.id
  description       = "Allow HTTPS from App SG"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  # References the application security group to restrict access
  referenced_security_group_id = aws_security_group.app_sg.id
}


