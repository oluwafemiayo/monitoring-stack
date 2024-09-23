terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "3.7.0"
    }
  }
}

provider "grafana" {
  url  = "http://localhost:3000"
  auth = var.auth
}
