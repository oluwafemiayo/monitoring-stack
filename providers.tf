provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-kind"
}

# Helm provider
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}


