variable "grafana_admin_password" {}
variable "grafana_admin_user" {}
variable "grafana_version" {
  type = string
  default = "8.5.1"
  } 
variable "auth" {
  type = string
  default = "admin:admin"
}
