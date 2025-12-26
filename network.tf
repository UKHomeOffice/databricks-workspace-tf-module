# Data source for S3 Prefix List
data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${var.region}.s3"
}

# Private Subnets for the Workspace Network Configuration
resource "aws_subnet" "private_compute" {
  for_each = var.private_compute_subnet_config

  vpc_id            = var.vpc_id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = merge(
    var.tags, {
      Name = "${var.resource_prefix}-private-compute-${each.key}"
    }
  )
}

resource "aws_route_table_association" "private_compute" {
  for_each = aws_subnet.private_compute

  subnet_id      = each.value.id
  route_table_id = var.private_route_table_id
}

# NACL for Databricks private compute subnets
resource "aws_network_acl" "private_compute" {
  vpc_id     = var.vpc_id
  subnet_ids = [for s in aws_subnet.private_compute : s.id]

  ingress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    protocol   = "-1"
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.resource_prefix}-nacl-private-compute"
    }
  )
}
