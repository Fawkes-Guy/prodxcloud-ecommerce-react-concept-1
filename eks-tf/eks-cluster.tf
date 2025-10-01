# 1. IAM Role for the EKS Cluster Control Plane
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster-name}-role"

  # Trust policy that allows the EKS service to assume this role
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# 2. Attach the required AWS-managed policy to the role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# 3. Create the EKS Cluster itself
resource "aws_eks_cluster" "prodxcloud_cluster" {
  name     = var.cluster-name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.30" # Specifying a modern, supported version

  # Configure the cluster's networking to use our VPC and subnets
  vpc_config {
    # Note: These are the names of the resources from subnets.tf
    # They will be placed in us-east-2 as we configured there.
    subnet_ids = [
      aws_subnet.private-us-east-2a.id,
      aws_subnet.private-us-east-2b.id,
      aws_subnet.public-us-east-2a.id,
      aws_subnet.public-us-east-2b.id
    ]
  }

  # This ensures the IAM role and its policy are created before the cluster
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy_attachment
  ]
}