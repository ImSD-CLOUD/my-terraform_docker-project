
locals {
  aws_region = "us-east-1"
  vpc_id     = aws_vpc.docker_vpc.id

  # REPLACE with existing PRIVATE SUBNET IDs
  private_subnet_ids = [aws_subnet.sn2.id, aws_subnet.sn3.id]

  # REPLACE with the Route Table IDs associated with your private subnets
  private_route_table_ids = [aws_route_table.rt_private.id]

  endpoint_sg_id = aws_security_group.endpoint_sg.id
}

# --- 1. S3 Gateway Endpoint (for ECR Image Layers) ---

resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = local.vpc_id
  service_name      = "com.amazonaws.${local.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  # Attach the endpoint to the private route tables
  route_table_ids = local.private_route_table_ids

  tags = {
    Name = "S3-Gateway-Endpoint-for-ECR"
  }
}

# --- 2. ECR API Interface Endpoint ---
# Handles image manifest requests and authentication (e.g., docker login)

resource "aws_vpc_endpoint" "ecr_api_interface" {
  vpc_id             = local.vpc_id
  service_name       = "com.amazonaws.${local.aws_region}.ecr.api"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = local.private_subnet_ids
  security_group_ids = [local.endpoint_sg_id]

  # This is crucial for using the ECR service names privately
  private_dns_enabled = true

  tags = {
    Name = "ECR-API-Interface-Endpoint"
  }
}

# --- 3. ECR DKR Interface Endpoint ---
# Handles the Docker Daemon requests for pulling the image

resource "aws_vpc_endpoint" "ecr_dkr_interface" {
  vpc_id              = local.vpc_id
  service_name        = "com.amazonaws.${local.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.private_subnet_ids
  security_group_ids  = [local.endpoint_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "ECR-DKR-Interface-Endpoint"
  }
}

#  CloudWatch Logs Interface Endpoint ---

resource "aws_vpc_endpoint" "cloudwatch_logs_interface" {
  vpc_id              = local.vpc_id
  service_name        = "com.amazonaws.${local.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.private_subnet_ids
  security_group_ids  = [local.endpoint_sg_id]
  private_dns_enabled = true

  tags = {
    Name = "CloudWatch-Logs-Interface-Endpoint"
  }
}