variable "teams" {
  type = list(string)
  default = ["gryffindor", "slytherin"]
}

variable "namespace" {
type = list(string)
  default = ["gryffindor", "slytherin"]
}

variable "team_users" {
  type = map(string)
  default = {
    "gryffindor" = "harry"
    "slytherin" = "malfoy"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "kind-kube-cluster01"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Create namespaces for each team
resource "kubernetes_namespace" "team_namespaces" {
  count = length(var.teams)

  metadata {
    name = var.teams[count.index]
  }
}

# Create a virtual cluster for each team
resource "helm_release" "vcluster" {
  count            = length(var.teams)
  name             = "${var.teams[count.index]}-vcluster"
  repository       = "https://charts.loft.sh"
  chart            = "vcluster"
  namespace        = kubernetes_namespace.team_namespaces[count.index].metadata[0].name
  create_namespace = false
}

# Define roles for each team
resource "kubernetes_role" "team_roles" {
  count = length(var.teams)

  metadata {
    name      = "${var.teams[count.index]}-role"
    namespace = var.namespace[count.index]
  }

  rule {
    api_groups = count.index == 0 ? ["apps"] : [""]
    resources  = count.index == 0 ? ["deployments"] : ["pods"]
    verbs      = count.index == 0 ? ["create", "update", "delete"] : ["get", "list"]
  }
}

# Create role bindings for each team
resource "kubernetes_role_binding" "team_role_bindings" {
  count = length(var.teams)

  metadata {
    name      = "${var.teams[count.index]}-role-binding"
    namespace = var.namespace[count.index]
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.team_roles[count.index].metadata[0].name
  }

  subject {
    kind      = "User"
    name      = var.team_users[var.teams[count.index]]
    api_group = "rbac.authorization.k8s.io"
  }
}
