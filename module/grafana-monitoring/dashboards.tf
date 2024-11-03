resource "grafana_dashboard" "kubernetes_dashboard" {
  config_json = jsonencode({
    id            = null,  #auto-generate ID
    uid           = "cluster-metrics",
    title         = "kubernetes Cluster Metrics",
    tags          = ["kubernetes", "pods", "nodes"],
    timezone      = "browser",
    schemaVersion = 16,
    version       = 1,
    refresh       = "5s",  

    templating = {
      list = [
        # Node Variable
        {
          type    = "query",
          name    = "node",
          label   = "Node",
          datasource = "Prometheus",
          query   = "label_values(node_cpu_seconds_total, instance)",
          refresh = 1,
          includeAll = true,
        },
        # Pod Variable
        {
          type    = "query",
          name    = "pod",
          label   = "Pod",
          datasource = "Prometheus",
          query   = "label_values(container_cpu_usage_seconds_total, pod)",
          refresh = 1,
          includeAll = true,
        }
      ]
    },

    panels = [
      # Node CPU Usage - time Series (with templating)
      {
        title      = "Node CPU Usage",
        type       = "timeseries",
        datasource = "Prometheus",
        gridPos    = { h = 9, w = 12, x = 0, y = 0 },
        fieldConfig = {
          defaults = {
            unit = "percent",
          }
        },
        repeat = "node",  # Repeat for each selected node
        targets = [
          {
            expr         = "sum(rate(node_cpu_seconds_total{mode!='idle', instance=~'$node'}[5m])) by (instance)",
            legendFormat = "{{instance}}",
            refId        = "A"
          }
        ]
      },

      # Node Memory Usage - Gauge
      {
        title      = "Node Memory Usage",
        type       = "gauge",
        datasource = "Prometheus",
        gridPos    = { h = 9, w = 12, x = 12, y = 0 },
        repeat = "node",
        fieldConfig = {
          defaults = {
            unit   = "percent",
            min    = 0,
            max    = 100,
            color  = {
              mode = "thresholds"
            },
            thresholds = {
              mode = "absolute",
              steps = [
                { color = "green", value = 0 },
                { color = "orange", value = 75 },
                { color = "red", value = 90 }
              ]
            }
          }
        },
        targets = [
          {
            expr         = "sum(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes{instance=~'$node'}) / sum(node_memory_MemTotal_bytes{instance=~'$node'}) * 100",
            legendFormat = "{{instance}}",
            refId        = "B"
          }
        ]
      },

      # Pod CPU Usage - Stat (with templating)
      {
        title      = "Pod CPU Usage",
        type       = "stat",
        datasource = "Prometheus",
        gridPos    = { h = 9, w = 12, x = 0, y = 9 },
        repeat = "pod",  
        fieldConfig = {
          defaults = {
            unit     = "percent",
            color    = {
              mode = "thresholds"
            },
            thresholds = {
              mode = "absolute",
              steps = [
                { color = "green", value = 0 },
                { color = "orange", value = 75 },
                { color = "red", value = 90 }
              ]
            }
          }
        },
        targets = [
          {
            expr         = "sum(rate(container_cpu_usage_seconds_total{image!=\"\", pod=~'$pod'}[5m])) by (pod, namespace)",
            legendFormat = "{{pod}}",
            refId        = "C"
          }
        ]
      },

      # Pod Memory Usage - Time Series (with templating)
      {
        title      = "Pod Memory Usage",
        type       = "timeseries",
        datasource = "Prometheus",
        gridPos    = { h = 9, w = 12, x = 12, y = 9 },
        repeat = "pod",  # Repeat for each selected pod
        fieldConfig = {
          defaults = {
            unit = "bytes",
          }
        },
        targets = [
          {
            expr         = "sum(container_memory_working_set_bytes{image!=\"\", pod=~'$pod'}) by (pod, namespace)",
            legendFormat = "{{pod}}",
            refId        = "D"
          }
        ]
      }
    ]
  })
}

data "grafana_dashboard" "from_uid" {
  depends_on = [
    grafana_dashboard.kubernetes_dashboard
  ]
  uid = "cluster-metrics"
}



resource "grafana_dashboard" "kubernetes_alerts_dashboard" {
  config_json = jsonencode({
    id            = null,  
    uid           = "kubernetes-alerts",
    title         = "Kubernetes Alerts Overview",
    schemaVersion = 16,
    version       = 1,
    refresh       = "10s",

    panels = [
      # Pod Memory Usage 
      {
        title      = "Pod Memory Usage with Alert",
        type       = "timeseries",  
        gridPos    = { h = 9, w = 12, x = 0, y = 0 },
        targets = [
          {
            expr         = "sum(container_memory_working_set_bytes{pod=~'.+'}) by (pod, namespace)",
            legendFormat = "{{pod}}",
            refId        = "A"
          }
        ],
        options = {
          tooltip = {
            mode = "single"
          },
          legend = {
            displayMode = "list",
            placement   = "bottom"
          },
        },
        fieldConfig = {
          defaults = {
            unit    = "bytes",
            decimals = 2,
            thresholds = {
              mode = "absolute",
              steps = [
                { color = "green", value = null },
                { color = "yellow", value = 50 },
                { color = "red", value = 75 }
              ]
            },
          },
          overrides = []
        },
        alert = {
          name   = "High Pod Memory Usage Alert",
          message = "Pod memory usage is high for more than 2 minutes.",
          conditions = [
            {
              evaluator = {
                type  = "gt",
                params = [75]  # Alert when memory usage exceeds 75% of the limit
              },
              operator = {
                type = "and"
              },
              reducer = {
                type = "avg"
              },
              type = "query",
              query = {
                refId = "A",
                params = ["5m", "now"]
              }
            }
          ],
          frequency = "1m",
          handler = 1,
          no_data_state = "no_data",
          execution_error_state = "alerting",
          notifications = [
            null_resource.email.id
            #grafana_notification_channel.slack.id
          ]
        }
      }
    ]
  })
}

resource "null_resource" "email" {
  depends_on = [helm_release.grafana]
  provisioner "local-exec" {
    command = <<EOT
          curl -X POST http://localhost:3000/api/alert-notifications \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer admin:admin" \
            -d '{
              "name": "Email Alert",
              "type": "email",
              "settings": {
                "addresses": "devtest@devteam.com"
              },
              "isDefault": true
            }'

    EOT
  }
}

