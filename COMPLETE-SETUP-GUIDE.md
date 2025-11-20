# Complete Setup Guide: Microservices with Docker, Kubernetes, Helm, Minikube, GitLab CI/CD, and ArgoCD

This guide will walk you through setting up and running your microservices project from scratch.

---

## 📋 Table of Contents

1. [Prerequisites](#1-prerequisites)
2. [Step 1: Install Required Tools](#step-1-install-required-tools)
3. [Step 2: Set Up Minikube](#step-2-set-up-minikube)
4. [Step 3: Build Docker Images Locally](#step-3-build-docker-images-locally)
5. [Step 4: Push Images to Docker Hub](#step-4-push-images-to-docker-hub)
6. [Step 5: Deploy to Kubernetes with Helm](#step-5-deploy-to-kubernetes-with-helm)
7. [Step 6: Set Up GitLab CI/CD](#step-6-set-up-gitlab-cicd)
8. [Step 7: Install and Configure ArgoCD](#step-7-install-and-configure-argocd)
9. [Step 8: Deploy with ArgoCD](#step-8-deploy-with-argocd)
10. [Step 9: Verify Everything Works](#step-9-verify-everything-works)
11. [Troubleshooting](#troubleshooting)

---

## 1. Prerequisites

Before starting, make sure you have:
- ✅ A computer with Windows, macOS, or Linux
- ✅ Administrator/root access
- ✅ Internet connection
- ✅ Docker Hub account (we'll use `wrakash` as the username)
- ✅ GitLab account (or GitHub if using GitHub Actions)
- ✅ Basic knowledge of command line

---

## Step 1: Install Required Tools

### 1.1 Install Docker

**Windows:**
1. Download Docker Desktop from: https://www.docker.com/products/docker-desktop
2. Install and restart your computer
3. Open Docker Desktop and make sure it's running

**macOS:**
```bash
# Using Homebrew
brew install --cask docker
# Or download from docker.com
```

**Linux (Ubuntu/Debian):**
```bash
# Update package index
sudo apt-get update

# Install Docker
sudo apt-get install -y docker.io

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group (to run without sudo)
sudo usermod -aG docker $USER
# Log out and log back in for this to take effect
```

**Verify Docker installation:**
```bash
docker --version
docker run hello-world
```

### 1.2 Install Minikube

**Windows:**
```powershell
# Using Chocolatey
choco install minikube

# Or download from: https://minikube.sigs.k8s.io/docs/start/
```

**macOS:**
```bash
# Using Homebrew
brew install minikube
```

**Linux:**
```bash
# Download and install
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

**Verify Minikube installation:**
```bash
minikube version
```

### 1.3 Install kubectl (Kubernetes CLI)

**Windows:**
```powershell
# Using Chocolatey
choco install kubernetes-cli

# Or download from: https://kubernetes.io/docs/tasks/tools/
```

**macOS:**
```bash
# Using Homebrew
brew install kubectl
```

**Linux:**
```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

**Verify kubectl installation:**
```bash
kubectl version --client
```

### 1.4 Install Helm

**Windows:**
```powershell
# Using Chocolatey
choco install kubernetes-helm

# Or download from: https://helm.sh/docs/intro/install/
```

**macOS:**
```bash
# Using Homebrew
brew install helm
```

**Linux:**
```bash
# Download and install
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

**Verify Helm installation:**
```bash
helm version
```

### 1.5 Install Node.js (for local development)

**Windows/macOS/Linux:**
1. Download from: https://nodejs.org/ (version 20 or higher)
2. Install and verify:
```bash
node --version
npm --version
```

---

## Step 2: Set Up Minikube

### 2.1 Start Minikube

**For Windows (PowerShell):**
```powershell
# Start Minikube with 3 nodes (as per your setup)
minikube start --nodes 3

# If you need more resources, you can specify:
minikube start --nodes 3 --memory 4096 --cpus 2
```

**For macOS/Linux:**
```bash
# Start Minikube with 3 nodes
minikube start --nodes 3

# With more resources:
minikube start --nodes 3 --memory 4096 --cpus 2
```

**Note:** The first time you start Minikube, it will download a VM image. This may take a few minutes.

### 2.2 Verify Minikube is Running

```bash
# Check Minikube status
minikube status

# Check Kubernetes nodes
kubectl get nodes

# You should see 3 nodes (minikube, minikube-m02, minikube-m03)
```

### 2.3 Enable Minikube Addons

```bash
# Enable ingress (for API Gateway)
minikube addons enable ingress

# Enable metrics server (for HPA - Horizontal Pod Autoscaler)
minikube addons enable metrics-server

# List all addons
minikube addons list
```

### 2.4 Configure Docker to Use Minikube's Docker

```bash
# Point Docker to Minikube's Docker daemon
eval $(minikube docker-env)

# For Windows PowerShell:
minikube docker-env | Invoke-Expression

# Verify you're using Minikube's Docker
docker ps
```

**Important:** You need to run this command in every new terminal window where you want to build Docker images for Minikube.

---

## Step 3: Build Docker Images Locally

### 3.1 Navigate to Your Project

```bash
# Navigate to your project directory
cd E:\kube
# Or wherever your project is located
```

### 3.2 Build Service1 Image

```bash
# Navigate to service1 directory
cd service1

# Build Docker image
docker build -t service1:latest .

# Verify image was created
docker images | grep service1
```

### 3.3 Build Service2 Image

```bash
# Navigate to service2 directory
cd ../service2

# Build Docker image
docker build -t service2:latest .

# Verify image was created
docker images | grep service2
```

### 3.4 Build API Gateway Image

```bash
# Navigate to api-gateway directory
cd ../api-gateway

# Build Docker image
docker build -t api-gateway:latest .

# Verify image was created
docker images | grep api-gateway
```

### 3.5 Tag Images for Docker Hub (Optional - for pushing later)

```bash
# Tag images with your Docker Hub username
docker tag service1:latest wrakash/service1:latest
docker tag service2:latest wrakash/service2:latest
docker tag api-gateway:latest wrakash/api-gateway:latest

# Verify tags
docker images | grep wrakash
```

---

## Step 4: Push Images to Docker Hub

### 4.1 Login to Docker Hub

```bash
# Login to Docker Hub
docker login

# Enter your Docker Hub username: wrakash
# Enter your Docker Hub password: (your password)
```

### 4.2 Push Images

```bash
# Push Service1
docker push wrakash/service1:latest

# Push Service2
docker push wrakash/service2:latest

# Push API Gateway
docker push wrakash/api-gateway:latest
```

**Note:** If you haven't created these repositories on Docker Hub, Docker will create them automatically when you push.

---

## Step 5: Deploy to Kubernetes with Helm

### 5.1 Update Helm Values (if needed)

Check and update the image names in Helm values files:

**For Service1:**
```bash
# Edit service1/helm/values.yaml
# Make sure image.repository is set correctly
```

**For Service2:**
```bash
# Edit service2/helm/values.yaml
# Make sure image.repository is set correctly
```

**For API Gateway:**
```bash
# Edit api-gateway/helm/values.yaml
# Make sure image.repository is set correctly
```

### 5.2 Deploy Service1

```bash
# Navigate to project root
cd E:\kube

# Deploy Service1 using Helm
helm install service1 ./service1/helm

# Or with custom values
helm install service1 ./service1/helm -f service1/helm/values.yaml

# Check deployment status
kubectl get pods -l app=service1
kubectl get svc service1
```

### 5.3 Deploy Service2

```bash
# Deploy Service2
helm install service2 ./service2/helm

# Check deployment status
kubectl get pods -l app=service2
kubectl get svc service2
```

### 5.4 Deploy API Gateway

```bash
# Deploy API Gateway
helm install api-gateway ./api-gateway/helm

# Check deployment status
kubectl get pods -l app=api-gateway
kubectl get svc api-gateway
```

### 5.5 Verify All Services are Running

```bash
# Check all pods
kubectl get pods

# Check all services
kubectl get svc

# Check all deployments
kubectl get deployments

# View detailed status of a pod
kubectl describe pod <pod-name>

# View logs of a pod
kubectl logs <pod-name>
```

### 5.6 Access Services via Port Forwarding

```bash
# Port forward API Gateway
kubectl port-forward svc/api-gateway 3000:3000

# In another terminal, port forward Service1
kubectl port-forward svc/service1 3001:3001

# In another terminal, port forward Service2
kubectl port-forward svc/service2 3002:3002
```

**Test the services:**
- API Gateway: http://localhost:3000
- Service1 Health: http://localhost:3000/service1/health
- Service2 Health: http://localhost:3000/service2/health

---

## Step 6: Set Up GitLab CI/CD

### 6.1 Create GitLab Repository

1. Go to GitLab.com (or your GitLab instance)
2. Create a new project/repository
3. Copy the repository URL

### 6.2 Push Code to GitLab

```bash
# Navigate to your project
cd E:\kube

# Initialize git (if not already done)
git init

# Add GitLab remote
git remote add origin https://gitlab.com/your-username/your-repo-name.git

# Add all files
git add .

# Commit
git commit -m "Initial commit: Microservices with Helm and ArgoCD"

# Push to GitLab
git push -u origin main
```

### 6.3 Configure GitLab CI/CD Variables

1. Go to your GitLab project
2. Navigate to **Settings** → **CI/CD** → **Variables**
3. Click **Expand** on "Variables"
4. Add the following variables:

| Key | Value | Protected | Masked |
|-----|-------|-----------|--------|
| `DOCKER_HUB_USER` | `wrakash` | No | No |
| `DOCKER_HUB_TOKEN` | `your-docker-hub-token` | Yes | Yes |
| `CI_REGISTRY_USER` | `wrakash` | No | No |
| `CI_REGISTRY_PASSWORD` | `your-docker-hub-password` | Yes | Yes |

**To get Docker Hub token:**
1. Go to Docker Hub → Account Settings → Security
2. Click "New Access Token"
3. Copy the token and use it as `DOCKER_HUB_TOKEN`

### 6.4 Update GitLab CI Files

Each service has its own `.gitlab-ci.yml` file. Make sure they're configured correctly:

**Check api-gateway/.gitlab-ci.yml:**
- Verify `IMAGE_NAME` is set to `wrakash/api-gateway` (or your Docker Hub username)
- Verify `HELM_CHART_PATH` points to `helm`

**Check service1/.gitlab-ci.yml:**
- Verify `IMAGE_NAME` is set to `wrakash/service1`
- Verify `HELM_CHART_PATH` points to `helm`

**Check service2/.gitlab-ci.yml:**
- Verify `IMAGE_NAME` is set to `wrakash/service2`
- Verify `HELM_CHART_PATH` points to `helm`

### 6.5 Test GitLab CI/CD Pipeline

1. Make a small change to any service
2. Commit and push:
```bash
git add .
git commit -m "Test CI/CD pipeline"
git push
```

3. Go to GitLab → **CI/CD** → **Pipelines**
4. Watch the pipeline run
5. Verify the Docker images are built and pushed to Docker Hub

---

## Step 7: Install and Configure ArgoCD

### 7.1 Install ArgoCD in Minikube

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready (this may take 2-3 minutes)
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

### 7.2 Check ArgoCD Pods

```bash
# Check if ArgoCD pods are running
kubectl get pods -n argocd

# You should see pods like:
# - argocd-application-controller-xxx
# - argocd-dex-server-xxx
# - argocd-redis-xxx
# - argocd-repo-server-xxx
# - argocd-server-xxx
```

### 7.3 Access ArgoCD UI

**Option 1: Port Forward (Recommended for local testing)**

```bash
# Port forward ArgoCD server
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Access ArgoCD UI at: https://localhost:8080
# (Accept the self-signed certificate warning)
```

**Option 2: Using Minikube Service**

```bash
# Change ArgoCD server service to NodePort
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'

# Get the service URL
minikube service argocd-server -n argocd --url
```

### 7.4 Get ArgoCD Admin Password

```bash
# Get the default admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# For Windows PowerShell:
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

**Login to ArgoCD:**
- Username: `admin`
- Password: (the password from above)

### 7.5 Install ArgoCD CLI (Optional but Recommended)

**Windows:**
```powershell
# Using Chocolatey
choco install argocd

# Or download from: https://argo-cd.readthedocs.io/en/stable/cli_installation/
```

**macOS:**
```bash
# Using Homebrew
brew install argocd
```

**Linux:**
```bash
# Download ArgoCD CLI
curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```

**Login via CLI:**
```bash
# Login to ArgoCD
argocd login localhost:8080

# Enter username: admin
# Enter password: (the password from step 7.4)
```

---

## Step 8: Deploy with ArgoCD

### 8.1 Update ArgoCD Application Manifests

Before deploying, update the repository URLs in ArgoCD application files:

**For api-gateway/argocd/application.yaml:**
```yaml
spec:
  source:
    repoURL: https://gitlab.com/your-username/your-repo-name.git  # Update this
    targetRevision: HEAD
    path: api-gateway/helm
```

**For service1/argocd/application.yaml:**
```yaml
spec:
  source:
    repoURL: https://gitlab.com/your-username/your-repo-name.git  # Update this
    targetRevision: HEAD
    path: service1/helm
```

**For service2/argocd/application.yaml:**
```yaml
spec:
  source:
    repoURL: https://gitlab.com/your-username/your-repo-name.git  # Update this
    targetRevision: HEAD
    path: service2/helm
```

### 8.2 Configure Git Repository Access in ArgoCD

**Via UI:**
1. Go to ArgoCD UI → **Settings** → **Repositories**
2. Click **Connect Repo**
3. Enter:
   - **Type:** `git`
   - **Repository URL:** `https://gitlab.com/your-username/your-repo-name.git`
   - **Username:** (your GitLab username)
   - **Password:** (your GitLab personal access token)

**Via CLI:**
```bash
# Add GitLab repository to ArgoCD
argocd repo add https://gitlab.com/your-username/your-repo-name.git \
  --username your-gitlab-username \
  --password your-gitlab-token \
  --type git

# Verify repository is added
argocd repo list
```

**To create GitLab Personal Access Token:**
1. Go to GitLab → **Settings** → **Access Tokens**
2. Create token with `read_repository` scope
3. Copy the token

### 8.3 Deploy Services with ArgoCD

**Option 1: Via UI**
1. Go to ArgoCD UI
2. Click **New App**
3. Fill in:
   - **Application Name:** `service1`
   - **Project Name:** `default`
   - **Sync Policy:** `Automatic`
   - **Repository URL:** `https://gitlab.com/your-username/your-repo-name.git`
   - **Path:** `service1/helm`
   - **Cluster URL:** `https://kubernetes.default.svc`
   - **Namespace:** `default`
4. Click **Create**
5. Repeat for `service2` and `api-gateway`

**Option 2: Via CLI**
```bash
# Deploy Service1
kubectl apply -f service1/argocd/application.yaml

# Deploy Service2
kubectl apply -f service2/argocd/application.yaml

# Deploy API Gateway
kubectl apply -f api-gateway/argocd/application.yaml
```

### 8.4 Verify ArgoCD Applications

```bash
# List all ArgoCD applications
kubectl get applications -n argocd

# Or via CLI
argocd app list

# Get detailed status
argocd app get service1
argocd app get service2
argocd app get api-gateway

# View application in UI
# Go to ArgoCD UI and click on each application
```

### 8.5 Sync Applications (if needed)

```bash
# Sync an application manually
argocd app sync service1
argocd app sync service2
argocd app sync api-gateway

# Or sync all
argocd app sync --all
```

---

## Step 9: Verify Everything Works

### 9.1 Check All Pods are Running

```bash
# Check all pods in default namespace
kubectl get pods

# Check pods in all namespaces
kubectl get pods --all-namespaces

# All pods should be in "Running" status
```

### 9.2 Check All Services

```bash
# Check services
kubectl get svc

# You should see:
# - service1
# - service2
# - api-gateway
```

### 9.3 Test API Gateway

```bash
# Port forward API Gateway
kubectl port-forward svc/api-gateway 3000:3000

# In another terminal, test endpoints:
curl http://localhost:3000/health
curl http://localhost:3000/service1/health
curl http://localhost:3000/service2/health
```

### 9.4 Test via Browser

1. Port forward API Gateway:
```bash
kubectl port-forward svc/api-gateway 3000:3000
```

2. Open browser and visit:
   - http://localhost:3000
   - http://localhost:3000/health
   - http://localhost:3000/service1/health
   - http://localhost:3000/service2/health

### 9.5 Check ArgoCD Sync Status

```bash
# Check application health
argocd app get service1
argocd app get service2
argocd app get api-gateway

# All should show "Healthy" and "Synced"
```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. Pods are not starting

```bash
# Check pod status
kubectl get pods

# Describe pod to see errors
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Common issues:
# - Image pull errors: Check image name and Docker Hub credentials
# - Resource limits: Check if you have enough resources
# - Configuration errors: Check Helm values
```

#### 2. Cannot connect to services

```bash
# Check if services are created
kubectl get svc

# Check service endpoints
kubectl get endpoints

# Verify pods have correct labels
kubectl get pods --show-labels
kubectl get svc service1 -o yaml  # Check selector matches pod labels
```

#### 3. ArgoCD cannot sync

```bash
# Check ArgoCD application status
argocd app get <app-name>

# Check repository connection
argocd repo list

# Test repository access
argocd repo get <repo-url>

# Common issues:
# - Repository not accessible: Check credentials
# - Wrong path: Verify path in application.yaml
# - Branch not found: Check targetRevision
```

#### 4. Docker build fails

```bash
# Check Docker is running
docker ps

# For Minikube, make sure you're using Minikube's Docker
eval $(minikube docker-env)

# Check Dockerfile syntax
docker build -t test-image .

# Check for network issues
docker pull node:20-alpine
```

#### 5. Minikube issues

```bash
# Restart Minikube
minikube stop
minikube start --nodes 3

# Check Minikube status
minikube status

# View Minikube logs
minikube logs

# Delete and recreate (last resort)
minikube delete
minikube start --nodes 3
```

#### 6. Helm deployment fails

```bash
# Check Helm chart syntax
helm lint ./service1/helm

# Dry run to see what will be deployed
helm install service1 ./service1/helm --dry-run --debug

# Check existing releases
helm list

# Uninstall if needed
helm uninstall service1
```

#### 7. Port forwarding not working

```bash
# Check if service exists
kubectl get svc api-gateway

# Check if pods are running
kubectl get pods -l app=api-gateway

# Try different port
kubectl port-forward svc/api-gateway 8080:3000

# Check if port is already in use
netstat -an | grep 3000  # Linux/macOS
netstat -an | findstr 3000  # Windows
```

### Useful Commands Reference

```bash
# Kubernetes
kubectl get pods
kubectl get svc
kubectl get deployments
kubectl get ingress
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- /bin/sh

# Helm
helm list
helm status <release-name>
helm uninstall <release-name>
helm upgrade <release-name> <chart-path>

# ArgoCD
argocd app list
argocd app get <app-name>
argocd app sync <app-name>
argocd app delete <app-name>

# Minikube
minikube status
minikube service list
minikube service <service-name> --url
minikube dashboard

# Docker
docker images
docker ps
docker build -t <image-name> .
docker push <image-name>
```

---

## 🎉 Congratulations!

You've successfully set up a complete microservices architecture with:
- ✅ Docker containerization
- ✅ Kubernetes orchestration with Minikube
- ✅ Helm for package management
- ✅ GitLab CI/CD for automated builds
- ✅ ArgoCD for GitOps deployment

### Next Steps

1. **Monitor your services:**
   - Set up monitoring with Prometheus and Grafana
   - Configure alerting

2. **Scale your services:**
   - Adjust replica counts in Helm values
   - Use HPA (Horizontal Pod Autoscaler) for automatic scaling

3. **Improve security:**
   - Use Kubernetes secrets for sensitive data
   - Implement network policies
   - Use TLS/SSL certificates

4. **Add more features:**
   - Implement service mesh (Istio/Linkerd)
   - Add distributed tracing
   - Set up centralized logging

---

## 📚 Additional Resources

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Documentation](https://helm.sh/docs/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [Docker Documentation](https://docs.docker.com/)
- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)

---

**Need Help?** Check the troubleshooting section or review the logs using the commands above.

