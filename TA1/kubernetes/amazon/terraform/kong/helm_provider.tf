provider "kubernetes" {
  host                   = data.terraform_remote_state.global_networking.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.global_networking.outputs.cluster.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.global_networking.outputs.cluster_id]
    command     = "aws"
  }
}
provider "helm" {
    kubernetes {
      host                   = data.terraform_remote_state.global_networking.outputs.cluster_endpoint
      cluster_ca_certificate = base64decode(data.terraform_remote_state.global_networking.outputs.cluster.cluster_certificate_authority_data)
      # cluster_ca_certificate = base64decode(data.aws_eks_cluster.default.certificate_authority[0].data)
      #token                  = data.aws_eks_cluster_auth.cluster.token
      exec {
        api_version = "client.authentication.k8s.io/v1beta1"
        args        = ["eks", "get-token", "--cluster-name", data.terraform_remote_state.global_networking.outputs.cluster_id]
        command     = "aws"
      }
  }
}