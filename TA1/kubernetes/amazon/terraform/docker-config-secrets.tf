resource "kubernetes_namespace" "python-web-app" {
  metadata {
    name = var.python_web_app_namespace
  }
}

data "aws_secretsmanager_secret_version" "docker_creds" {
  # Fill in the name you gave to your secret
  secret_id = "docker_config_secret"
}

locals {
  docker_creds = jsondecode(
    data.aws_secretsmanager_secret_version.docker_creds.secret_string
  )
}

resource "kubernetes_secret" "docker-hub-reg" {
  metadata {
    name      = "docker-hub-secret"
    namespace = var.python_web_app_namespace

  }
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          "username" = local.docker_creds.docker_registry_username
          "password" = local.docker_creds.docker_registry_password
          "email"    = local.docker_creds.docker_registry_email
          "auth"     = base64encode("${local.docker_creds.docker_registry_username}:${local.docker_creds.docker_registry_password}")
        }
      }
    })
  }
  type = "kubernetes.io/dockerconfigjson"
}
