resource "kubernetes_namespace" "kong-dp" {
  metadata {
    name = var.kong_dp_namespace
  }
}

resource "kubernetes_secret" "kong-cluster-cert-dp" {
  metadata {
    name = "kong-cluster-cert"
    namespace = var.kong_dp_namespace

  }
  data = {
   "tls.crt" = "${file("${path.cwd}/kong/certs/cluster.crt")}"
   "tls.key" = "${file("${path.cwd}/kong/certs/cluster.key")}"
  }
 
  type = "kubernetes.io/tls"
}

resource "helm_release" "kong-dp" {
  name       = "kong-dp"
  atomic     = false
  skip_crds  = true
  repository = var.chart_repository
  chart      = var.chart_name
  version    = var.chart_version
  namespace  = var.kong_dp_namespace

  values = [
    
    "${file("${path.cwd}/kong/kong-hybrid-dp-values.yaml")}"
  ]
}