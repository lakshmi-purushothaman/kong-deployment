resource "kubernetes_namespace" "kong" {
  metadata {
    name = var.kong_cp_namespace
  }
}

resource "kubernetes_secret" "kong-cluster-cert" {
  metadata {
    name = "kong-cluster-cert"
    namespace = var.kong_cp_namespace

  }
  # data = {
  #  "tls.crt" = "${file("${path.module}/${var.kong_rt_file_path}/certs/cluster.crt")}"
  #   "tls.key" = "${file("${path.module}/${var.kong_rt_file_path}/certs/cluster.key")}"
  # }

  data = {
   "tls.crt" = "${file("${path.cwd}/kong/certs/cluster.crt")}"
   "tls.key" = "${file("${path.cwd}/kong/certs/cluster.key")}"
  }
 
  type = "kubernetes.io/tls"
}

resource "helm_release" "kong" {
  name       = "kong"
  atomic     = false
  skip_crds  = true
  timeout    = 1000
  repository = var.chart_repository
  chart      = var.chart_name
  version    = var.chart_version
  namespace  = var.kong_cp_namespace

  values = [
    "${file("${path.cwd}/kong/kong-hybrid-cp-values.yaml")}"
  ]
}