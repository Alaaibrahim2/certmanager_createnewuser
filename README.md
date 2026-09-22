# 🔐 cert-manager User Certificate + RBAC

A Kubernetes lab demonstrating how to use **cert-manager** to issue a client certificate for a Kubernetes user, authenticate that user with the API Server, and control access using RBAC.

## 🏗️ Architecture

```text
Kubernetes Cluster CA
        │
        ▼
cert-manager Issuer
        │
        ▼
Certificate
CN = abdo
        │
        ▼
Secret: abdo-user-tls
 ├── tls.crt
 ├── tls.key
 └── ca.crt
        │
        ▼
abdo.crt + abdo.key
        │
        ▼
Kubeconfig / Context
        │
        ▼
Kubernetes API Server
        │
        ▼
Authentication
username = abdo
        │
        ▼
RBAC
        │
        ▼
Allowed / Forbidden
```

## ⚙️ What Was Implemented

* Installed and configured **cert-manager Operator through OLM**
* Created an **Issuer** backed by the Kubernetes Cluster CA
* Issued a client certificate for user **`abdo`**
* Stored the certificate and private key in a Kubernetes **Secret**
* Created an `abdo` kubeconfig context using the existing cluster
* Created a **Role + RoleBinding** for `abdo`
* Allowed `abdo` to `get`, `list`, and `watch` Pods in the `default` namespace

## 📂 Repository Structure

```text
abdo-certmanager-rbac/
├── README.md
├── commands.sh
└── manifests/
    ├── 01-operatorgroup.yaml
    ├── 02-issuer.yaml
    ├── 03-certificate.yaml
    └── 04-rbac.yaml
```

## 🔑 Authentication & Authorization

```text
Certificate CN = abdo
        ↓
API Server Authentication
        ↓
User = abdo
        ↓
RoleBinding
        ↓
Role
        ↓
get/list/watch Pods in default
```

The **certificate identifies the user**, while **RBAC defines what the user is allowed to do**.

## 🧪 Result

```bash
kubectl --context=abdo-context get pods
```

✅ Allowed

```bash
kubectl --context=abdo-context get deployments
```

❌ Forbidden

```bash
kubectl --context=abdo-context get pods -n kube-system
```

❌ Forbidden

## 🔄 Certificate Renewal

cert-manager manages the Certificate lifecycle and automatically renews it before expiration. The Kubernetes Secret is updated with the renewed certificate.

> ⚠️ Never commit `abdo.key`, `abdo.crt`, or the Kubernetes CA private key to GitHub.

