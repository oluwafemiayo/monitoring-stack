## Monitoring Stack Deployment with Terraform
This project provides Terraform modules for deploying a Prometheus and Grafana monitoring stack on a Kind Kubernetes cluster.

### Overview
The repository includes two Terraform modules:

1: Prometheus Monitoring Module: Deploys Prometheus for Kubernetes monitoring.
2: Grafana Monitoring Module: Deploys Grafana for visualizing metrics collected by Prometheus.

### Tools Included:
Prometheus: Metrics collection and alerting.
Grafana: Data visualization and dashboarding.

### Prerequisites
To deploy this monitoring stack, ensure that the following prerequisites are met:

Kind Kubernetes Cluster is deployed. A simple configuration file is provided. 
Install Kind on your machine
```bash
cd kind-cluster
kind create cluster kind --config kind.yaml
```
Kubeconfig: Terraform requires access to the Kubernetes cluster. Ensure your kubeconfig is set up properly.
Helm: Prometheus and Grafana will be deployed using Helm charts.
Terraform: Ensure you have Terraform installed.

### Required Tools:
Terraform
Helm
kubectl
Terraform Providers:
Kubernetes Provider: Used to interact with your Kubernetes cluster.
Helm Provider: Used to deploy Helm charts.
Grafana Provider: Used to configure Grafana alerts and dashboards.

### Configuration

Before you deploy the stack, you will need to configure some parameters. These parameters can be passed to the modules via a terraform.tfvars file or directly in the configuration.

Example terraform.tfvars:
```hcl
grafana_admin_user     = "admin"
grafana_admin_password = "admin-password"
```
Input Variables:
grafana_admin_user: The username for the Grafana admin user.
grafana_admin_password: The password for the Grafana admin user.

### Usage

Follow these steps to deploy Prometheus and Grafana with Terraform.

1. Clone the Repository
```bash
git clone https://github.com/oluwafemiayo/monitoring-stack
cd monitoring-stack
```

2. Initialize Terraform
Initialize Terraform to download the necessary providers and modules:

```sh
terraform init
```
3. Review and Apply the Configuration
Once you’ve initialized Terraform, review your configuration to ensure it meets your needs.

To review the configuration:

```sh
terraform plan
```
If everything looks good, apply the configuration to deploy Prometheus and Grafana:

```bash
terraform apply
```

4. Accessing Grafana and Prometheus
Once the deployment completes, you can access Grafana and Prometheus from the output configuration

To get the pod IPs, use the following commands:

```bash
kubectl get svc -n prometheus
kubectl get svc -n grafana
```
To expose prometheus and grafana on ui using kind cluster

```bash
kubectl port-forward svc/grafana -n grafana 3000:80
kubectl port-forward svc/prometheus-server  9090:80 -n prometheus
```
Login to Grafana with the admin credentials provided in the terraform.tfvars file:

```bash
Username: grafana_admin_user
Password: grafana_admin_password
```

5. Configuring Dashboards
Grafana will be automatically configured with Prometheus as a data source. You can explore the pre-configured dashboards or import your own.

Outputs

After deployment, you can retrieve the following outputs:

Prometheus URL: The URL where Prometheus is accessible.
Grafana URL: The URL where Grafana is accessible.
Cleaning Up

To destroy the resources created by Terraform, use the following command:

```bash
terraform destroy
```


For Additional Configuration

Alerting: You can configure custom alerts in Grafana to trigger based on Prometheus metrics.
Dashboards: You can import community dashboards or build your own within Grafana.
