# Output the URLs
output "prometheus_url" {
  description = "Prometheus URL"
  value       = module.prometheus.prometheus_url
}

output "grafana_url" {
  description = "Grafana URL"
  value       = module.grafana.grafana_url
}
