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

  tags = merge(local.common_tags, {
    Name = "${var.resource_prefix}-private-compute-${each.key}"
  })
}

resource "aws_route_table_association" "private_compute" {
  for_each = aws_subnet.private_compute

  subnet_id      = each.value.id
  route_table_id = var.private_route_table_id
}

# NACL for Databricks private compute subnets
resource "aws_network_acl" "private_compute" {
  vpc_id    = var.vpc_id
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

# Security group for Compute Clusters
resource "aws_security_group" "sg" {
  name   = "${var.resource_prefix}-workspace-sg"
  vpc_id = var.vpc_id


  dynamic "ingress" {
    for_each = ["tcp", "udp"]
    content {
      description = "Databricks - Workspace SG - Internode Communication"
      from_port   = 0
      to_port     = 65535
      protocol    = ingress.value
      self        = true
    }
  }

  dynamic "egress" {
    for_each = ["tcp", "udp"]
    content {
      description = "Databricks - Workspace SG - Internode Communication"
      from_port   = 0
      to_port     = 65535
      protocol    = egress.value
      self        = true
    }
  }

  dynamic "egress" {
    for_each = var.sg_egress_ports
    content {
      description = "Databricks - Workspace SG - REST (443), Secure Cluster Connectivity (2443/6666), Lakebase PostgreSQL (5432), Compute Plane to Control Plane Internal Calls (8443), Unity Catalog Logging and Lineage Data Streaming (8444), Future Extendability (8445-8451)"
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr_range]
    }
  }

  dynamic "egress" {
    content {
      description     = "S3 Gateway Endpoint - SG"
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      prefix_list_ids = [data.aws_prefix_list.s3.id]
    }
  }

  tags = var.tags
}
