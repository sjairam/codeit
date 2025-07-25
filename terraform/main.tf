terraform {

  required_version = ">= 1.8.0"       #field for tf version.  minimum

  #Different fields and requirements for providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    #https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.23.0"
    }

  }
}

provider "aws" {
  region = "us-east-1"
}

#  TODO :  TO work out cluster dynamically
#provider "helm" {
#  kubernetes {
#    host              = "cluster-console.sand2.harvard.edu"
#    cluster_ca_certificate = base64decode(rke2_cluster.my_cluster.cluster_ca_certificate)
#    exec {
#      api_version = "client.authentication.k8s.io/v1beta1"
#      args        = ["eks", "get-token", "--cluster-name", "local"]
#      command     = "aws"
#    }
#  }
#}

# TODO :  TO work out cluster dynamically
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
    config_context = "sandbox1"
  }
}

# Create a namespace for observability
resource "kubernetes_namespace" "kafka-namespace" {
  metadata {
    name = "kafka"
  }
}

# Create a namespace for observability
resource "kubernetes_namespace" "observability-namespace" {
  metadata {
    name = "observability"
  }
}

# Helm chart for Strimzi Kafka
resource "helm_release" "strimzi-cluster-operator" {
  name = "strimzi-cluster-operator"  
  repository = "https://strimzi.io/charts/"
  chart = "strimzi-kafka-operator"
  version = "0.42.0"
  namespace = kubernetes_namespace.kafka-namespace.metadata[0].name
  depends_on = [kubernetes_namespace.kafka-namespace]
}