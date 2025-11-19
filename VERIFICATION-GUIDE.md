# 🔍 Complete Verification Guide: How to Check if Everything is Running & CI/CD Status

This guide covers:
1. ✅ How to verify all services are running correctly
2. 🔄 How to run/use CI/CD pipeline
3. 📊 How to check if CI/CD is working

---

## 📋 Table of Contents
1. [Verifying Services are Running](#1-verifying-services-are-running)
2. [Running CI/CD Pipeline](#2-running-cicd-pipeline)
3. [Checking CI/CD Status](#3-checking-cicd-status)
4. [Complete Health Check Checklist](#4-complete-health-check-checklist)

---

## 1️⃣ Verifying Services are Running

### A. Local Development (Node.js)

#### Step 1: Check if services are running
```bash
# Check if ports are in use
# Windows PowerShell
netstat -ano | findstr :3000
netstat -ano | findstr :3001
netstat -ano | findstr :3002

# Linux/Mac
lsof -i :3000
lsof -i :3001
lsof -i :3002
```

#### Step 2: Test Health Endpoints
```bash
# Test API Gateway
curl http://localhost:3000/health
# Expected: {"status":"ok","service":"api-gateway-service","timestamp":"..."}

# Test Service1
curl http://localhost:3001/health
# Expected: {"status":"ok"}

# Test Service2
curl http://localhost:3002/health
# Expected: {"status":"ok"}
```

#### Step 3: Test API Gateway Routing
```bash
# Test root endpoint
curl http://localhost:3000/
# Expected: {"message":"API Gateway is running...","version":"1.0.1",...}

# Test Service1 via Gateway
curl http://localhost:3000/api/users
# Should proxy to Service1

# Test Service2 via Gateway
curl http://localhost:3000/api/payments
# Should proxy to Service2
```

#### Step 4: Check Service Logs
```bash
# Each service should show:
# - "Service is running on port XXXX"
# - No error messages
# - Successful startup messages
```

---

### B. Docker Containers

#### Step 1: Check Container Status
```bash
docker ps
# Should show 3 running containers:
# - api-gateway (port 3000)
# - service1 (ports 3001, 3003)
# - service2 (port 3002)
```

#### Step 2: Check Container Logs
```bash
# API Gateway
docker logs api-gateway
# Should show: "API Gateway is running on port 3000"

# Service1
docker logs service1
# Should show: "Service1 HTTP is running on port 3001"
# Should show: "Service1 TCP microservice is running on port: 3003"

# Service2
docker logs service2
# Should show: "Service2 is running on port 3002"
```

#### Step 3: Test from Inside Containers
```bash
# Test API Gateway container
docker exec api-gateway curl http://localhost:3000/health

# Test Service1 container
docker exec service1 curl http://localhost:3001/health

# Test Service2 container
docker exec service2 curl http://localhost:3002/health
```

---

### C. Kubernetes Deployment

#### Step 1: Check Pod Status
```bash
kubectl get pods
# All pods should show STATUS: Running
# All pods should show READY: 1/1

# Detailed view
kubectl get pods -o wide
```

#### Step 2: Check Service Status
```bash
kubectl get svc
# Should show:
# - api-gateway (ClusterIP or LoadBalancer)
# - service1 (ClusterIP)
# - service2 (ClusterIP)
```

#### Step 3: Check Deployment Status
```bash
kubectl get deployments
# All deployments should show:
# - READY: 1/1
# - UP-TO-DATE: 1
# - AVAILABLE: 1

# Check rollout status
kubectl rollout status deployment/api-gateway
kubectl rollout status deployment/service1
kubectl rollout status deployment/service2
```

#### Step 4: Port Forward and Test
```bash
# Terminal 1: Port forward API Gateway
kubectl port-forward svc/api-gateway 3000:3000

# Terminal 2: Test health
curl http://localhost:3000/health

# Test Service1
kubectl port-forward svc/service1 3001:3001
curl http://localhost:3001/health

# Test Service2
kubectl port-forward svc/service2 3002:3002
curl http://localhost:3002/health
```

#### Step 5: Check Pod Logs
```bash
# Get pod names
kubectl get pods

# Check logs (replace <pod-name> with actual pod name)
kubectl logs <api-gateway-pod-name>
kubectl logs <service1-pod-name>
kubectl logs <service2-pod-name>

# Follow logs in real-time
kubectl logs -f <pod-name>

# Check logs for specific container (if multiple containers)
kubectl logs <pod-name> -c <container-name>
```

#### Step 6: Describe Resources for Detailed Info
```bash
# Check pod details
kubectl describe pod <pod-name>

# Check service details
kubectl describe svc api-gateway
kubectl describe svc service1
kubectl describe svc service2

# Check deployment details
kubectl describe deployment api-gateway
```

---

## 2️⃣ Running CI/CD Pipeline

### Prerequisites Setup

#### Step 1: Configure GitLab CI/CD Variables
Go to your GitLab project → Settings → CI/CD → Variables and add:

**Required Variables:**
- `DOCKER_HUB_USER`: `wrakash`
- `DOCKER_HUB_TOKEN`: Your Docker Hub access token (get from https://hub.docker.com/settings/security)

**Optional Variables:**
- `KUBECONFIG`: Base64-encoded kubeconfig (if using direct Helm deployment)
- `CI_REGISTRY_USER`: If using GitLab Container Registry
- `CI_REGISTRY_PASSWORD`: If using GitLab Container Registry

#### Step 2: Push Code to GitLab
```bash
# For each service (service1, service2, api-gateway)
cd service1  # or service2, api-gateway
git init
git add .
git commit -m "Initial commit: Setup CI/CD"
git remote add origin <your-gitlab-repo-url>
git push -u origin main
```

---

### How CI/CD Pipeline Works

Each service has a `.gitlab-ci.yml` with 3 stages:

1. **Test Stage** (Automatic on push to main/master/develop)
   - Runs `npm ci`
   - Runs `npm run lint`
   - Runs `npm run test`
   - Generates Prisma client

2. **Build Stage** (Automatic on push to main/master/develop)
   - Builds Docker image
   - Tags image with commit SHA and `latest`
   - Pushes to Docker Hub (wrakash/sky-*)

3. **Deploy Stage** (Manual - you must trigger)
   - **Option A:** Direct Helm deployment (if KUBECONFIG is set)
   - **Option B:** Update Helm chart values.yaml and push to GitHub (for ArgoCD)

---

### Running the CI/CD Pipeline

#### Method 1: Automatic Trigger (Test & Build)

**Step 1: Push Code to GitLab**
```bash
cd service1  # or any service
echo "// Test change" >> src/main.ts
git add .
git commit -m "test: trigger CI/CD pipeline"
git push origin main
```

**Step 2: Check Pipeline Status**
1. Go to GitLab project → CI/CD → Pipelines
2. You'll see a pipeline running with:
   - ✅ Test job (automatic)
   - ✅ Build job (automatic)
   - ⏸️ Deploy jobs (manual - waiting for you)

**Step 3: Verify Test & Build Stages**
- ✅ Green checkmark = Success
- ❌ Red X = Failed (check logs)
- ⏸️ Blue pause = Waiting (manual job)

#### Method 2: Manual Deployment Options

**Option A: Update Helm Chart for ArgoCD (Recommended)**

After build succeeds, trigger the `update-helm-chart` job:

1. Go to GitLab → CI/CD → Pipelines
2. Click on the running pipeline
3. Click "▶ Play" button on `update-helm-chart` job
4. This will:
   - Update `helm/values.yaml` with new image tag
   - Commit and push to GitHub repository
   - ArgoCD will detect the change and auto-sync

**Option B: Direct Helm Deployment**

1. Ensure `KUBECONFIG` variable is set in GitLab CI/CD variables
2. Go to GitLab → CI/CD → Pipelines
3. Click "▶ Play" on `deploy` job
4. This will deploy directly to Kubernetes using Helm

---

### Triggering CI/CD Pipeline Workflow

**Complete Workflow Example:**

```bash
# 1. Make a code change
cd service1
echo "console.log('New version');" >> src/main.ts

# 2. Commit and push
git add .
git commit -m "feat: add new feature"
git push origin main

# 3. Watch pipeline in GitLab
# - Test stage runs automatically ✅
# - Build stage runs automatically ✅
# - Docker image is built and pushed to Docker Hub ✅

# 4. After build succeeds, manually trigger:
# - Click "update-helm-chart" job → Play
# - This updates GitHub repo with new image tag

# 5. ArgoCD detects change in GitHub
# - Auto-syncs the application
# - Deploys new version to Kubernetes

# 6. Verify deployment
kubectl get pods
kubectl logs <new-pod-name>
curl http://localhost:3000/health  # (after port-forward)
```

---

## 3️⃣ Checking CI/CD Status

### A. Using Verification Script (Recommended)

```bash
cd scripts
./verify-cicd-pipeline.sh
```

This script checks:
- ✅ Kubernetes cluster connectivity
- ✅ ArgoCD installation and pod status
- ✅ GitHub credentials in ArgoCD
- ✅ ArgoCD applications sync status
- ✅ CI/CD configuration files
- ✅ Dockerfiles existence
- ✅ Helm charts existence

**Expected Output:**
```
🔍 Verifying CI/CD Pipeline Configuration...

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1️⃣  Kubernetes Cluster Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ Kubernetes cluster is accessible

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
2️⃣  ArgoCD Installation Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ ArgoCD namespace exists
✓ All ArgoCD pods are running (7/7)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
3️⃣  GitHub Repository Access
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ GitHub credentials secret exists in ArgoCD

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
4️⃣  ArgoCD Applications Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  api-gateway: Synced | Healthy
  service1: Synced | Healthy
  service2: Synced | Healthy

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
5️⃣  GitLab CI/CD Configuration Files
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ service1/.gitlab-ci.yml exists
✓ service2/.gitlab-ci.yml exists
✓ api-gateway/.gitlab-ci.yml exists

...
```

---

### B. Manual CI/CD Checks

#### Check 1: GitLab Pipeline Status
```bash
# Via GitLab Web UI:
1. Go to your GitLab project
2. Click "CI/CD" → "Pipelines"
3. Check latest pipeline status:
   - ✅ Green = Success
   - ❌ Red = Failed (click to see logs)
   - ⏸️ Blue = Running
   - ⏸️ Gray = Manual (waiting for trigger)
```

**Via GitLab CLI (if installed):**
```bash
# List pipelines
glab ci list

# View pipeline details
glab ci view <pipeline-id>

# View job logs
glab ci trace <job-id>
```

#### Check 2: Docker Hub Images
```bash
# Check if images exist on Docker Hub
# Visit: https://hub.docker.com/r/wrakash/sky-service1/tags
# Visit: https://hub.docker.com/r/wrakash/sky-service2/tags
# Visit: https://hub.docker.com/r/wrakash/sky-gateway/tags

# Or via Docker CLI
docker pull wrakash/sky-service1:latest
docker pull wrakash/sky-service2:latest
docker pull wrakash/sky-gateway:latest
```

#### Check 3: ArgoCD Applications Status
```bash
# List all ArgoCD applications
kubectl get applications -n argocd

# Expected output:
# NAME          SYNC STATUS   HEALTH STATUS
# api-gateway   Synced        Healthy
# service1      Synced        Healthy
# service2      Synced        Healthy

# Detailed status for each app
kubectl get application api-gateway -n argocd -o yaml

# Get sync status
kubectl get application api-gateway -n argocd -o jsonpath='{.status.sync.status}'
# Expected: "Synced"

# Get health status
kubectl get application api-gateway -n argocd -o jsonpath='{.status.health.status}'
# Expected: "Healthy"

# Check for errors
kubectl get application api-gateway -n argocd -o jsonpath='{.status.conditions[*].message}'
```

#### Check 4: ArgoCD UI (Visual Check)
```bash
# Access ArgoCD UI
cd scripts
./access-argocd-ui.sh

# Or manually:
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Open browser: https://localhost:8080
# Login with:
#   Username: admin
#   Password: (get from kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# In ArgoCD UI, you should see:
# - All 3 applications listed
# - Green "Synced" status
# - Green "Healthy" status
# - No error messages
```

#### Check 5: Kubernetes Resources
```bash
# Check if pods are running with latest images
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[0].image}{"\n"}{end}'

# Check deployment image tags
kubectl get deployment api-gateway -o jsonpath='{.spec.template.spec.containers[0].image}'
kubectl get deployment service1 -o jsonpath='{.spec.template.spec.containers[0].image}'
kubectl get deployment service2 -o jsonpath='{.spec.template.spec.containers[0].image}'

# Should match the latest image tag from Docker Hub
```

#### Check 6: GitHub Repository Status (for ArgoCD)
```bash
# Check if Helm charts are updated in GitHub
# Visit: https://github.com/wrakash/sky-service1/tree/main/helm
# Visit: https://github.com/wrakash/sky-service2/tree/main/helm
# Visit: https://github.com/wrakash/sky-apigateway/tree/main/helm

# Check values.yaml has latest image tag
# The image.tag should match the Docker image tag that was built
```

---

### C. Troubleshooting CI/CD Issues

#### Issue: Pipeline Failed at Test Stage
```bash
# Check job logs in GitLab UI
# Common issues:
# - Missing dependencies → Run `npm install` locally
# - Linting errors → Run `npm run lint` locally
# - Test failures → Run `npm test` locally
```

#### Issue: Pipeline Failed at Build Stage
```bash
# Check Docker Hub credentials
# Verify DOCKER_HUB_TOKEN is set in GitLab CI/CD variables

# Test Docker login manually
docker login -u wrakash -p <your-token>

# Check if image exists
docker pull wrakash/sky-service1:latest
```

#### Issue: ArgoCD Application Shows "Unknown" Status
```bash
# Check if GitHub repository exists and has code
# Check if helm directory exists in GitHub repo
# Check GitHub credentials in ArgoCD:
kubectl get secret github-creds -n argocd

# Reconfigure if needed:
cd scripts
./configure-argocd-git.sh
```

#### Issue: ArgoCD Application Shows "OutOfSync"
```bash
# Force sync
kubectl patch application api-gateway -n argocd --type json \
  -p='[{"op": "replace", "path": "/operation", "value": {"initiatedBy": {"username": "admin"},"sync": {"revision": "HEAD"}}}]'

# Or sync via ArgoCD CLI
argocd app sync api-gateway
```

#### Issue: Pods Not Starting
```bash
# Check pod events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Common issues:
# - Image pull errors → Check image exists on Docker Hub
# - Image pull secrets → Create if using private registry
# - Resource limits → Check if cluster has resources
```

---

## 4️⃣ Complete Health Check Checklist

### ✅ Quick Health Check (5 minutes)

- [ ] All services respond to health checks
- [ ] API Gateway routes requests correctly
- [ ] Kubernetes pods are running (if using K8s)
- [ ] No error logs in any service
- [ ] Docker images exist on Docker Hub (if using CI/CD)

### ✅ Full Health Check (15 minutes)

- [ ] **Local/Kubernetes Services:**
  - [ ] API Gateway: `curl http://localhost:3000/health` returns `{"status":"ok"}`
  - [ ] Service1: `curl http://localhost:3001/health` returns `{"status":"ok"}`
  - [ ] Service2: `curl http://localhost:3002/health` returns `{"status":"ok"}`
  - [ ] All pods show `Running` and `Ready: 1/1`
  - [ ] No crash loop or error events in pods

- [ ] **CI/CD Pipeline:**
  - [ ] GitLab CI/CD variables are configured
  - [ ] Latest pipeline shows ✅ for test and build stages
  - [ ] Docker images exist on Docker Hub with latest tag
  - [ ] ArgoCD applications show `Synced` and `Healthy`
  - [ ] Helm chart values.yaml has correct image tag

- [ ] **ArgoCD (if using):**
  - [ ] ArgoCD namespace exists
  - [ ] All ArgoCD pods are running
  - [ ] GitHub credentials are configured
  - [ ] All 3 applications are synced
  - [ ] ArgoCD UI is accessible

- [ ] **End-to-End Test:**
  - [ ] Create user via API Gateway
  - [ ] Create payment via API Gateway
  - [ ] All requests return successful responses
  - [ ] Services can communicate with each other

---

## 🚀 Quick Commands Reference

```bash
# === Service Health Checks ===
curl http://localhost:3000/health  # API Gateway
curl http://localhost:3001/health  # Service1
curl http://localhost:3002/health  # Service2

# === Kubernetes Checks ===
kubectl get pods
kubectl get svc
kubectl get deployments
kubectl logs <pod-name>

# === CI/CD Verification ===
cd scripts && ./verify-cicd-pipeline.sh
kubectl get applications -n argocd

# === ArgoCD Access ===
cd scripts && ./access-argocd-ui.sh
kubectl get applications -n argocd -o wide

# === Pipeline Trigger ===
git add . && git commit -m "test: trigger CI/CD" && git push origin main

# === Force ArgoCD Sync ===
kubectl patch application <app-name> -n argocd --type json \
  -p='[{"op": "replace", "path": "/operation", "value": {"initiatedBy": {"username": "admin"},"sync": {"revision": "HEAD"}}}]'
```

---

## 📊 Success Indicators

### ✅ Everything is Working When:

1. **Services:**
   - All health endpoints return `{"status":"ok"}`
   - No errors in logs
   - All pods are `Running` with `Ready: 1/1`

2. **CI/CD:**
   - GitLab pipeline shows ✅ for test and build
   - Docker images are pushed to Docker Hub
   - ArgoCD shows all apps as `Synced` and `Healthy`
   - Latest code changes are deployed

3. **Integration:**
   - API Gateway successfully proxies to Service1 and Service2
   - End-to-end API calls work
   - No 503 or 500 errors

---

## 🆘 Need Help?

1. Run verification script: `./scripts/verify-cicd-pipeline.sh`
2. Check logs: `kubectl logs <pod-name>` or `docker logs <container>`
3. Check ArgoCD UI: `./scripts/access-argocd-ui.sh`
4. Review GitLab pipeline logs in the CI/CD section
5. Check this guide's troubleshooting section

---

**Last Updated:** Based on current project configuration
**Project:** Microservices with NestJS, Kubernetes, and ArgoCD

