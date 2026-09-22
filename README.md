# cert-manager User Certificate + RBAC Lab

This lab creates a Kubernetes client certificate for user `abdo` using cert-manager, signed by the Kubernetes cluster CA, then uses that identity with Kubernetes RBAC.

## Architecture

```text
Kubernetes Cluster CA
        |
        v
cert-manager Issuer
        |
        v
Certificate: abdo
CN = abdo
        |
        v
Secret: abdo-user-tls
  |-- tls.crt
  |-- tls.key
  `-- ca.crt
        |
        v
abdo client certificate
        |
        v
Kubernetes kubeconfig context
        |
        v
API Server Authentication
        |
        v
username = abdo
        |
        v
RBAC RoleBinding
        |
        v
get/list/watch Pods in default
