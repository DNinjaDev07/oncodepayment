# OnCode Payment Recorder

A DEMO DevOps CRUD app for payment records. This project demonstrates a full DevOps pipeline: containerized Spring Boot backend, Nginx frontend, PostgreSQL database, Helm charts for Kubernetes, Terraform for Infrastructure As Code, and ArgoCD for GitOps.

## Stack

- Backend: Java 17, Spring Boot, Spring Data JPA
- Database: PostgreSQL (H2 fallback for local dev/tests)
- Frontend: HTML, CSS, JavaScript, Nginx
- Containers: Docker (multi-stage builds), Docker Compose
- Orchestration: Kubernetes via Kind cluster
- Infrastructure: Terraform (Ingress, ArgoCD, namespaces)
- Platform: Nginx Ingress Controller, ArgoCD
- GitOps: ArgoCD watches this repo and auto-syncs Helm charts to the cluster

## Run Locally with Docker

1. Start the full stack:
```bash
docker compose up --build
```

2. Open:
- Frontend: http://localhost
- Backend API: http://localhost:8098/oncode/getpayments

3. Stop:
```bash
docker compose down
```

4. Stop and remove database volume:
```bash
docker compose down -v
```

## Run on Kubernetes (Kind + Terraform)

Prerequisites: Docker, Kind, Terraform (>= 1.14), kubectl, Helm 3.x

1. Create the Kind cluster:
```bash
kind create cluster --name oncodepayment --config kind-config.yaml
```

2. Deploy the platform (Ingress, ArgoCD, namespaces, ArgoCD Application):
```bash
cd terraform
terraform init
terraform apply
```

3. Access ArgoCD:
```bash
kubectl port-forward -n argocd svc/argocd-server 8080:443
```
- URL: https://localhost:8080
- Username: admin
- Password:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

4. Access the app:
```bash
# Add to /etc/hosts
127.0.0.1 oncodepayment.local
```
Visit http://oncodepayment.local:8081

5. Tear down:
```bash
cd terraform
terraform destroy
kind delete cluster --name oncodepayment
```

## API Endpoints

Base path: `/oncode`

| Method | Path | Description |
|--------|------|-------------|
| GET | /getpayments | List all payments |
| GET | /getpayment/{id} | Get one payment |
| POST | /addpayment | Create a payment |
| PUT | /updatepayment/{id} | Update a payment |
| DELETE | /deletepayment/{id} | Delete a payment |

Sample payload:
```json
{
  "amount": 42.42,
  "fromAccount": 1111111,
  "toAccount": 2222222
}
```

## Project Structure

```
oncodepayment/
  Dockerfile                  # Multi-stage build (Maven build + JRE runtime)
  docker-compose.yml          # Local dev: backend + frontend + PostgreSQL
  kind-config.yaml            # Kind cluster config (control-plane)
  pom.xml                     # Spring Boot + PostgreSQL + H2
  src/                        # Java source code
  frontend/                   # Nginx frontend (Dockerfile + nginx.conf.template)
  helm/oncodepayment/         # Helm chart (10 templates)
    Chart.yaml
    values.yaml
    templates/
      backend-deployment.yml, backend-service.yml
      frontend-deployment.yml, frontend-service.yml
      postgresql-deployment.yml, postgresql-service.yml, postgresql-pvc.yml
      configmap.yml, secret.yml, ingress.yml
  terraform/                  # Platform infrastructure (Terraform)
    providers.tf              # Providers: helm, kubernetes, kubectl
    variables.tf              # kubeconfig_path, namespaces, repo URL, branch
    main.tf                   # Namespaces + Nginx Ingress
    argocd.tf                 # ArgoCD Helm release + Application manifest
    outputs.tf                # ArgoCD password retrieval command
  legacy/                     # Old CI/CD files (Jenkins, old K8s manifests)
```

## Configuration

Backend reads environment variables from `src/main/resources/application.properties`. Without env vars, it falls back to H2 in-memory for local dev.

| Variable | Purpose | Default |
|----------|---------|---------|
| DB_URL | JDBC connection string | jdbc:h2:mem:paymentdb |
| DB_USERNAME | Database username | sa |
| DB_PASSWORD | Database password | (empty) |
| DB_DRIVER | JDBC driver class | org.h2.Driver |
| JPA_DDL_AUTO | Hibernate DDL strategy | create-drop |
| JPA_DIALECT | Hibernate dialect | H2Dialect |
| CORS_ORIGINS | Allowed CORS origins | localhost variants |

Terraform variables (all have defaults, override with `-var` or `terraform.tfvars`):

| Variable | Default |
|----------|---------|
| kubeconfig_path | ~/.kube/config |
| argocd_namespace | argocd |
| app_namespace | oncodepayment |
| app_repo_url | https://github.com/DNinjaDev07/oncodepayment.git |
| app_target_revision | master |

## DevOps Progress

Based on the implementation plan (DEVOPS_PLAN.md):

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Move legacy files to legacy/ | Done |
| 2 | Multi-stage Dockerfile | Done |
| 3 | PostgreSQL + Docker Compose | Done |
| 4 | Helm charts (10 templates) | Done |
| 5 | Terraform (platform infrastructure) | Done |
| 6 | GitHub Actions CI/CD pipeline | Not started |
| 7 | ArgoCD GitOps end-to-end flow | Partial |