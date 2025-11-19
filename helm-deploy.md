# Helm Deployment Commands

## Prerequisites
Make sure you have:
- kubectl configured and connected to your Kubernetes cluster
- Helm 3.x installed
- Docker images pushed to registry (wrakash/sky-*)

## Deployment Commands

### 1. Deploy Service1

```bash
# Install/Upgrade Service1
helm upgrade --install service1 ./service1/helm \
  --namespace default \
  --create-namespace \
  --set image.repository=wrakash/sky-service1 \
  --set image.tag=1.0.0

# Or use values file with custom image tag
helm upgrade --install service1 ./service1/helm \
  --namespace default \
  --create-namespace \
  --set image.tag=1.0.0

# Or install from current directory (if running from root)
helm upgrade --install service1 service1/helm \
  --namespace default \
  --create-namespace \
  --set image.tag=1.0.0
```

### 2. Deploy Service2

```bash
# Install/Upgrade Service2
helm upgrade --install service2 ./service2/helm \
  --namespace default \
  --create-namespace \
  --set image.repository=wrakash/sky-service2 \
  --set image.tag=1.0.0

# Or use values file with custom image tag
helm upgrade --install service2 ./service2/helm \
  --namespace default \
  --create-namespace \
  --set image.tag=1.0.0
```

### 3. Deploy API Gateway

```bash
# Install/Upgrade API Gateway
helm upgrade --install api-gateway ./api-gateway/helm \
  --namespace default \
  --create-namespace \
  --set image.repository=wrakash/sky-gateway \
  --set image.tag=1.0.0

# Or use values file with custom image tag
helm upgrade --install api-gateway ./api-gateway/helm \
  --namespace default \
  --create-namespace \
  --set image.tag=1.0.0
```

## Complete Deployment (All Services)

```bash
# Deploy all services in sequence
helm upgrade --install service1 ./service1/helm \
  --namespace default \
  --create-namespace \
  --set image.tag=1.0.0

helm upgrade --install service2 ./service2/helm \
  --namespace default \
  --create-namespace \
  --set image.tag=1.0.0

helm upgrade --install api-gateway ./api-gateway/helm \
  --namespace default \
  --create-namespace \
  --set image.tag=1.0.0
```

## Using Custom Namespace

```bash
# Create a namespace first (optional)
kubectl create namespace microservices

# Deploy to custom namespace
helm upgrade --install service1 ./service1/helm \
  --namespace microservices \
  --set image.tag=1.0.0

helm upgrade --install service2 ./service2/helm \
  --namespace microservices \
  --set image.tag=1.0.0

helm upgrade --install api-gateway ./api-gateway/helm \
  --namespace microservices \
  --set image.tag=1.0.0
```

## Useful Management Commands

### Check Deployment Status
```bash
# List all Helm releases
helm list --namespace default

# Check specific release status
helm status service1 --namespace default
helm status service2 --namespace default
helm status api-gateway --namespace default
```

### View Deployed Resources
```bash
# View pods
kubectl get pods -n default

# View services
kubectl get svc -n default

# View deployments
kubectl get deployments -n default
```

### Upgrade to New Image Version
```bash
# Update image tag to new version (e.g., 1.0.1)
helm upgrade service1 ./service1/helm \
  --namespace default \
  --set image.tag=1.0.1

helm upgrade service2 ./service2/helm \
  --namespace default \
  --set image.tag=1.0.1

helm upgrade api-gateway ./api-gateway/helm \
  --namespace default \
  --set image.tag=1.0.1
```

### Uninstall Services
```bash
# Uninstall a specific service
helm uninstall service1 --namespace default
helm uninstall service2 --namespace default
helm uninstall api-gateway --namespace default

# Uninstall all services
helm uninstall service1 service2 api-gateway --namespace default
```

### Dry Run (Test Before Deploying)
```bash
# Test deployment without actually deploying
helm upgrade --install service1 ./service1/helm \
  --namespace default \
  --set image.tag=1.0.0 \
  --dry-run --debug
```

### View Generated Manifests
```bash
# See what Kubernetes resources will be created
helm template service1 ./service1/helm \
  --set image.tag=1.0.0

helm template service2 ./service2/helm \
  --set image.tag=1.0.0

helm template api-gateway ./api-gateway/helm \
  --set image.tag=1.0.0
```

## Notes

- `helm upgrade --install` will install if the release doesn't exist, or upgrade if it does
- Image repository is already set in values.yaml, so you only need to override the tag
- Default namespace is `default`, but you can specify any namespace
- Make sure your Kubernetes cluster has access to pull images from `wrakash/sky-*` registry
- If using private registry, you may need to create imagePullSecrets

