resource "random_bytes" "session_key" {
  length = 64
}

resource "random_uuid" "pgdog_blue_token" {}
resource "random_uuid" "pgdog_green_token" {}

locals {
  pgdog_control_version = coalesce(var.pgdog_control_version, var.pgdog_version)
  pgdog_blue_token      = coalesce(var.pgdog_blue_token, random_uuid.pgdog_blue_token.result)
  pgdog_green_token     = coalesce(var.pgdog_green_token, random_uuid.pgdog_green_token.result)

  database_url = var.create_rds ? (
    "postgres://${aws_db_instance.postgres[0].username}:${urlencode(coalesce(var.db_password, random_password.db_password[0].result))}@${aws_db_instance.postgres[0].endpoint}/${aws_db_instance.postgres[0].db_name}"
  ) : var.external_database_url
}

resource "helm_release" "pgdog_control" {
  name             = "pgdog-cloud"
  namespace        = var.pgdog_namespace
  create_namespace = true

  repository = "https://helm-ee.pgdog.dev"
  chart      = "pgdog-control"
  version    = var.pgdog_control_helm_chart_version

  values = [
    yamlencode({
      image = {
        tag = local.pgdog_control_version
      }
      ingress = {
        host = var.pgdog_ingress_host
        tls = {
          enabled = var.pgdog_ingress_tls_enabled
        }
        clusterIssuer = var.pgdog_ingress_cluster_issuer
        sslRedirect   = tostring(var.pgdog_ingress_ssl_redirect)
      }
      redis = {
        memory = var.pgdog_redis_memory
      }
      env = merge(
        {
          DATABASE_URL = local.database_url
          SESSION_KEY  = random_bytes.session_key.base64
        },
        var.pgdog_control_env
      )
    }),
    var.pgdog_control_values
  ]

  depends_on = [
    aws_db_instance.postgres,
    helm_release.ingress_nginx,
    helm_release.cert_manager,
    kubectl_manifest.letsencrypt_issuer
  ]
}

resource "null_resource" "pgdog_blue_token" {
  depends_on = [helm_release.pgdog_control]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl exec -n ${var.pgdog_namespace} deployment/pgdog-cloud-control -- control token --token ${local.pgdog_blue_token} --name Blue
    EOT
  }
}

resource "null_resource" "pgdog_green_token" {
  depends_on = [helm_release.pgdog_control]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl exec -n ${var.pgdog_namespace} deployment/pgdog-cloud-control -- control token --token ${local.pgdog_green_token} --name Green
    EOT
  }
}

resource "null_resource" "pgdog_blue_token_assignments" {
  for_each   = toset(var.pgdog_token_emails)
  depends_on = [null_resource.pgdog_blue_token]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl exec -n ${var.pgdog_namespace} deployment/pgdog-cloud-control -- control assign-token --email ${each.key} --token ${local.pgdog_blue_token}
    EOT
  }
}

resource "null_resource" "pgdog_green_token_assignments" {
  for_each   = toset(var.pgdog_token_emails)
  depends_on = [null_resource.pgdog_green_token]

  provisioner "local-exec" {
    command = <<-EOT
      kubectl exec -n ${var.pgdog_namespace} deployment/pgdog-cloud-control -- control assign-token --email ${each.key} --token ${local.pgdog_green_token}
    EOT
  }
}
