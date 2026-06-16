# Samvad API.

Samvad is sanskrit word for conversation. It is used in the context of communication and interaction between individuals or groups. It is a fundamental aspect of human interaction and is essential for building relationships and understanding. We are using Gin framework to build our API.

The Gin framework is a web framework for Go that is known for its simplicity and performance. It is a popular choice for building web applications and APIs in Go.

## Requirements 📋

| Tool | Version | Why? |
|---|---|---|
| [Go](https://go.dev/dl/) | 1.24.2 | The language itself |
| [Gin](https://github.com/gin-gonic/gin) | latest | Web framework for the API |
| [godotenv](https://github.com/joho/godotenv) | latest | Loads `.env` locally (optional in prod) |
| [golangci-lint](https://golangci-lint.run/) | v2.1.6 | Code quality police 👮 |
| [lefthook](https://github.com/evilmartians/lefthook) | latest | Git hooks that keep you honest |

For local Kubernetes deployment (see section below), you'll also need:
- [Docker](https://docs.docker.com/get-docker/)
- [minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Installation

1. Install golang: https://go.dev/doc/install. We are using golang version 1.24.2

2. Install gin
```
go get github.com/gin-gonic/gin
```

## Initial setup
1. Create a new directory for your project and navigate to it in your terminal.

2. Initialize a new Go module by running the following command:
```
go mod init github.com/your_username/samvad
```

3. Create boilerplate directory structure using
```
mkdir -p cmd/server internal/{handler,service,config} pkg
touch cmd/server/main.go .gitignore README.md
```

4. Create a github repo and push your code to it.
```
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/your_username/samvad.git
git push -u origin main
```

5. Setup pre-commit hooks using lefthook
```
go get github.com/evilmartians/lefthook@latest
go install github.com/evilmartians/lefthook@latest

export PATH="$PATH:$HOME/go/bin"
lefthook install # Installs pre-commit hooks and pre-push hooks.
```

6. Install golang-ci linter
```
go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.1.6
go get github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.1.6
```

7. Install godotenv
```
go get github.com/joho/godotenv
go install github.com/joho/godotenv
```

## Local Kubernetes Deployment 🐳☸️

Samvad runs on Kubernetes because running things on bare metal is so 2010. Here's how we containerize and deploy locally using minikube.

### Prerequisites

1. Install Docker: https://docs.docker.com/get-docker/
2. Install minikube: https://minikube.sigs.k8s.io/docs/start/
3. Install kubectl: https://kubernetes.io/docs/tasks/tools/

### Folder structure

```
Dockerfile               # Multi-stage build: Go compiler → tiny Alpine binary (37MB!)
                         # Stage 1: golang:1.25-alpine builds the binary
                         # Stage 2: alpine:latest runs only the binary
                         # CGO_ENABLED=0 for a static, dependency-free binary

.dockerignore            # Keeps .env, .git, *.md out of the Docker context
                         # (your secrets stay on your laptop, where they belong)

k8s/local/
├── namespace.yaml       # samvad-dev — a little bubble where our pods live
├── secret.yaml          # Real API keys (gitignored, never committed)
├── secret.yaml.example  # Structure reference with placeholder values
├── deployment.yaml      # The boss — tells K8s what container to run and how
└── service.yaml         # The bouncer — routes traffic to the right pods

scripts/
├── local_deploy.sh      # One-click "make it so" 🚀
└── local_teardown.sh    # One-click "make it not so" 💥
```

### The files (and why they exist)

**Dockerfile** — Multi-stage build. The first stage compiles the Go binary with `CGO_ENABLED=0` (static linking, no OS dependencies). The second stage copies just the binary into a fresh Alpine image. Result: a ~37MB image instead of ~400MB. Your future self thanks you.

**.dockerignore** — Prevents `.env`, `.git`, and `*.md` from sneaking into the Docker build context. The `.env` is also gitignored, so your precious API keys never leave your machine.

**namespace.yaml** — Creates `samvad-dev`, a logical fence around all our K8s resources. Everything else (secret, deployment, service) lives inside it. Think of it as a labeled drawer in the kitchen — keeps things organized.

**secret.yaml** (gitignored) — Stores `VALID_API_KEY` as a Kubernetes Secret. Uses `stringData` so you can write plain text values (K8s automatically base64-encodes them). Copy `secret.yaml.example` to `secret.yaml`, fill in your real values, and never commit it. The deployment references this secret via `env.valueFrom.secretKeyRef`.

**deployment.yaml** — The heart of the operation. Tells K8s:
- Run 1 replica of the container with image `samvad-api:latest`
- Listen on port 8080 (the container's `containerPort`)
- Inject env vars from the `samvad-api-secret` secret
- Reserve 100m CPU + 64Mi memory (minimum guarantees)
- Cap at 500m CPU + 128Mi memory (burst limits)
- `imagePullPolicy: Never` — use the image in minikube's Docker, don't try to pull from the internet

**service.yaml** — A stable entry point that load-balances across pods. Defines three ports:
- `port: 80` — the internal cluster port (other services talk to `samvad-api-service:80`)
- `targetPort: 8080` — forwards to the container port (must match `containerPort` in deployment)
- `nodePort: 30080` — the external door (access via `http://<minikube-ip>:30080`)
- `type: NodePort` — makes the service accessible from outside the cluster

### The dev loop 🎡

Step 1: Build the Docker image
```
docker build -t samvad-api:latest .
```

Step 2: Deploy everything
```
./scripts/deployments/local/local_deploy.sh
```

This script will:
1. 🏗️ Start minikube (if not running)
2. 📦 Load the image into minikube's internal Docker
3. 🌍 Create the `samvad-dev` namespace
4. 🤫 Apply secrets
5. 🤖 Deploy the container
6. 🌐 Expose the service
7. 🔌 Open a port-forward tunnel to `localhost:8080`

Step 3: Test it
```
curl http://localhost:8080/api/v1/health
```

Step 4: Tear it down
```
./scripts/deployments/local/local_teardown.sh
```

This will kill the tunnel, delete all K8s resources (deployment, service, secret, namespace), and stop minikube. Everything, everywhere, all at once. 💥

## Local Terraform Deployment 🏗️☸️

Because YAML is so last week. Terraform manages the same K8s resources but with variables, state, and the ability to destroy everything with one command.

### Prerequisites (same as above +)
- [Terraform](https://developer.hashicorp.com/terraform/downloads) ≥ 1.15

### Folder structure
```
terraform/
├── modules/samvad-app/          # Reusable module
│   ├── main.tf                  # Resources (namespace, secret, deployment, service)
│   ├── variables.tf             # Input variables (env-specific ones required)
│   └── outputs.tf               # Host port, service port, node port
└── environments/
    └── local/                   # Local dev environment (minikube)
        ├── main.tf              # Module call with local overrides
        ├── variables.tf         # All local env config in one place
        ├── providers.tf         # Minikube kubeconfig
        ├── terraform.tfvars     # Your secrets (gitignored 🤫)
        └── terraform.tfvars.example
```

### The resources (and what they do)

| Resource | What it creates | Equivalent YAML |
|---|---|---|
| `kubernetes_namespace_v1` | `samvad-dev` namespace | `k8s/local/namespace.yaml` |
| `kubernetes_secret_v1` | `samvad-api-secret` with base64'd API key | `k8s/local/secret.yaml` |
| `kubernetes_deployment_v1` | 2 replicas, resource limits, env from secret | `k8s/local/deployment.yaml` |
| `kubernetes_service_v1` | NodePort service (port 80 → target 8080 → node 30080) | `k8s/local/service.yaml` |

### The dev loop 🎯

**One script does it all:**
```bash
./scripts/deployments/local/terraform_deploy.sh
```

This magical incantation:
1. 🏗️ Builds the Docker image
2. 🏁 Checks minikube is running (exits with instructions if not)
3. 📦 Loads image into minikube
4. 📋 `terraform init` (downloads provider)
5. 👀 `terraform plan` (shows what will change)
6. 🛠️ `terraform apply -auto-approve` (creates everything)
7. 🔌 `kubectl port-forward` to `localhost:8080` (background)

Test it:
```bash
curl http://localhost:8080/api/v1/health
```

**Tear it down:**
```bash
./scripts/deployments/local/terraform_destroy.sh
```

This kills the port-forward tunnel and runs `terraform destroy -auto-approve`. Poof! 💨

### State & Git Hygiene 🧼

| File | Git? | Why |
|---|---|---|
| `.terraform.lock.hcl` | ✅ **Commit** | Pins provider versions (no surprise upgrades) |
| `.terraform/` | ❌ **Ignore** | Local cache, platform-specific binaries |
| `terraform.tfvars` | ❌ **Ignore** | Contains your actual API key |
| `*.tfstate` | ❌ **Ignore** | State file = secrets + machine-specific |

> **Pro tip:** For teams, use remote state (S3 + DynamoDB, or Terraform Cloud) instead of local `.tfstate` files.

### Common Gotchas 🐛

| Symptom | Cause | Fix |
|---|---|---|
| Port-forward times out | Service selector didn't match pod labels | Fixed: selector now only requires `app` label |
| "Minikube not running" | You forgot to start it | Script tells you: `minikube start --driver docker` |
| Probes restart pods | `/health` needs API key | Removed probes; add public `/live` endpoint later |
| `terraform apply` fails | State drift or manual K8s changes | `terraform refresh` then re-apply |

### Next Level 🚀

1. **Module-ify** ✅ — Reusable module with `environments/local` and `environments/eks` (TODO)
2. **Remote state** — S3 bucket + DynamoDB locking
3. **Public health endpoint** — Add `/live` and `/ready` without auth for probes
4. **EKS migration** — Swap provider config, use `type = "LoadBalancer"`, IAM roles for secrets
