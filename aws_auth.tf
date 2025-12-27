#####################################
# Kubernetes Provider (for EKS)
#####################################
provider "kubernetes" {
  host                   = aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(
    aws_eks_cluster.eks.certificate_authority[0].data
  )

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      aws_eks_cluster.eks.name
    ]
  }
}

#####################################
# aws-auth ConfigMap
#####################################
resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapUsers = <<EOF
- userarn: arn:aws:iam::448049834082:user/aditya
  username: aditya
  groups:
    - system:masters
EOF

    mapRoles = <<EOF
- rolearn: ${aws_iam_role.eks_node_role.arn}
  username: system:node:{{EC2PrivateDNSName}}
  groups:
    - system:bootstrappers
    - system:nodes
EOF
  }

  depends_on = [
    aws_eks_cluster.eks,
    aws_eks_node_group.nodes
  ]
}
