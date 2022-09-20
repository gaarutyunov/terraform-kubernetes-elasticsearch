locals {
  // Elasticsearch monitoring related local var
  prefixed_node_group = (var.node_group != "") ? "-${var.node_group}" : var.node_group
  keystore            = concat(var.keystore, [])
  image_pull_secrets  = concat(var.image_pull_secrets, [])
  image               = var.image != "" ? var.image : "docker.elastic.co/elasticsearch/elasticsearch"
}

resource "helm_release" "elasticsearch" {
  name       = local.full_name_override
  repository = "https://helm.elastic.co"
  chart      = "elasticsearch"
  namespace  = var.namespace
  timeout    = var.helm_install_timeout

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "nodeGroup"
    value = var.node_group
  }

  set {
    name  = "fullnameOverride"
    value = local.full_name_override
  }

  set {
    name  = "masterService"
    value = local.master_service
  }

  dynamic "set" {
    for_each = var.es_config

    content {
      type  = "string"
      name  = "esConfig.${set.key}"
      value = var.es_config[set.key]
    }
  }

  set {
    name  = "antiAffinity"
    value = var.anti_affinity
  }

  set {
    name  = "protocol"
    value = var.protocol
  }

  set {
    name  = "httpPort"
    value = var.http_port
  }

  dynamic "set" {
    for_each = var.common_annotations

    content {
      type  = "string"
      name  = "commonAnnotations.\"${set.key}\""
      value = var.common_annotations[set.key]
    }
  }

  set {
    type  = "string"
    name  = "roles.master"
    value = local.roles["master"]
  }

  set {
    type  = "string"
    name  = "roles.data"
    value = local.roles["data"]
  }

  set {
    type  = "string"
    name  = "roles.ingest"
    value = local.roles["ingest"]
  }

  set {
    name  = "image"
    value = local.image
  }

  set {
    name  = "imageTag"
    value = var.es_version
  }

  dynamic "set" {
    for_each = local.image_pull_secrets

    content {
      name  = "imagePullSecrets[${set.key}].name"
      value = local.image_pull_secrets[set.key]
    }
  }

  set {
    name  = "replicas"
    value = local.replicas
  }

  set {
    name  = "minimumMasterNodes"
    value = local.minimum_master_nodes
  }

  set {
    name  = "terminationGracePeriod"
    value = var.termination_grace_period
  }

  set {
    name  = "resources.requests.cpu"
    value = var.resources.requests.cpu
  }

  set {
    name  = "resources.requests.memory"
    value = var.resources.requests.memory
  }

  set {
    name  = "resources.limits.cpu"
    value = var.resources.limits.cpu
  }

  set {
    name  = "resources.limits.memory"
    value = var.resources.limits.memory
  }

  set {
    name  = "volumeClaimTemplate.storageClassName"
    value = var.storage_class_name
  }

  set {
    name  = "volumeClaimTemplate.resources.requests.storage"
    value = var.storage_size
  }

  set {
    name  = "persistence.enabled"
    value = local.persistance_enabled
  }

  set {
    name  = "ingress.enabled"
    value = var.ingress.enabled
  }

  dynamic "set" {
    for_each = var.ingress.hosts

    content {
      name  = "ingress.hosts[${set.key}].host"
      value = var.ingress.hosts[set.key].host
    }
  }

  dynamic "set" {
    for_each = var.ingress.hosts

    content {
      name  = "ingress.hosts[${set.key}].path"
      value = var.ingress.hosts[set.key].path
    }
  }

  dynamic "set" {
    for_each = var.ingress.hosts

    content {
      name  = "ingress.hosts[${set.key}].port"
      value = var.ingress.hosts[set.key].port
    }
  }

  dynamic "set" {
    for_each = var.ingress.annotations

    content {
      name  = "ingress.annotations.\"${set.key}\""
      value = var.ingress.annotations[set.key]
    }
  }

  dynamic "set" {
    for_each = var.extra_service_ports.ports

    content {
      name  = "extraServicePorts.ports[${set.key}].name"
      value = var.extra_service_ports.ports[set.key].name
    }
  }

  dynamic "set" {
    for_each = var.extra_service_ports.ports

    content {
      name  = "extraServicePorts.ports[${set.key}].port"
      value = var.extra_service_ports.ports[set.key].port
    }
  }

  dynamic "set" {
    for_each = var.extra_service_ports.ports

    content {
      name  = "extraServicePorts.ports[${set.key}].nodePort"
      value = var.extra_service_ports.ports[set.key].node_port
    }
  }

  dynamic "set" {
    for_each = var.extra_service_ports.ports

    content {
      name  = "extraServicePorts.ports[${set.key}].targetPort"
      value = var.extra_service_ports.ports[set.key].target_port
    }
  }

  dynamic "set" {
    for_each = var.extra_configs

    content {
      name  = "extraConfigs[${set.key}].name"
      value = var.extra_configs[set.key].name
    }
  }

  dynamic "set" {
    for_each = var.extra_configs

    content {
      name  = "extraConfigs[${set.key}].path"
      value = var.extra_configs[set.key].path
    }
  }

  dynamic "set" {
    for_each = var.extra_configs

    content {
      name  = "extraConfigs[${set.key}].config"
      value = var.extra_configs[set.key].config
    }
  }

  dynamic "set" {
    for_each = var.tolerations

    content {
      name  = "tolerations[${set.key}].key"
      value = var.tolerations[set.key].key
    }
  }

  dynamic "set" {
    for_each = var.tolerations

    content {
      name  = "tolerations[${set.key}].operator"
      value = var.tolerations[set.key].operator
    }
  }

  dynamic "set" {
    for_each = var.tolerations

    content {
      name  = "tolerations[${set.key}].value"
      value = var.tolerations[set.key].value
    }
  }

  dynamic "set" {
    for_each = var.tolerations

    content {
      name  = "tolerations[${set.key}].effect"
      value = var.tolerations[set.key].effect
    }
  }

  dynamic "set" {
    for_each = var.node_selector

    content {
      type  = "string"
      name  = "nodeSelector.${set.key}"
      value = var.node_selector[set.key]
    }
  }

  set {
    name  = "esJavaOpts"
    value = var.es_java_opts
  }

  set {
    name  = "extraVolumes"
    value = var.extra_volumes
  }

  set {
    name  = "extraContainers"
    value = var.extra_containers
  }

  dynamic "set" {
    for_each = local.keystore

    content {
      name  = "keystore[${set.key}].secretName"
      value = local.keystore[set.key]
    }
  }
}
