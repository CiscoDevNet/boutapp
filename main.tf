#Helm install of sample app on IKS
data "terraform_remote_state" "iksws" {
  backend = "remote"
  config = {
    organization = var.org
    workspaces = {
      name = var.ikswsname
    }
  }
}

variable "org" {
  type = string
}
variable "ikswsname" {
  type = string
}
variable "appns" {
  type = string
}
variable "appchart" {
  type = string
}

resource helm_release byoapp {
  name       = "byoapp"
  namespace = var.appns
  chart = var.appchart
  #chart = "https://prathjan.github.io/helm-chart/boutapp-0.2.0.tgz"
  timeout = 600
}

provider "helm" {
  kubernetes {
    host = local.kube_config.clusters[0].cluster.server
    client_certificate = base64decode(local.kube_config.users[0].user.client-certificate-data)
    client_key = base64decode(local.kube_config.users[0].user.client-key-data)
    cluster_ca_certificate = base64decode(local.kube_config.clusters[0].cluster.certificate-authority-data)
  }
}

locals {
  kube_config = yamldecode(data.terraform_remote_state.iksws.outputs.kube_config)
}

