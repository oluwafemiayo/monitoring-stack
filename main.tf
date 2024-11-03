# Prometheus Modules
module "prometheus" {
  source = "./module/prometheus-monitoring"
}

#Grafana Modules
module "grafana" {
  source                 = "./module/grafana-monitoring"
  grafana_admin_user     = var.grafana_admin_user
  grafana_admin_password = var.grafana_admin_password
}
