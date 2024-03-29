variable "region" {
  default     = "eu-west-2"
  description = "AWS region"
}

variable "cluster_name" {
  default = "kong-ta2-eks"
}

variable "vpc_name" {
  default = "kong-ta2"
}

variable "kong_tf_state_bucket" {
  default = "tf-hybrid-kong-bucket"
}

variable "kong_tf_state_lock" {
  default = "hybrid-kong-terraform-state-locking"
}

variable "kong_tf_state_key" {
  default = "kong-ta2/terraform.tfstate"
}

variable "chart_repository" {
  default = "https://charts.konghq.com"
}

variable "chart_name" {
  default = "kong"
}

variable "chart_version" {
  default = "1.15.0"
}

variable "kong_cp_namespace" {
  default = "kong"
}

variable "kong_dp_namespace" {
  default = "kong-dp"
}

variable "kong_rt_file_path" {
  default = "TA1/kubernetes/amazon/terraform/kong"
}

