### MSK
resource "aws_msk_cluster" "example" {
  cluster_name = "my-msk-cluster"
  kafka_version = "2.8.0"
  number_of_broker_nodes = 3
}


### EKS

resource "aws_iam_policy" "msk_access_policy" {
  name = "MSKAccessPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "kafka:DescribeCluster",
          "kafka:GetBootstrapBrokers",
          "kafka:ListClusters"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "eks_msk_role" {
  name = "EksMskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "eks_msk_instance_profile" {
  name = "EksMskInstanceProfile"

  roles = [aws_iam_role.eks_msk_role.name]
}

# Attach the instance profile to your EKS worker nodes.
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  # Other EKS module configuration
  # ...
  
  instance_roles = [aws_iam_instance_profile.eks_msk_instance_profile.name]
}

