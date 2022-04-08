resource "kubernetes_deployment" "api" {
  for_each = { for service in var.service_list : service.api_name => service }
  metadata {
    name = each.value.api_name
    labels = {
      app = each.value.api_name
    }
  }

  spec {
    replicas = each.value.replicas

    selector {
      match_labels = {
        app = each.value.api_name
      }
    }

    template {
      metadata {
        labels = {
          app = each.value.api_name
        }
      }

      spec {
        container {
          image = each.value.docker_image
          name  = each.value.api_name

          port {
            container_port = each.value.container_port
          }
        }
        restart_policy = "Always"
      }
    }
  }
}

resource "kubernetes_service" "api_service" {
  depends_on = [kubernetes_deployment.api]
  for_each   = { for service in var.service_list : service.api_name => service }
  metadata {
    name = each.value.api_name
    labels = {
      app = each.value.api_name
    }
  }
  spec {
    selector = {
      app = each.value.api_name
    }
    port {
      port        = each.value.container_port
      target_port = each.value.container_port
      name        = each.value.port_name
    }

    type = "NodePort"
  }
}

resource "kubernetes_ingress_v1" "ingress" {
  depends_on = [kubernetes_service.api_service]
  metadata {
    name = "${local.project_name}-ingress-rule"
    labels = {
      zone       = "data"
      isExternal = "true"
    }
    namespace = "default"
    annotations = {
      "kubernetes.io/elb.tls-ciphers-policy" = var.load_balancer_port == "443" ? "tls-1-2" : ""
      "kubernetes.io/ingress.class"          = "cce"
      "kubernetes.io/elb.port"               = var.load_balancer_port
      "kubernetes.io/elb.ip"                 = var.load_balancer_ip
      "kubernetes.io/elb.id"                 = var.load_balancer_id
    }
  }

  spec {
    # default_backend {
    #   service {
    #     name = "MyApp1"
    #     port {
    #       number = 8080
    #     }
    #   }
    # }
    dynamic "tls" {
      for_each = var.load_balancer_port == "443" ? [kubernetes_secret_v1.secret_tls] : []
      content {
        secret_name = "${var.project}-${var.environment}-tls"
      }
    }

    dynamic "rule" {
      for_each = var.service_list
      content {
        host = var.hostname
        http {
          path {
            backend {
              service {
                name = rule.value.api_name
                port {
                  number = rule.value.container_port
                }
              }
            }
            path = rule.value.url_path
          }
        }
      }
    }
  }
}


resource "kubernetes_secret_v1" "secret_tls" {
  count = var.load_balancer_port == "443" ? 1 : 0
  metadata {
    name = "${var.project}-${var.environment}-tls"
  }

  data = {
    "tls.crt" = var.ssl_cert
    "tls.key" = var.ssl_key
  }

  type = "IngressTLS"
}