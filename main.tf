# --------------------
# VPC
# --------------------
resource "aws_vpc" "deployHub_vpc" {
  cidr_block           = var.deployHub_vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "deployHub-vpc"
  }
}

# --------------------
# Public Subnet
# --------------------
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.deployHub_vpc.id
  cidr_block              = var.public_subnet_cidr_block
  availability_zone       = var.public_subnet_availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# --------------------
# Internet Gateway
# --------------------
resource "aws_internet_gateway" "igw_deployhHub" {
  vpc_id = aws_vpc.deployHub_vpc.id

  tags = {
    Name = "deployHub-IGW"
  }
}

# --------------------
# Public Route Table
# --------------------
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.deployHub_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_deployhHub.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet.id
}

# --------------------
# Private Subnet
# --------------------
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.deployHub_vpc.id
  cidr_block              = var.private_subnet_cidr_block
  availability_zone       = var.private_subnet_availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet"
  }
}

# --------------------
# NAT Gateway Requirements (Elastic IP)
# --------------------
resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id

  depends_on = [aws_internet_gateway.igw_deployhHub]

  tags = {
    Name = "deployHub-nat-gateway"
  }
}

# --------------------
# Private Route Table → Internet via NAT
# --------------------
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.deployHub_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_association" {
  route_table_id = aws_route_table.private_route.id
  subnet_id      = aws_subnet.private_subnet.id
}

# --------------------
# EC2 (in Public Subnet)
# --------------------
resource "aws_instance" "xyz" {
  ami           = var.aws_instance_ami
  instance_type = var.aws_instance_type
  key_name      = var.aws_instance_key_pair

  subnet_id = aws_subnet.public_subnet.id # ⬅ FIXED

  tags = {
    Name = "deployHub-instance"
  }
}

# --------------------
# Iam role 
# --------------------
resource "aws_iam_role" "eks_role" {
  name = "deployhub-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_controller" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}


# --------------------
# eks cluster
# --------------------

resource "aws_eks_cluster" "deployHub_cluster" {
  name     = "eks-cluster"
  version  = "1.29"
  role_arn = aws_iam_role.eks_role.arn
  vpc_config {
    subnet_ids = [
      aws_subnet.private_subnet.id,
      aws_subnet.public_subnet.id
    ]
  }
}

