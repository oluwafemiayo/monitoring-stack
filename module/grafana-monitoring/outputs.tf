# Grafana URL
output "grafana_url" {
  value = "http://localhost:3000"
}

# Grafana dashboard URL
output "dashboard_url" {
  value = "http://localhost:3000/d/${data.grafana_dashboard.from_uid.uid}"
}
