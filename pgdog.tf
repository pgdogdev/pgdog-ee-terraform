resource "helm_release" "pgdog" {
  name             = "pgdog"
  namespace        = var.pgdog_namespace
  create_namespace = true

  repository = "https://helm.pgdog.dev"
  chart      = "pgdog"

  values = [
    var.pgdog_values
  ]
}
