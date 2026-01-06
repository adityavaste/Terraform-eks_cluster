Provisioned a managed Kubernetes (EKS) cluster with managed node groups.


**Thats how i use this module in my project**

module "eks-cluster" {
  source  = "git::https://github.com/adityavaste/eks_module.git?ref=dev"
  deployHub_vpc_cidr_block         = "10.0.0.0/16"
  public_subnet_cidr_block         = "10.0.1.0/24"
  public_subnet_availability_zone  = "ap-south-1a"
  private_subnet_cidr_block        = "10.0.2.0/24"
  private_subnet_availability_zone = "ap-south-1b"
  aws_instance_ami                 = "ami-00ca570c1b6d79f36"
  aws_instance_type                = "t2.micro"
  aws_instance_key_pair            = "12-dec"
  ami_type                         = "AL2_x86_64"
}
