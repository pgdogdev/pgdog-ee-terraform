resource "helm_release" "pgdog_blue" {
  name             = "pgdog-blue"
  namespace        = var.pgdog_namespace
  create_namespace = true

  repository = "https://helm.pgdog.dev"
  chart      = "pgdog"

  values = [
    yamlencode({
      image = {
        repository = "ghcr.io/pgdogdev/pgdog-enterprise"
        tag        = local.pgdog_blue_version
      }
      control = {
        enabled  = true
        token    = local.pgdog_blue_token
        endpoint = "http://pgdog-cloud-control.${var.pgdog_namespace}.svc.cluster.local"
      }
      service = {
        aws = {
          enabled = true
        }
      }
    }),
    var.pgdog_blue_values
  ]
}

resource "helm_release" "pgdog_green" {
  name             = "pgdog-green"
  namespace        = var.pgdog_namespace
  create_namespace = true

  repository = "https://helm.pgdog.dev"
  chart      = "pgdog"

  values = [
    yamlencode({
      image = {
        repository = "ghcr.io/pgdogdev/pgdog-enterprise"
        tag        = local.pgdog_green_version
      }
      control = {
        enabled  = true
        token    = local.pgdog_green_token
        endpoint = "http://pgdog-cloud-control.${var.pgdog_namespace}.svc.cluster.local"
      }
      service = {
        aws = {
          enabled = true
        }
      }
    }),
    var.pgdog_green_values
  ]
}

data "kubernetes_service_v1" "pgdog_blue" {
  count = var.pgdog_create_dns_record ? 1 : 0

  metadata {
    name      = "pgdog-blue"
    namespace = var.pgdog_namespace
  }

  depends_on = [helm_release.pgdog_blue]
}

data "kubernetes_service_v1" "pgdog_green" {
  count = var.pgdog_create_dns_record ? 1 : 0

  metadata {
    name      = "pgdog-green"
    namespace = var.pgdog_namespace
  }

  depends_on = [helm_release.pgdog_green]
}

locals {
  pgdog_blue_version   = coalesce(var.pgdog_blue_version, var.pgdog_version)
  pgdog_green_version  = coalesce(var.pgdog_green_version, var.pgdog_version)
  pgdog_blue_endpoint = coalesce(
    var.pgdog_blue_endpoint != "" ? var.pgdog_blue_endpoint : null,
    try(data.kubernetes_service_v1.pgdog_blue[0].status[0].load_balancer[0].ingress[0].hostname, null),
    "pgdog-blue.${var.pgdog_namespace}.svc.cluster.local"
  )
  pgdog_green_endpoint = coalesce(
    var.pgdog_green_endpoint != "" ? var.pgdog_green_endpoint : null,
    try(data.kubernetes_service_v1.pgdog_green[0].status[0].load_balancer[0].ingress[0].hostname, null),
    "pgdog-green.${var.pgdog_namespace}.svc.cluster.local"
  )
}

resource "aws_route53_record" "pgdog" {
  count = var.pgdog_create_dns_record ? 1 : 0

  zone_id = var.pgdog_route53_zone_id
  name    = var.pgdog_route53_record_name
  type    = "CNAME"
  ttl     = 60

  records = [
    var.pgdog_active_deployment == "blue" ? local.pgdog_blue_endpoint : local.pgdog_green_endpoint
  ]
}
