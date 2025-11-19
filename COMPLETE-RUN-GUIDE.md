# 🚀 Complete Project Run Guide - Step by Step

This document provides a complete step-by-step guide to run the entire project and verify everything is working, including CI/CD.

---

## ✅ **STEP 1: Initial Setup (One-Time)**

### Prerequisites Check:
```powershell
# Check installed tools
node --version     # Should be 20+
npm --version      # Should be 10+
docker --version   # Docker Desktop should be running
kubectl version    # If using Kubernetes
helm version       # If using Helm
```

### Install Dependencies:
```powershell
# Service1
cd service1
npm install
npx prisma generate
npx prisma migrate dev

# Service2
cd ..\service2
npm install
npx prisma generate
npx prisma migrate dev

# API Gateway
cd ..\api-gateway
npm install
```

**✅ Status:** All dependencies installed ✓

---

## ✅ **STEP 2: Start Services Locally**

### Option A: Using PowerShell Script (Easiest)
```powershell
cd E:\kube
.\scripts\start-services.ps1
```

### Option B: Manual Start (3 Separate Terminals)

**Terminal 1 - Service1:**
```powershell
cd service1
npm run start:dev
```
**Expected:** `Service1 HTTP is running on port 3001`

**Terminal 2 - Service2:**
```powershell
cd service2
npm run start:dev
```
**Expected:** `Service2 is running on port 3002`

**Terminal 3 - API Gateway:**
```powershell
cd api-gateway
npm run start:dev
```
**Expected:** `API Gateway is running on port 3000`

### Option C: Using Background Jobs
```powershell
# Stop existing jobs first
Get-Job | Stop-Job; Get-Job | Remove-Job

# Start Service1
cd service1
Start-Job -Name "Service1" -ScriptBlock { Set-Location E:\kube\service1; npm run start:dev }

# Start Service2
cd ..\service2
Start-Job -Name "Service2" -ScriptBlock { Set-Location E:\kube\service2; npm run start:dev }

# Start API Gateway
cd ..\api-gateway
Start-Job -Name "APIGateway" -ScriptBlock { Set-Location E:\kube\api-gateway; npm run start:dev }

# Wait 30-40 seconds for services to start
Start-Sleep -Seconds 40
```

**✅ Status:** Services starting... (wait 30-40 seconds)

---

## ✅ **STEP 3: Verify Services Are Running**

### Quick Health Check:
```powershell
# Test each service
Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:3001/health" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:3002/health" -UseBasicParsing

# Or use curl (if available)
curl http://localhost:3000/health
curl http://localhost:3001/health
curl http://localhost:3002/health
```

### Expected Responses:
- **API Gateway:** `{"status":"ok","service":"api-gateway-service","timestamp":"..."}`
- **Service1:** `{"status":"ok"}`
- **Service2:** `{"status":"ok"}`

### Check Ports:
```powershell
netstat -ano | findstr ":3000 :3001 :3002"
```

### Check Background Jobs:
```powershell
Get-Job | Format-Table Id, Name, State
```

**✅ Status:** All services should respond with HTTP 200 ✓

---

## ✅ **STEP 4: Test API Gateway Routing**

### Test Service1 via Gateway:
```powershell
# Get users (should route to Service1)
Invoke-WebRequest -Uri "http://localhost:3000/api/users" -UseBasicParsing

# Or in browser: http://localhost:3000/api/users
```

### Test Service2 via Gateway:
```powershell
# Get payments (should route to Service2)
Invoke-WebRequest -Uri "http://localhost:3000/api/payments" -UseBasicParsing

# Or in browser: http://localhost:3000/api/payments
```

**✅ Status:** Gateway should successfully proxy requests ✓

---

## ✅ **STEP 5: Build Docker Images**

### Start Docker Desktop First!
```powershell
# Verify Docker is running
docker ps
```

### Build Images:
```powershell
# Service1
cd service1
docker build -t wrakash/sky-service1:1.0.0 .

# Service2
cd ..\service2
docker build -t wrakash/sky-service2:1.0.0 .

# API Gateway
cd ..\api-gateway
docker build -t wrakash/sky-gateway:1.0.0 .
```

### Verify Images Built:
```powershell
docker images | findstr "wrakash"
```

**✅ Status:** Docker images built successfully ✓

---

## ✅ **STEP 6: Push Docker Images (Optional)**

### Login to Docker Hub:
```powershell
docker login
# Enter username: wrakash
# Enter password: (from config.yaml)
```

### Push Images:
```powershell
docker push wrakash/sky-service1:1.0.0
docker push wrakash/sky-service2:1.0.0
docker push wrakash/sky-gateway:1.0.0
```

