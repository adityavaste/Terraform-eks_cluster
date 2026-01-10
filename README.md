Provisioned a managed Kubernetes (EKS) cluster with managed node groups.

1.The VPC is divided into public and private subnets

2.Public subnet hosts internet-facing components

3.Private subnet hosts EKS worker nodes and application pods

4.Inbound traffic is handled securely via an ALB

5.Outbound internet access for private resources is enabled via a NAT Gateway

6.The EKS control plane is fully managed by AWS


**This whiteboard illustrates the exact architecture of the setup.**
(https://excalidraw.com/#json=m0T9tTtpGXsx3FVNeRlwu,cBnYGDdWLa2UTkVBHWL2-A)
for better view adjust zoom at 40%

=========================================================================================================


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

