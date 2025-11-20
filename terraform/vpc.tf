resource "aws_vpc" "docker_vpc" {

  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    name = "docker_vpc"
  }

}

