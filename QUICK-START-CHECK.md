# ⚡ Quick Start: Verify Everything is Running

## 🎯 One-Command Health Check

```bash
# Run complete health check
./scripts/health-check.sh
```

This checks:
- ✅ Local services (ports 3000, 3001, 3002)
- ✅ Docker containers
- ✅ Kubernetes resources
- ✅ ArgoCD status
- ✅ CI/CD configuration files

---

## 🚀 How to Run CI/CD

### Step 1: Setup (One-time)

1. **Configure GitLab CI/CD Variables:**
   - Go to GitLab project → Settings → CI/CD → Variables
   - Add:
     - `DOCKER_HUB_USER` = `wrakash`
     - `DOCKER_HUB_TOKEN` = (Your Docker Hub token)

2. **Push code to GitLab:**
   ```bash
   cd service1  # or service2, api-gateway
   git init
   git remote add origin <your-gitlab-repo-url>
   git add .
   git commit -m "Initial commit"
   git push -u origin main
   ```

### Step 2: Trigger Pipeline

```bash
# Make a change and push
echo "// Test" >> src/main.ts
git add .
git commit -m "test: trigger CI/CD"
git push origin main
```

### Step 3: Check Status

1. **GitLab Pipeline:**
   - Go to GitLab → CI/CD → Pipelines
   - Watch test ✅ and build ✅ stages run automatically

2. **After Build Succeeds:**
   - Click "▶ Play" on `update-helm-chart` job
   - This updates GitHub repo → ArgoCD auto-syncs → New version deploys!

---

## 📊 How to Check CI/CD is Working

### Method 1: Automated Script
```bash
./scripts/verify-cicd-pipeline.sh
```

### Method 2: Manual Checks

**Check GitLab Pipeline:**
```bash
# Visit GitLab → CI/CD → Pipelines
# Should see: ✅ Test, ✅ Build
```

**Check Docker Hub:**
```bash
# Visit: https://hub.docker.com/r/wrakash/sky-service1/tags
# Should see latest image
```

**Check ArgoCD:**
```bash
kubectl get applications -n argocd
# Should show: Synced | Healthy

# Or use UI:
./scripts/access-argocd-ui.sh
```

**Check Kubernetes:**
```bash
kubectl get pods
# All pods should be Running
```

---

## ✅ Quick Verification Commands

```bash
# Test services
curl http://localhost:3000/health  # API Gateway
curl http://localhost:3001/health  # Service1
curl http://localhost:3002/health  # Service2

# Check Kubernetes
kubectl get pods
kubectl get svc

# Check CI/CD
./scripts/verify-cicd-pipeline.sh

# Check ArgoCD
kubectl get applications -n argocd
```

---

## 📚 Full Documentation

For complete details, see:
- **VERIFICATION-GUIDE.md** - Complete verification guide
- **README.md** - How to run the project
- **ci-cd.md** - CI/CD setup details

---

## 🆘 Quick Troubleshooting

**Services not responding?**
```bash
# Check if running
netstat -ano | findstr :3000  # Windows
lsof -i :3000                 # Linux/Mac
```

**Pipeline failing?**
- Check GitLab → CI/CD → Pipelines → Click failed job → View logs
- Ensure `DOCKER_HUB_TOKEN` is set in GitLab CI/CD variables

**ArgoCD not syncing?**
```bash
./scripts/verify-cicd-pipeline.sh
kubectl get applications -n argocd
```

**Pods not starting?**
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

