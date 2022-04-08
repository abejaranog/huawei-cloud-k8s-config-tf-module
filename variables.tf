variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "kubeconfig" {
  type        = string
  description = "Kubeconfig file content"
}

variable "load_balancer_port" {
  type        = string
  description = "Load balancer listener port"
  default     = "80"
}

variable "load_balancer_ip" {
  type = string
}

variable "load_balancer_id" {
  type = string
}

variable "hostname" {
  type = string
}

variable "service_list" {
  type = list(object({
    api_name       = string
    replicas       = number
    docker_image   = string
    container_port = number
    port_name      = string
  url_path = string }))
}

variable "ssl_cert" {
  type        = string
  description = "SSL certificate to use with HTTPS Listener. Required if use 443 as port"
  default     = ""
}

variable "ssl_key" {
  type        = string
  description = "SSL key associated with ssl cert. Required if use 443 as port"
  default     = ""
}