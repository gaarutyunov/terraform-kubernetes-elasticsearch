variable "helm_install_timeout" {
  type        = number
  default     = 600
  description = "Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks)"
}

variable "cluster_name" {
  type        = string
  default     = "elasticsearch-cluster"
  description = "Elasticsearch cluster name and release name"
}

variable "anti_affinity" {
  type        = string
  default     = "soft"
}

variable "node_suffix" {
  type        = string
  default     = ""
  description = "Suffix that will be added to the name of this instance"
}

variable "node_group" {
  type        = string
  default     = ""
  description = "This is the name that will be used for each group of nodes in the cluster (values: client, master, node). In case of only one node, leave empty."
}

variable "protocol" {
  type        = string
  default     = "http"
  description = "The protocol that will be used for the readinessProbe. Change this to `https` if you have `xpack.security.http.ssl.enabled` set"
}

variable "http_port" {
  type        = string
  default     = "9200"
  description = "The http port that Kubernetes will use for the healthchecks and the service. If you change this you will also need to set http.port in extraEnvs"
}

variable "common_annotations" {
  type        = map(string)
  default     = {}
  description = "Common annotations for all the resources"
}

variable "pod_annotations" {
  type        = map(string)
  default     = {}
  description = "Configurable annotations applied to all Elasticsearch pods"
}

variable "roles" {
  type = object({
    master = bool
    data   = bool
    ingest = bool
  })
  default = {
    "master" = null
    "data"   = null
    "ingest" = null
  }
  description = "A hash map with the specific roles for the node group"
}

variable "image_pull_secrets" {
  type        = list(string)
  description = "Image Pull Secrets"
  default     = []
}

variable "image" {
  type        = string
  description = "Elasticsearch image"
  default     = ""
}

variable "es_version" {
  type        = string
  description = "Elasticsearch version"
}

variable "namespace" {
  type        = string
  description = "Namespace in which service will be deployed"
}

variable "replicas" {
  type        = number
  default     = 1
  description = "Kubernetes replica count for the statefulset (i.e. how many pods)"
}

variable "master_eligible_nodes" {
  type        = number
  default     = 3
  description = "Number of master eligible nodes used to calculate minimumMasterNodes"
}

variable "es_config" {
  type = map(string)
  default = {
    "elasticsearch\\.yml" : <<EOT
xpack.license.self_generated.type: basic
xpack.security.enabled: false
EOT
  }
  description = "Allows you to add any config files in `/usr/share/elasticsearch/config/` such as `elasticsearch.yml` and `log4j2.properties`. See [values.yaml](https://github.com/elastic/helm-charts/tree/master/elasticsearch/values.yaml) for an example of the formatting"
}

variable "termination_grace_period" {
  type        = number
  default     = 120
  description = "The terminationGracePeriod in seconds used when trying to stop the pod"
}

variable "es_java_opts" {
  type        = string
  default     = "-Xmx128m -Xms128m"
  description = "Java options for Elasticsearch. This is where you should configure the jvm heap size. Can be around half of requests memory."
}

variable "storage_class_name" {
  type        = string
  default     = "hostpath"
  description = "Storage class name"
}

variable "storage_size" {
  type        = string
  default     = "512M"
  description = "Storage size of the storageClassName"
}

variable "resources" {
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })

  default = {
    requests = {
      cpu    = "100m"
      memory = "512M"
    }
    limits = {
      cpu    = "1000m"
      memory = "512M"
    }
  }

  description = "Allows you to set the resources for the statefulset"
}

variable "ingress" {
  type = object({
    enabled = bool
    hosts = list(object({
      host = string
      path = string
      port = string
    }))
    annotations = map(string)
  })
  default = {
    enabled = false
    hosts = [
      {
        host = ""
        path = "/"
        port = 5601
      }
    ]
    annotations = {}
  }
  description = "Configurable ingress to expose the Elasticsearch service"
}

variable "extra_service_ports" {
  type = object({
    ports = list(object({
      name        = string
      port        = string
      node_port   = string
      target_port = string
    }))
  })
  default = {
    ports = []
  }
  description = "Configurable service to expose the Elasticsearch service"
}

variable "extra_configs" {
  type = list(object({
    name   = string
    path   = string
    config = string
  }))
  default     = []
  description = "Additional config maps"
}

variable "extra_volumes" {
  type        = string
  default     = ""
  description = "Templatable string of additional volumes to be passsed to the tpl function"
}

variable "extra_containers" {
  type        = string
  default     = ""
  description = "Templatable string of additional containers to be passed to the tpl function"
}

variable "keystore" {
  type        = list(string)
  default     = []
  description = "Allows you map Kubernetes secrets into the keystore."
}

variable "tolerations" {
  type = list(object({
    key      = string
    operator = string
    value    = string
    effect   = string
  }))
  default = []
}

variable "node_selector" {
  type    = map(string)
  default = {}
}

locals {
  default_replicas = {
    "client" = 2
    "master" = 3
    "data"   = 3
  }

  default_roles = {
    "" = {
      "master" = true
      "data"   = true
      "ingest" = false
    }
    "client" = {
      "master" = false
      "data"   = false
      "ingest" = false
    }
    "master" = {
      "master" = true
      "data"   = false
      "ingest" = false
    }
    "data" = {
      "master" = false
      "data"   = true
      "ingest" = true
    }
  }

  node_suffix          = var.node_suffix != "" ? "-${var.node_suffix}" : ""
  full_name_override   = var.node_group != "" ? "${var.cluster_name}-${var.node_group}${local.node_suffix}" : "${var.cluster_name}${local.node_suffix}"
  master_service       = var.node_group != "" ? "${var.cluster_name}-master" : ""
  replicas             = var.replicas != 0 ? var.replicas : local.default_replicas[var.node_group]
  minimum_master_nodes = floor((var.master_eligible_nodes / 2) + 1)
  roles = {
    "master" = coalesce(var.roles["master"], local.default_roles[var.node_group]["master"])
    "data"   = coalesce(var.roles["data"], local.default_roles[var.node_group]["data"])
    "ingest" = coalesce(var.roles["ingest"], local.default_roles[var.node_group]["ingest"])
  }
  persistance_enabled = var.node_group != "client" ? true : false
}
