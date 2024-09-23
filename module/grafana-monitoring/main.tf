# Grafana namespace
resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "grafana"
  }
}

# Deploy Grafana using Helm
resource "helm_release" "grafana" {
  name       = "grafana"
  chart      = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  namespace  = kubernetes_namespace.grafana.metadata[0].name
  version    = var.grafana_version
  cleanup_on_fail  = true

  values = [
    <<EOF
adminUser: "${var.grafana_admin_user}"
adminPassword: "${var.grafana_admin_password}"
service:
  type: ClusterIP


datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://prometheus-server.prometheus.svc.cluster.local:80
        access: proxy
        isDefault: true

EOF
  ]

  wait = true
}