### Verify on Docker Hub:
- Visit: https://hub.docker.com/r/wrakash/sky-service1/tags
- Visit: https://hub.docker.com/r/wrakash/sky-service2/tags
- Visit: https://hub.docker.com/r/wrakash/sky-gateway/tags

**✅ Status:** Images pushed to Docker Hub ✓

---

## ✅ **STEP 7: Deploy to Kubernetes (If Using)**

### Check Kubernetes Connection:
```powershell
kubectl cluster-info
kubectl get nodes
```

### Deploy with Helm:
```powershell
# Service1
helm upgrade --install service1 .\service1\helm `
  --namespace default `
  --create-namespace `
  --set image.tag=1.0.0

# Service2
helm upgrade --install service2 .\service2\helm `
  --namespace default `
  --create-namespace `
  --set image.tag=1.0.0

# API Gateway
helm upgrade --install api-gateway .\api-gateway\helm `
  --namespace default `
  --create-namespace `
  --set image.tag=1.0.0
```

### Verify Deployment:
```powershell
kubectl get pods
kubectl get svc
kubectl get deployments
```

### Port Forward to Access:
```powershell
kubectl port-forward svc/api-gateway 3000:3000
# Then test: http://localhost:3000/health
```

**✅ Status:** Services deployed to Kubernetes ✓

---

## ✅ **STEP 8: Setup and Run CI/CD**

### Prerequisites:
1. **GitLab Account** with repository access
2. **Docker Hub Token** (from https://hub.docker.com/settings/security)
3. **GitHub Repositories** created:
   - `https://github.com/wrakash/sky-service1.git`
   - `https://github.com/wrakash/sky-service2.git`
   - `https://github.com/wrakash/sky-apigateway.git`

### Step 8.1: Configure GitLab CI/CD Variables

1. Go to your GitLab project → **Settings** → **CI/CD** → **Variables**
2. Add these variables:
   - `DOCKER_HUB_USER` = `wrakash`
   - `DOCKER_HUB_TOKEN` = (Your Docker Hub access token)

### Step 8.2: Push Code to GitLab

```powershell
# For each service (service1, service2, api-gateway)
cd service1
git init
git add .
git commit -m "Initial commit: Setup CI/CD"
git remote add origin <your-gitlab-repo-url>
git push -u origin main
```

### Step 8.3: Trigger CI/CD Pipeline

```powershell
# Make a small change
echo "// CI/CD Test" >> src/main.ts
git add .
git commit -m "test: trigger CI/CD pipeline"
git push origin main
```

### Step 8.4: Monitor Pipeline

1. Go to GitLab → **CI/CD** → **Pipelines**
2. Watch the pipeline:
   - ✅ **Test stage** runs automatically
   - ✅ **Build stage** runs automatically (builds Docker image)
   - ⏸️ **Deploy stages** are manual (you must trigger)

### Step 8.5: After Build Succeeds

1. In GitLab pipeline, click **"▶ Play"** on `update-helm-chart` job
2. This will:
   - Update `helm/values.yaml` with new image tag
   - Commit and push to GitHub repository
   - ArgoCD detects the change
   - ArgoCD auto-syncs the application

**✅ Status:** CI/CD pipeline running ✓

---

## ✅ **STEP 9: Setup ArgoCD (GitOps)**

### Step 9.1: Install ArgoCD (if not installed)
```powershell
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait 2-3 minutes for ArgoCD to start
kubectl get pods -n argocd -w
```

### Step 9.2: Configure GitHub Access
```powershell
cd scripts
.\configure-argocd-git.sh
```

Or manually:
```powershell
kubectl create secret generic github-creds `
  -n argocd `
  --from-literal=type=git `
  --from-literal=url=https://github.com/wrakash `
  --from-literal=username=wrakash `
  --from-literal=password=YOUR_GITHUB_PERSONAL_ACCESS_TOKEN
```

### Step 9.3: Apply ArgoCD Applications
```powershell
.\scripts\apply-argocd.sh
```

Or manually:
```powershell
kubectl apply -f service1\argocd\application.yaml
kubectl apply -f service2\argocd\application.yaml
kubectl apply -f api-gateway\argocd\application.yaml
```

### Step 9.4: Access ArgoCD UI
```powershell
.\scripts\access-argocd-ui.sh
```

Or manually:
```powershell
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Visit: https://localhost:8080
# Username: admin
# Password: (get with kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
```

### Step 9.5: Verify ArgoCD Status
```powershell
kubectl get applications -n argocd
```

**Expected:**
```
NAME          SYNC STATUS   HEALTH STATUS
api-gateway   Synced        Healthy
service1      Synced        Healthy
service2      Synced        Healthy
```

