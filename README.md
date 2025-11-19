# Microservices Architecture with NestJS, Kubernetes, and ArgoCD

This project contains three NestJS microservices deployed on Kubernetes using Helm charts, with CI/CD pipelines via GitLab CI and ArgoCD.

## Architecture

- **Service1**: NestJS microservice running on port 3001
- **Service2**: NestJS microservice running on port 3002
- **API Gateway**: NestJS API Gateway running on port 3000, routing requests to Service1 and Service2

## Prerequisites

- Node.js 20+
- Docker
- Kubernetes cluster (Minikube with 3 nodes)
- Helm 3.x
- ArgoCD installed in the cluster
- GitLab CI/CD (or GitLab account with CI/CD enabled)
- Docker Hub account (wrakash)

## Project Structure (Per-Service Architecture)

Each microservice is self-contained with its own Helm charts, CI/CD, and ArgoCD configuration:

```
.
├── service1/              # First microservice (self-contained)
│   ├── src/              # Source code
│   ├── helm/             # Helm chart for this service
│   ├── argocd/           # ArgoCD application manifest
│   ├── Dockerfile
│   ├── .gitlab-ci.yml    # Service-specific CI/CD pipeline
│   └── package.json
├── service2/              # Second microservice (self-contained)
│   ├── src/
│   ├── helm/
│   ├── argocd/
│   ├── Dockerfile
│   ├── .gitlab-ci.yml
│   └── package.json
└── api-gateway/           # API Gateway service (self-contained)
    ├── src/
    ├── helm/
    ├── argocd/
    ├── Dockerfile
    ├── .gitlab-ci.yml
    └── package.json
```

**Benefits of Per-Service Structure:**
- ✅ Each service is independently deployable
- ✅ Services can be managed by different teams
- ✅ Easy to extract services to separate repositories
- ✅ Independent CI/CD pipelines per service
- ✅ Better isolation and modularity

## Local Development

### Running Services Locally

```bash
# Service1
cd service1
npm install
npm run start:dev

# Service2
cd service2
npm install
npm run start:dev

# API Gateway
cd api-gateway
npm install
npm run start:dev
```

## Docker Build

### Build and Push Images

```bash
# Service1
cd service1
docker build -t wrakash/service1:latest .
docker push wrakash/service1:latest

# Service2
cd service2
docker build -t wrakash/service2:latest .
docker push wrakash/service2:latest

# API Gateway
cd api-gateway
docker build -t wrakash/api-gateway:latest .
docker push wrakash/api-gateway:latest
```

## Kubernetes Deployment

### Using Helm

```bash
# Deploy Service1
helm install service1 ./service1/helm

# Deploy Service2
helm install service2 ./service2/helm

# Deploy API Gateway
helm install api-gateway ./api-gateway/helm
```

### Using ArgoCD

1. Ensure ArgoCD is installed in your cluster:
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

2. Deploy each service independently using its own ArgoCD config:
```bash
# Deploy Service1 to its VM/cluster
kubectl apply -f service1/argocd/application.yaml

# Deploy Service2 to its VM/cluster
kubectl apply -f service2/argocd/application.yaml

# Deploy API Gateway to its VM/cluster
kubectl apply -f api-gateway/argocd/application.yaml
```

**Note:** Each service's ArgoCD application can target a different Kubernetes cluster/VM by updating the `destination.server` in each service's `argocd/application.yaml`.

## GitLab CI/CD Setup

Each service has its own `.gitlab-ci.yml` file for independent CI/CD pipelines.

1. Set the following CI/CD variables in GitLab:
   - `DOCKER_PASSWORD`: Your Docker Hub password or access token

2. Update the repository URL in ArgoCD application manifests:
   - Replace `https://github.com/your-org/your-repo.git` with your actual repository URL
   - Update paths in `service1/argocd/application.yaml`, `service2/argocd/application.yaml`, and `api-gateway/argocd/application.yaml`

3. Each service's pipeline will:
   - Build Docker image for that specific service
   - Push image to Docker Hub (wrakash registry)
   - ArgoCD will automatically sync and deploy changes

**Note:** Changes to one service only trigger that service's pipeline, providing better isolation and faster builds.

## Accessing Services

### Port Forwarding

```bash
# API Gateway
kubectl port-forward svc/api-gateway 3000:3000

# Service1
kubectl port-forward svc/service1 3001:3001

# Service2
kubectl port-forward svc/service2 3002:3002
```

### API Endpoints

- API Gateway: `http://localhost:3000`
- Service1 via Gateway: `http://localhost:3000/service1/data`
- Service2 via Gateway: `http://localhost:3000/service2/data`
- Health Check: `http://localhost:3000/health`

## Minikube Setup

Since you have a 3-node Minikube cluster:

```bash
# Verify nodes
kubectl get nodes

# Enable ingress (if needed)
minikube addons enable ingress

# Get service URLs
minikube service api-gateway --url
```

## Configuration

### Environment Variables

- `PORT`: Service port (default: 3000, 3001, 3002)
- `NODE_ENV`: Environment (production/development)
- `SERVICE1_URL`: Service1 URL for API Gateway (default: http://service1:3001)
- `SERVICE2_URL`: Service2 URL for API Gateway (default: http://service2:3002)

### Helm Values

Edit `helm/*/values.yaml` to customize:
- Replica count
- Resource limits
- Image tags
- Service types
- Ingress configuration

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Check Services
```bash
kubectl get svc
kubectl describe svc <service-name>
```

### ArgoCD Sync Issues
```bash
kubectl get applications -n argocd
argocd app get <app-name>
argocd app sync <app-name>
```

## License

MIT

