# Minimal Go Backend + Docker + Azure ACI via Terraform + CI/CD

## 1) Minimal Backend

Run locally:

```bash
go run .
# In another terminal
curl http://localhost:8080
```

Expected: `Hello from backend 👋`.

## 2) Dockerize and Run Locally

```bash
docker build -t my-backend:local .
docker run --rm -p 8080:8080 my-backend:local
# In another terminal
curl http://localhost:8080
```

## 3) Push Image to Azure Container Registry (ACR)

Create or use an existing ACR. With Terraform in this repo, ACR is created automatically. To push manually:

```bash
az acr login --name terralearnregistry01
docker tag my-backend:local terralearnregistry01.azurecr.io/my-backend:v1
docker push terralearnregistry01.azurecr.io/my-backend:v1
```

## 4) Terraform to Azure Container Instances

Prereqs: Azure subscription and CLI login.

```bash
cd infra
terraform init
terraform apply -auto-approve \
  -var "project_name=my-backend" \
  -var "location=southeastasia" \
  -var "acr_name=terralearnregistry01" \
  -var "image_tag=v1"
```

Outputs include `fqdn`. Test:

```bash
curl http://$(terraform output -raw fqdn):8080
```

## 5) CI/CD with GitHub Actions (ACR)

Create repository secrets:
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `ACR_USERNAME` (from ACR admin user)
- `ACR_PASSWORD` (from ACR admin password)

Update `ACR_NAME` and optionally `AZURE_LOCATION` in `.github/workflows/ci-cd.yml` env.

Pipeline:
- Builds and pushes image `v<run_number>` and `latest`
- Runs Terraform to deploy to ACI using the new tag

Push to `main` to trigger.


