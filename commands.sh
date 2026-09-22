#!/usr/bin/env bash
set -euo pipefail

# 1) Create a Secret containing the Kubernetes cluster CA.
sudo cp /etc/kubernetes/pki/ca.crt /tmp/kubernetes-ca.crt
sudo cp /etc/kubernetes/pki/ca.key /tmp/kubernetes-ca.key

sudo chown ubuntu:ubuntu /tmp/kubernetes-ca.crt /tmp/kubernetes-ca.key
sudo chmod 600 /tmp/kubernetes-ca.key

kubectl create secret tls kubernetes-ca \
  --cert=/tmp/kubernetes-ca.crt \
  --key=/tmp/kubernetes-ca.key \
  -n default

rm -f /tmp/kubernetes-ca.crt /tmp/kubernetes-ca.key


# 2) Apply manifests.
kubectl apply -f manifests/01-operatorgroup.yaml
kubectl apply -f manifests/02-issuer.yaml
kubectl apply -f manifests/03-certificate.yaml
kubectl apply -f manifests/04-rbac.yaml


# 3) Export abdo's client certificate and private key.
kubectl get secret abdo-user-tls -n default \
  -o jsonpath='{.data.tls\.crt}' | base64 -d > abdo.crt

kubectl get secret abdo-user-tls -n default \
  -o jsonpath='{.data.tls\.key}' | base64 -d > abdo.key

chmod 600 abdo.key


# 4) Create abdo context on the EXISTING cluster.
CLUSTER_NAME="$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')"

kubectl config set-credentials abdo \
  --client-certificate=abdo.crt \
  --client-key=abdo.key

kubectl config set-context abdo-context \
  --cluster="${CLUSTER_NAME}" \
  --user=abdo \
  --namespace=default


# 5) Test without changing the current context.
kubectl --context=abdo-context get pods

kubectl --context=abdo-context get deployments || true

kubectl --context=abdo-context get pods -n kube-system || true
