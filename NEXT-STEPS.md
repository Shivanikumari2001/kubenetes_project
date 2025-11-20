# Next Steps: Testing Your Fix

## 🎯 Immediate Next Steps

### Step 1: Test the Fix Locally

Since we just fixed the routing issue for `/service1/health`, you need to test it:

#### A. If Running Services Locally (Development Mode)

**1. Make sure Service1 is running:**
```bash
# Open a terminal and navigate to service1
cd service1
npm run start:dev
# Service1 should be running on http://localhost:3001
```

**2. Rebuild and restart API Gateway:**
```bash
# Navigate to api-gateway
cd api-gateway

# Rebuild the project (since we changed the code)
npm run build

# Restart the API Gateway
npm run start:dev
# API Gateway should be running on http://localhost:3000
```

**3. Test the endpoint:**
```bash
# Open browser or use curl
curl http://localhost:3000/service1/health

# Or open in browser:
# http://localhost:3000/service1/health
```

**Expected Result:**
```json
{"status":"ok"}
```

---

#### B. If Running in Kubernetes/Docker

**1. Rebuild Docker image:**
```bash
# Navigate to api-gateway
cd api-gateway

# Build new Docker image with the fix
docker build -t wrakash/api-gateway:latest .

# Push to Docker Hub (if needed)
docker push wrakash/api-gateway:latest
```

**2. Update Kubernetes deployment:**
```bash
# If using Helm
helm upgrade api-gateway ./api-gateway/helm --set image.tag=latest

# Or if using kubectl directly
kubectl rollout restart deployment/api-gateway
```

**3. Port forward and test:**
```bash
# Port forward API Gateway
kubectl port-forward svc/api-gateway 3000:3000

# In another terminal, test
curl http://localhost:3000/service1/health
```

---

### Step 2: Verify All Endpoints Work

Test these endpoints to make sure everything is working:

```bash
# API Gateway root
curl http://localhost:3000

# API Gateway health
curl http://localhost:3000/health

# Service1 health (the one we just fixed)
curl http://localhost:3000/service1/health

# Service2 health
curl http://localhost:3000/service2/health

# Service1 root
curl http://localhost:3000/service1

# Service2 root
curl http://localhost:3000/service2
```

---

### Step 3: If You Haven't Set Up the Project Yet

If you're just starting, follow the complete setup guide:

1. **Read the setup guide:**
   - Open `COMPLETE-SETUP-GUIDE.md`
   - Follow it step by step

2. **Quick start (if you have everything installed):**
   ```bash
   # Start Minikube
   minikube start --nodes 3
   eval $(minikube docker-env)
   
   # Build images
   cd service1 && docker build -t service1:latest .
   cd ../service2 && docker build -t service2:latest .
   cd ../api-gateway && docker build -t api-gateway:latest .
   
   # Deploy with Helm
   helm install service1 ./service1/helm
   helm install service2 ./service2/helm
   helm install api-gateway ./api-gateway/helm
   
   # Port forward and test
   kubectl port-forward svc/api-gateway 3000:3000
   ```

---

## 🔍 Troubleshooting

### If you still get 404 error:

1. **Check if Service1 is running:**
   ```bash
   # For local development
   curl http://localhost:3001/health
   
   # For Kubernetes
   kubectl get pods -l app=service1
   kubectl logs <service1-pod-name>
   ```

2. **Check API Gateway logs:**
   ```bash
   # For local development
   # Check the terminal where API Gateway is running
   
   # For Kubernetes
   kubectl logs <api-gateway-pod-name>
   ```

3. **Verify the code changes were applied:**
   ```bash
   # Check if the routes are in app.controller.ts
   grep -n "service1/\*" api-gateway/src/app.controller.ts
   
   # Check if path handling is in app.service.ts
   grep -n "service1" api-gateway/src/app.service.ts
   ```

4. **Rebuild the project:**
   ```bash
   cd api-gateway
   npm run build
   # Make sure there are no build errors
   ```

---

## 📝 What We Fixed

We added route handlers for `/service1/*` and `/service2/*` paths in the API Gateway so that:
- `http://localhost:3000/service1/health` → forwards to `http://service1:3001/health`
- `http://localhost:3000/service2/health` → forwards to `http://service2:3002/health`

The fix includes:
1. ✅ Added routes in `app.controller.ts` for `service1/*` and `service2/*`
2. ✅ Updated path handling in `app.service.ts` to strip the service prefix
3. ✅ Removed conflicting proxy middleware from `main.ts`

---

## 🚀 After Testing

Once everything works:

1. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Fix: Add routing for /service1/* and /service2/* endpoints"
   git push
   ```

2. **If using GitLab CI/CD:**
   - The pipeline will automatically build and push new Docker images
   - ArgoCD will automatically sync and deploy (if configured)

3. **Continue with the setup guide:**
   - Follow `COMPLETE-SETUP-GUIDE.md` for full deployment setup
   - Set up GitLab CI/CD
   - Configure ArgoCD

---

## ✅ Success Checklist

- [ ] API Gateway starts without errors
- [ ] `http://localhost:3000/service1/health` returns `{"status":"ok"}`
- [ ] `http://localhost:3000/service2/health` returns `{"status":"ok"}`
- [ ] All endpoints respond correctly
- [ ] No 404 errors

---

**Need help?** Check the troubleshooting section or review the logs!

