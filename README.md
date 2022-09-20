# terraform-kubernetes-elasticsearch

Elasticsearch module for Kubernetes based on [[Elasticsearch Helm charts](https://github.com/elastic/helm-charts/tree/master/elasticsearch). Latest changes from Helm charts are from ([521eb282b72491ea52f430145c2d718375d735ef](https://github.com/elastic/helm-charts/commit/521eb282b72491ea52f430145c2d718375d735ef#diff-18897dcfce6a4e7ae63a3baeed443c48).

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
