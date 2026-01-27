resource "random_bytes" "session_key" {
  length = 64
}

resource "helm_release" "pgdog_control" {
  name             = "pgdog-cloud"
  namespace        = var.pgdog_namespace
  create_namespace = true

  repository = "https://helm-ee.pgdog.dev"
  chart      = "pgdog-control"

  values = [
    yamlencode({
      image = {
        tag = var.pgdog_version
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
          DATABASE_URL = "postgres://${aws_db_instance.postgres.username}:${urlencode(coalesce(var.db_password, random_password.db_password.result))}@${aws_db_instance.postgres.endpoint}/${aws_db_instance.postgres.db_name}"
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
