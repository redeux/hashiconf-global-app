provider "google" {
  zone = var.zone
}

data "google_client_config" "default" {
}

data "google_container_cluster" "default" {
  name = var.cluster_name
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.default.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.default.master_auth[0].cluster_ca_certificate,
  )
  experiments {
    manifest_resource = true
  }
}

resource "kubernetes_manifest" "workspace_gke_cluster" {
  manifest = {
    "apiVersion" = "app.terraform.io/v1alpha1"
    "kind"       = "Workspace"
    "metadata" = {
      "name"      = "gke-cluster"
      "namespace" = "demo"
    }
    "spec" = {
      "module" = {
        "source"  = "redeux/gke-basic/google"
        "version" = "0.1.0"
      }
      "organization" = "tf-eco-k8s-vmw"
      "outputs" = [
        {
          "key"              = "zone"
          "moduleOutputName" = "google_zone"
        },
        {
          "key"              = "version"
          "moduleOutputName" = "node_version"
        },
      ]
      "secretsMountPath" = "/tmp/secrets"
      "variables" = [
        {
          "environmentVariable" = false
          "key"                 = "cluster_name"
          "sensitive"           = false
          "value"               = "allthewaydown"
        },
        {
          "environmentVariable" = true
          "key"                 = "GOOGLE_CREDENTIALS"
          "sensitive"           = true
        },
        {
          "environmentVariable" = true
          "key"                 = "GOOGLE_PROJECT"
          "sensitive"           = true
        },
        {
          "environmentVariable" = true
          "key"                 = "GOOGLE_REGION"
          "sensitive"           = true
        },
        {
          "environmentVariable" = true
          "key"                 = "CONFIRM_DESTROY"
          "sensitive"           = false
          "value"               = "1"
        },
      ]
    }
  }
}
