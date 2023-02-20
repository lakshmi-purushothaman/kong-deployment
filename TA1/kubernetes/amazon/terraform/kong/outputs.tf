output "cluster" {
  description = "EKS cluster"
  value       = data.aws_eks_cluster.cluster
}