**✅ Status:** ArgoCD configured and syncing ✓

---

## ✅ **STEP 10: Complete Verification**

### Run Verification Script:
```powershell
.\scripts\verify-cicd-pipeline.sh
```

Or use the comprehensive script:
```powershell
.\scripts\run-and-verify.ps1
```

### Manual Verification Checklist:

#### ✅ Local Services:
- [ ] API Gateway responds: `http://localhost:3000/health`
- [ ] Service1 responds: `http://localhost:3001/health`
- [ ] Service2 responds: `http://localhost:3002/health`
- [ ] Gateway routes to Service1: `http://localhost:3000/api/users`
- [ ] Gateway routes to Service2: `http://localhost:3000/api/payments`

#### ✅ Docker:
- [ ] Images built: `docker images | findstr wrakash`
- [ ] Images pushed: Check Docker Hub
- [ ] Containers can run: `docker run -d -p 3002:3002 wrakash/sky-service2:1.0.0`

#### ✅ Kubernetes (if using):
- [ ] Pods running: `kubectl get pods`
- [ ] Services created: `kubectl get svc`
- [ ] Deployments healthy: `kubectl get deployments`

#### ✅ CI/CD:
- [ ] GitLab pipeline shows ✅ for test and build
- [ ] Docker images pushed to Docker Hub
- [ ] Helm chart updated in GitHub

#### ✅ ArgoCD (if using):
- [ ] ArgoCD pods running: `kubectl get pods -n argocd`
- [ ] Applications synced: `kubectl get applications -n argocd`
- [ ] ArgoCD UI accessible: `https://localhost:8080`

---

## 📊 **Quick Status Check Commands**

```powershell
# Service Health
Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:3001/health" -UseBasicParsing
Invoke-WebRequest -Uri "http://localhost:3002/health" -UseBasicParsing

# Background Jobs
Get-Job | Format-Table Id, Name, State

# Docker
docker ps
docker images | findstr wrakash

# Kubernetes
kubectl get pods
kubectl get svc
kubectl get applications -n argocd

# CI/CD Verification
.\scripts\verify-cicd-pipeline.sh
```

---

## 🆘 **Troubleshooting**

### Services Not Starting?
```powershell
# Check logs
Receive-Job -Name Service1 -Keep | Select-Object -Last 20
Receive-Job -Name Service2 -Keep | Select-Object -Last 20
Receive-Job -Name APIGateway -Keep | Select-Object -Last 20

# Restart services
Get-Job | Stop-Job; Get-Job | Remove-Job
.\scripts\start-services.ps1
```

### Port Already in Use?
```powershell
# Find process using port
netstat -ano | findstr ":3000"
# Kill process (replace PID with actual process ID)
taskkill /PID <PID> /F
```

### Docker Not Working?
```powershell
# Start Docker Desktop first!
# Then verify
docker ps
```

### Kubernetes Connection Issues?
```powershell
kubectl cluster-info
# If using Minikube: minikube start
```

### CI/CD Pipeline Failing?
- Check GitLab → CI/CD → Pipelines → Click failed job → View logs
- Verify `DOCKER_HUB_TOKEN` is set in GitLab CI/CD variables
- Ensure code is pushed to GitLab repository

### ArgoCD Not Syncing?
```powershell
# Check application status
kubectl get applications -n argocd
kubectl describe application api-gateway -n argocd

# Force sync
kubectl patch application api-gateway -n argocd --type json `
  -p='[{"op": "replace", "path": "/operation", "value": {"initiatedBy": {"username": "admin"},"sync": {"revision": "HEAD"}}}]'
```

---

## 📝 **Summary**

### ✅ **What We've Done:**
1. ✅ Installed all dependencies
2. ✅ Started all services locally
3. ✅ Verified services are responding
4. ✅ Built Docker images
5. ✅ (Optional) Pushed to Docker Hub
6. ✅ (Optional) Deployed to Kubernetes
7. ✅ (Optional) Set up CI/CD pipeline
8. ✅ (Optional) Configured ArgoCD GitOps

### 🎯 **Success Indicators:**
- All health endpoints return `{"status":"ok"}`
- GitLab pipeline shows ✅ for test and build
- Docker images exist on Docker Hub
- ArgoCD shows all apps as `Synced` and `Healthy`
- Kubernetes pods are `Running` with `Ready: 1/1`

### 📚 **Next Steps:**
- Make code changes and push to trigger CI/CD
- Monitor ArgoCD UI for automatic deployments
- Scale services using Kubernetes HPA
- Add more microservices following the same pattern

---

**Last Updated:** Based on complete project setup and verification
**Status:** All services ready for development and deployment! 🚀

