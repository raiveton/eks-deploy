resource "aws_eks_cluster" "cloudquicklabs" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cloudquicklabs.arn

  vpc_config {
    subnet_ids              = var.aws_public_subnet
    endpoint_public_access  = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = [aws_security_group.node_group_one.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cloudquicklabs-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cloudquicklabs-AmazonEKSVPCResourceController,
  ]
}

resource "aws_key_pair" "my_key_pair" {
  key_name   = "TestKeyPair"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDU6T+CSybncTlv6jZOQ/ji29CI8U3SxarZnBVd6/JcGLd3etgbLN1ANX7HZCywQgLO6t4HUjrITtskb4x9ANMIpZyMXQzJmF9HD0EfuXkKuf9jol+ZbtVfR2wT+j87eo6ZjLIMdYJGceq3CGGRRUk2NcZakl0GHLZ8zM1M/PZGU7ARf43YgFK9C814jwnvR2HaMWRp6CnEx6PXCd0srYJyIknhe4mZDv6wHjKN86uywOTtppzfUQZ4I+q0fvzql89J5Dqo3V7nF2mqYHeijpz54XpCX9m+AgVDpKq7JWghRTn5Znd2hThbF7YuA5snl9BPRx6xfWyYJjok0q8BZCodxYzkjHsGbMuezVQWo9SJRxmUq6CjaLzjR9hB8Ox1pbTVi6yUkddtcSRQm74r1EEn4bLBPR6FidKTA4Pwc8GvxMwOm7RvnjzEOr6KSOFO935xRNkMdp8zbx+jOACLTvr9NiTo55RAd3avip2DY1BqFQTmLy92JV4dkX8pO87fX6k= raiveton@Vladimirs-MacBook-Pro.local" 
}

resource "aws_eks_node_group" "cloudquicklabs" {
  cluster_name    = aws_eks_cluster.cloudquicklabs.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.cloudquicklabs2.arn
  subnet_ids      = var.aws_public_subnet
  instance_types  = var.instance_types

  remote_access {
    source_security_group_ids = [aws_security_group.node_group_one.id]
    ec2_ssh_key               = aws_key_pair.my_key_pair.key_name 
  }

  scaling_config {
    desired_size = var.scaling_desired_size
    max_size     = var.scaling_max_size
    min_size     = var.scaling_min_size
  }

  depends_on = [
    aws_iam_role_policy_attachment.cloudquicklabs-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.cloudquicklabs-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.cloudquicklabs-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_security_group" "node_group_one" {
  name_prefix = "node_group_one"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "cloudquicklabs" {
  name = "eks-cluster-cloudquicklabs"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cloudquicklabs-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cloudquicklabs.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "cloudquicklabs-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cloudquicklabs.name
}

resource "aws_iam_role" "cloudquicklabs2" {
  name = "eks-node-group-cloudquicklabs"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "cloudquicklabs-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.cloudquicklabs2.name
}

resource "aws_iam_role_policy_attachment" "cloudquicklabs-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.cloudquicklabs2.name
}

resource "aws_iam_role_policy_attachment" "cloudquicklabs-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.cloudquicklabs2.name
}
