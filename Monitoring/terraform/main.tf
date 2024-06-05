terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"  # This assumes you're running Docker locally
}

variable "api_key" {
  description = "The API key to be used in the scraper configuration."
  type        = string
  sensitive   = true
}

variable "slack_webhook" {
  description = "Slack webhook for the Grafana contact point configuration"
  type        = string
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Grafana password for the Admin user"
  type        = string
  sensitive   = true
}

locals {
  scraper_config = templatefile("${pathexpand(path.module)}/scraper/config.yml.tmpl", {
    api_key = var.api_key
  })
  contacts_config = templatefile("${pathexpand(path.module)}/grafana/contacts.json.tmpl", {
    slack_webhook = var.slack_webhook
  })
  grafana_datasources_path = abspath("${path.module}/grafana/grafana.datasources.yaml")
  grafana_dashboard_path = abspath("${path.module}/grafana/dashboard.json")
  grafana_dashboards_config = abspath("${path.module}/grafana/default.yaml")
  grafana_contacts_path = abspath("${path.module}/grafana/contacts.json")
  grafana_alerts_path = abspath("${path.module}/grafana/alerts.json")
  grafana_policies_path = abspath("${path.module}/grafana/policies.json")
  prometheus_config_path = abspath("${path.module}/prometheus/prometheus.yml")
  ethereum_metrics_config_path = abspath("${path.module}/scraper/config.yml")
}

# Define volumes for persistent storage
resource "docker_volume" "prometheus_data" {
  name = "prometheus-data"
}

resource "docker_volume" "grafana_data" {
  name = "grafana-data"
}

# Define a Docker network for the services
resource "docker_network" "monitoring_network" {
  name = "monitoring_network"
}

# Deploy contract metrics scraper
resource "docker_container" "ethereum_address_metrics_exporter" {
  name  = "ethereum-address-metrics-exporter"
  image = "ethpandaops/ethereum-address-metrics-exporter:latest"

  networks_advanced {
    name = docker_network.monitoring_network.name
  }

  # Mount the configuration file from the host machine
  volumes {
    host_path      = local.ethereum_metrics_config_path
    container_path = "/config.yaml"
  }

  # Expose container ports
  ports {
    internal = 9090
    external = 9091
  }
  ports {
    internal = 5555
    external = 5555
  }
}

# Deploy Prometheus service
resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = "prom/prometheus:latest"

  networks_advanced {
    name = docker_network.monitoring_network.name
  }

  volumes {
    volume_name    = docker_volume.prometheus_data.name
    container_path = "/prometheus"
  }

  volumes {
    host_path      = local.prometheus_config_path  # Absolute path to the Prometheus configuration file
    container_path = "/etc/prometheus/prometheus.yml"
  }

  ports {
    internal = 9090
    external = 9090
  }
}

# Deploy Grafana service
resource "docker_container" "grafana" {
  name  = "grafana"
  image = "grafana/grafana:latest"
  networks_advanced {
    name = docker_network.monitoring_network.name
  }

  volumes {
    volume_name    = docker_volume.grafana_data.name
    container_path = "/var/lib/grafana"
  }

  volumes {
    host_path      = local.grafana_datasources_path  # Absolute path to the Grafana datasources file
    container_path = "/etc/grafana/provisioning/datasources/grafana.datasources.yaml"
  }

  volumes {
    host_path      = local.grafana_dashboards_config
    container_path = "/etc/grafana/provisioning/dashboards/default.yaml"
  }

  volumes {
      host_path      = local.grafana_dashboard_path  # Absolute path to the Grafana dashboards file
      container_path = "/etc/grafana/provisioning/dashboards/dashboard.json"
  }

  volumes {
    host_path      = local.grafana_contacts_path  # Absolute path to the Grafana contact poins file
    container_path = "/etc/grafana/provisioning/alerting/contacts.json"
  }

  volumes {
    host_path      = local.grafana_alerts_path  # Absolute path to the Grafana alerts file
    container_path = "/etc/grafana/provisioning/alerting/alerts.json"
  }
  
  volumes {
    host_path      = local.grafana_policies_path  # Absolute path to the Grafana policies file
    container_path = "/etc/grafana/provisioning/alerting/policies.json"
  }

  env = [
    "GF_SECURITY_DISABLE_LOGIN_FORM=true",
    "GF_SECURITY_ADMIN_USER=admin",
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}",
    "GF_USERS_ALLOW_SIGN_UP=false"
  ]

  ports {
    internal = 3000
    external = 3000
  }
}

# Local file resources to generate the scraper config and Gragana contact points config from templates
resource "local_file" "scraper_config" {
  content  = local.scraper_config
  filename = local.ethereum_metrics_config_path
}

resource "local_file" "contacts_config" {
  content  = local.contacts_config
  filename = local.grafana_contacts_path
}