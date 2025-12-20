# Data source for S3 Prefix List
data "aws_prefix_list" "s3" {
  name = "com.amazonaws.${var.region}.s3"
}

# Private Subnets for the Workspace Network Configuration
resource "aws_subnet" "private" {
  count = 3

  region = var.region

  availability_zone                              = length(regexall("^[a-z]{2}-", element(local.azs, count.index))) > 0 ? element(local.azs, count.index) : null
  availability_zone_id                           = length(regexall("^[a-z]{2}-", element(local.azs, count.index))) == 0 ? element(local.azs, count.index) : null
  cidr_block                                     = element(concat(var.private_subnets_cidr, [""]), count.index)
  vpc_id                                         = local.vpc_id

  tags = merge(
    {
      Name = format("${var.resource_prefix}-private-%s", element(local.azs, count.index))
    },
    var.tags
  )
}

resource "aws_route_table" "private" {
  region = var.region

  vpc_id = var.vpc_id

  tags = merge(
    {
      "Name" = "${var.resource_prefix}-private"
    },
    var.tags
  )
}

resource "aws_route_table_association" "private" {
  count = 3

  region = var.region

  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(
    aws_route_table.private[*].id,
    count.index,
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
