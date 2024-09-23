# Include Prometheus and Grafana modules
module "prometheus" {
  source = "./module/prometheus-monitoring"
}

module "grafana" {
  source                 = "./module/grafana-monitoring"
  grafana_admin_user     = var.grafana_admin_user
  grafana_admin_password = var.grafana_admin_password
}
