# terraform-kubernetes-elasticsearch

Elasticsearch module for Kubernetes based on [Elasticsearch Helm charts](https://github.com/elastic/helm-charts/tree/master/elasticsearch)

## Usage

```hcl-terraform
locals {
  cluster_name          = "elasticsearch-cluster"
  es_version            = "7.17.3"
  master_eligible_nodes = 1
  namespace             = "elk"
}

module "elasticsearch_client" {
  source                = "./modules/terraform-kubernetes-elasticsearch"
  node_group            = "client"
  cluster_name          = local.cluster_name
  es_version            = local.es_version
  namespace             = local.namespace
  master_eligible_nodes = local.master_eligible_nodes
}

module "elasticsearch_master" {
  source                = "./modules/terraform-kubernetes-elasticsearch"
  node_group            = "master"
  cluster_name          = local.cluster_name
  es_version            = local.es_version
  namespace             = local.namespace
  master_eligible_nodes = local.master_eligible_nodes
}

module "elasticsearch_data" {
  source                = "./modules/terraform-kubernetes-elasticsearch"
  node_group            = "data"
  cluster_name          = local.cluster_name
  es_version            = local.es_version
  namespace             = local.namespace
  master_eligible_nodes = local.master_eligible_nodes
}

output "elasticsearch_endpoint" {
  value = module.elasticsearch_master.elasticsearch_endpoint
}
```

### Variables

In order to check which variables are customizable, check `variables.tf`.
