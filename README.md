# Description

Module to configure a k8s cluster receiving a kubeconfig file content as input with a list of services to expose with a dynamic ingress block.

# Special notes

_An empty kubeconfig file is required to workaround the first provider load. In apply time, kubeconfig file is changed by a generated file that contains the right cluster configuration._

Well integrated with the CCE Cluster module created also by me.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.8.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 2.8.0 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |

## Resources

| Name | Type |
|------|------|
| [kubernetes_deployment.api](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_ingress_v1.ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_secret_v1.secret_tls](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_service.api_service](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [local_file.kubeconfig](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | n/a | `string` | n/a | yes |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | n/a | `string` | n/a | yes |
| <a name="input_kubeconfig"></a> [kubeconfig](#input\_kubeconfig) | Kubeconfig file content | `string` | n/a | yes |
| <a name="input_load_balancer_id"></a> [load\_balancer\_id](#input\_load\_balancer\_id) | n/a | `string` | n/a | yes |
| <a name="input_load_balancer_ip"></a> [load\_balancer\_ip](#input\_load\_balancer\_ip) | n/a | `string` | n/a | yes |
| <a name="input_load_balancer_port"></a> [load\_balancer\_port](#input\_load\_balancer\_port) | Load balancer listener port | `string` | `"80"` | no |
| <a name="input_project"></a> [project](#input\_project) | n/a | `string` | n/a | yes |
| <a name="input_service_list"></a> [service\_list](#input\_service\_list) | n/a | <pre>list(object({<br>    api_name       = string<br>    replicas       = number<br>    docker_image   = string<br>    container_port = number<br>    port_name      = string<br>  url_path = string }))</pre> | n/a | yes |
| <a name="input_ssl_cert"></a> [ssl\_cert](#input\_ssl\_cert) | SSL certificate to use with HTTPS Listener. Required if use 443 as port | `string` | `""` | no |
| <a name="input_ssl_key"></a> [ssl\_key](#input\_ssl\_key) | SSL key associated with ssl cert. Required if use 443 as port | `string` | `""` | no |


## Example Usage

````
module "k8s_config" {
  source       = "git@github.com:abejarano/huawei-cloud-k8s-config-tf-module"
  project      = var.project
  environment  = var.environment
  kubeconfig   = module.k8s_cluster.kubeconfig
  service_list = local.services
  load_balancer_id = module.k8s_cluster.load_balancer_id
  load_balancer_ip = module.k8s_cluster.load_balancer_eip
  hostname         = "test.com"
  load_balancer_port = "443"
  ssl_cert = var.ssl_cert
  ssl_key = var.ssl_key
}

locals {
  services = [
    {
      api_name       = "nginx"
      replicas       = 2
      docker_image   = "nginx:1.8"
      container_port = 80
      port_name      = "http"
      url_path       = "/"
    }
  ]
}

````
