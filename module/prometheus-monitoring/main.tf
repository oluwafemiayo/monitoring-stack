# Prometheus namespace
resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
  }
}

# Deploy Prometheus using Helm
resource "helm_release" "prometheus" {
  name       = "prometheus"
  chart      = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  namespace  = kubernetes_namespace.prometheus.metadata[0].name
  cleanup_on_fail  = true
  version    =  var.prometheus_version

  values = [
    <<EOF
alertmanager:
  enabled: true
server:
  enabled: true


EOF
  ]
}
