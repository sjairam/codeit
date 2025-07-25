#!/bin/bash
set -e

# Namespace for Kafka
NAMESPACE="kafka"

# Create namespace if it doesn't exist
kubectl get namespace $NAMESPACE >/dev/null 2>&1 || kubectl create namespace $NAMESPACE

# Add Strimzi Helm repo
helm repo add strimzi https://strimzi.io/charts/
helm repo update

# Install or upgrade Strimzi Kafka operator
helm upgrade --install strimzi-kafka-operator strimzi/strimzi-kafka-operator \
  --namespace $NAMESPACE \
  --set watchAnyNamespace=true

# Wait for the Strimzi operator to be ready
kubectl rollout status deployment/strimzi-cluster-operator -n $NAMESPACE

# Deploy a sample Kafka cluster
cat <<EOF | kubectl apply -n $NAMESPACE -f -
apiVersion: kafka.strimzi.io/v1beta2
kind: Kafka
metadata:
  name: my-cluster
spec:
  kafka:
    version: 3.6.0
    replicas: 3
    listeners:
      - name: plain
        port: 9092
        type: internal
        tls: false
      - name: tls
        port: 9093
        type: internal
        tls: true
    storage:
      type: ephemeral
  zookeeper:
    replicas: 3
    storage:
      type: ephemeral
  entityOperator:
    topicOperator: {}
    userOperator: {}
EOF

echo "Strimzi Kafka operator and sample cluster deployed in namespace '$NAMESPACE'."
