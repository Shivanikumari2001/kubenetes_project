# ✅ Step-by-Step: How to Check if Your Project is Running

Complete guide to verify all microservices are running correctly.

---

## 🎯 **Quick Check (1 Minute)**

### **Method 1: Test Health Endpoints**

Open PowerShell and run:

```powershell
# Test API Gateway
Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing

# Test Service1
Invoke-WebRequest -Uri "http://localhost:3001/health" -UseBasicParsing

# Test Service2
Invoke-WebRequest -Uri "http://localhost:3002/health" -UseBasicParsing
```

**✅ If you see responses like:**
```
StatusCode        : 200
Content           : {"status":"ok","service":"api-gateway-service","timestamp":"..."}
```
**→ Services are RUNNING!** ✅

**❌ If you see errors like:**
```
Unable to connect to the remote server
```
**→ Services are NOT running** ❌

---

## 📋 **Complete Step-by-Step Verification**

### **STEP 1: Check if Services are Started Locally**

#### **Option A: Check Background Jobs (if using PowerShell jobs)**

```powershell
# Check if services are running as background jobs
Get-Job | Format-Table Id, Name, State

# Expected output:
# Id Name       State
# -- ----       -----
# 1  Service1   Running
# 2  Service2   Running
# 3  APIGateway Running
```

**If jobs are NOT running:**
```powershell
# Start services
.\scripts\start-services.ps1
```

#### **Option B: Check Ports are in Use**

```powershell
# Check if ports 3000, 3001, 3002 are listening
netstat -ano | findstr ":3000 :3001 :3002" | findstr "LISTENING"

# Expected output:
# TCP    0.0.0.0:3000           0.0.0.0:0              LISTENING       1234
# TCP    0.0.0.0:3001           0.0.0.0:0              LISTENING       5678
# TCP    0.0.0.0:3002           0.0.0.0:0              LISTENING       9012
```

**If ports are NOT in use:**
→ Services are NOT running. Start them first:
```powershell
# Terminal 1 - Service1
cd service1
npm run start:dev

# Terminal 2 - Service2
cd service2
npm run start:dev

# Terminal 3 - API Gateway
cd api-gateway
npm run start:dev
```

---

### **STEP 2: Test Health Endpoints**

#### **2.1 Test API Gateway (Port 3000)**

```powershell
# Test health endpoint
$response = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing
Write-Host "Status Code: $($response.StatusCode)"
Write-Host "Response: $($response.Content)"
```

**✅ Expected:**
```
Status Code: 200
Response: {"status":"ok","service":"api-gateway-service","timestamp":"2025-11-19T..."}
```

**❌ If Error:**
```
Invoke-WebRequest: Unable to connect to the remote server
```
→ API Gateway is NOT running

#### **2.2 Test Service1 (Port 3001)**

```powershell
# Test health endpoint
$response = Invoke-WebRequest -Uri "http://localhost:3001/health" -UseBasicParsing
Write-Host "Status Code: $($response.StatusCode)"
Write-Host "Response: $($response.Content)"
```

**✅ Expected:**
```
Status Code: 200
Response: {"status":"ok"}
```

**❌ If Error:**
```
Invoke-WebRequest: Unable to connect to the remote server
```
→ Service1 is NOT running

#### **2.3 Test Service2 (Port 3002)**

```powershell
# Test health endpoint
$response = Invoke-WebRequest -Uri "http://localhost:3002/health" -UseBasicParsing
Write-Host "Status Code: $($response.StatusCode)"
Write-Host "Response: $($response.Content)"
```

**✅ Expected:**
```
Status Code: 200
Response: {"status":"ok","service":"service2","timestamp":"2025-11-19T..."}
```

**❌ If Error:**
```
Invoke-WebRequest: Unable to connect to the remote server
```
→ Service2 is NOT running

---

### **STEP 3: Test API Gateway Root Endpoint**

```powershell
# Test root endpoint
$response = Invoke-WebRequest -Uri "http://localhost:3000/" -UseBasicParsing
Write-Host "Response: $($response.Content)"
```

**✅ Expected:**
```json
{
  "message": "API Gateway is running - CI/CD Test Successful!",
  "version": "1.0.1",
  "timestamp": "2025-11-19T..."
}
```

---

### **STEP 4: Test API Gateway Routing**

#### **4.1 Test Routing to Service1**

```powershell
# Get users (routes to Service1)
$response = Invoke-WebRequest -Uri "http://localhost:3000/api/users" -UseBasicParsing
Write-Host "Status Code: $($response.StatusCode)"
Write-Host "Response: $($response.Content)"
```

**✅ Expected:**
```
Status Code: 200
Response: []  (or list of users if any exist)
```

#### **4.2 Test Routing to Service2**

```powershell
# Get payments (routes to Service2)
$response = Invoke-WebRequest -Uri "http://localhost:3000/api/payments" -UseBasicParsing
Write-Host "Status Code: $($response.StatusCode)"
Write-Host "Response: $($response.Content)"
```

**✅ Expected:**
```
Status Code: 200
Response: []  (or list of payments if any exist)
```

---

### **STEP 5: Check Service Logs**

#### **5.1 Check Background Job Logs**

```powershell
# View Service1 logs
Receive-Job -Name Service1 -Keep | Select-Object -Last 20

# View Service2 logs
Receive-Job -Name Service2 -Keep | Select-Object -Last 20

# View API Gateway logs
Receive-Job -Name APIGateway -Keep | Select-Object -Last 20
```

**✅ Look for:**
```
Service1 HTTP is running on port 3001
Service2 is running on port 3002
API Gateway is running on port 3000
```

**❌ Look for errors:**
```
Error: Cannot find module...
Error: EADDRINUSE (port already in use)
Error starting...
```

#### **5.2 Check Console Output (if running in terminals)**

If you started services manually in separate terminals, check each terminal window for:
- ✅ "is running on port..." messages
- ❌ Error messages

---

### **STEP 6: Test with Browser (Visual Check)**

1. **Open your browser**

2. **Test API Gateway:**
   - URL: `http://localhost:3000/health`
   - Expected: See JSON response with `"status":"ok"`

3. **Test Service1:**
   - URL: `http://localhost:3001/health`
   - Expected: See JSON response with `"status":"ok"`

4. **Test Service2:**
   - URL: `http://localhost:3002/health`
   - Expected: See JSON response with `"status":"ok"`

5. **Test API Gateway Root:**
   - URL: `http://localhost:3000/`
   - Expected: See message "API Gateway is running..."

---

## 🐳 **If Using Docker**

### **STEP 1: Check Docker Containers**

```powershell
# Check if containers are running
docker ps

# Expected output:
# CONTAINER ID   IMAGE                        STATUS          PORTS                    NAMES
# abc123def456   wrakash/sky-gateway:1.0.0    Up 5 minutes    0.0.0.0:3000->3000/tcp   api-gateway
# def456ghi789   wrakash/sky-service1:1.0.0   Up 5 minutes    0.0.0.0:3001->3001/tcp   service1
# ghi789jkl012   wrakash/sky-service2:1.0.0   Up 5 minutes    0.0.0.0:3002->3002/tcp   service2
```

**✅ If containers are running:**
→ Services are RUNNING in Docker

**❌ If containers are NOT running:**
```powershell
# Start containers
docker start api-gateway service1 service2

# Or run them
docker run -d -p 3000:3000 --name api-gateway wrakash/sky-gateway:1.0.0
docker run -d -p 3001:3001 --name service1 wrakash/sky-service1:1.0.0
docker run -d -p 3002:3002 --name service2 wrakash/sky-service2:1.0.0
```

### **STEP 2: Check Docker Logs**

```powershell
# Check container logs
docker logs api-gateway
docker logs service1
docker logs service2

# Follow logs in real-time
docker logs -f api-gateway
```

---

## ☸️ **If Using Kubernetes**

### **STEP 1: Check Pods**

```powershell
# Check if pods are running
kubectl get pods

# Expected output:
# NAME                            READY   STATUS    RESTARTS   AGE
# api-gateway-7d4b8f9c5-abc123    1/1     Running   0          5m
# service1-6c3a7e8d4-def456       1/1     Running   0          5m
# service2-5b2a6c7d3-ghi789       1/1     Running   0          5m
```

**✅ If STATUS is "Running" and READY is "1/1":**
→ Services are RUNNING in Kubernetes

**❌ If STATUS is NOT "Running":**
```powershell
# Check pod details
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>
```

### **STEP 2: Check Services**

```powershell
# Check Kubernetes services
kubectl get svc

# Expected output:
# NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
# api-gateway   ClusterIP   10.96.1.100     <none>        3000/TCP   5m
# service1      ClusterIP   10.96.1.101     <none>        3001/TCP   5m
# service2      ClusterIP   10.96.1.102     <none>        3002/TCP   5m
```

### **STEP 3: Port Forward and Test**

```powershell
# Port forward API Gateway
kubectl port-forward svc/api-gateway 3000:3000

# Then test in another terminal:
Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing
```

---

## 🔧 **Automated Check Script**

Run the automated verification script:

```powershell
.\scripts\run-and-verify.ps1
```

Or the simpler version:

```powershell
.\scripts\start-services.ps1
```

This will:
- ✅ Check if services are running
- ✅ Start them if not running
- ✅ Test all endpoints
- ✅ Show status summary

---

## 📊 **Status Checklist**

### **Local Services:**

- [ ] **Port 3000** is listening (API Gateway)
- [ ] **Port 3001** is listening (Service1)
- [ ] **Port 3002** is listening (Service2)
- [ ] `http://localhost:3000/health` returns `200 OK`
- [ ] `http://localhost:3001/health` returns `200 OK`
- [ ] `http://localhost:3002/health` returns `200 OK`
- [ ] API Gateway routes to Service1: `http://localhost:3000/api/users`
- [ ] API Gateway routes to Service2: `http://localhost:3000/api/payments`
- [ ] No error messages in logs

### **Docker (if using):**

- [ ] All 3 containers are running: `docker ps`
- [ ] Containers show "Up" status
- [ ] Container logs show "running on port..." messages

### **Kubernetes (if using):**

- [ ] All 3 pods are Running: `kubectl get pods`
- [ ] All pods show READY 1/1
- [ ] Services are created: `kubectl get svc`
- [ ] Port forwarding works

---

## 🚨 **Troubleshooting**

### **Problem: Services Not Starting**

**Check:**
1. Ports are free: `netstat -ano | findstr ":3000 :3001 :3002"`
2. Dependencies installed: `cd service1 && npm list --depth=0`
3. Prisma setup: `cd service1 && npx prisma generate`
4. Node.js version: `node --version` (should be 20+)

**Solution:**
```powershell
# Kill processes on ports
.\scripts\kill-port.sh 3000
.\scripts\kill-port.sh 3001
.\scripts\kill-port.sh 3002

# Restart services
.\scripts\start-services.ps1
```

### **Problem: Health Endpoints Not Responding**

**Check:**
1. Services are actually running (Step 1)
2. Wait 30-40 seconds after starting for services to fully start
3. Check logs for errors (Step 5)

**Solution:**
```powershell
# Wait longer, then test again
Start-Sleep -Seconds 10
Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing
```

### **Problem: "Unable to connect" Error**

**Possible causes:**
1. Service not started
2. Firewall blocking ports
3. Wrong port number
4. Service crashed

**Solution:**
```powershell
# Check if process is running
Get-Process -Name node -ErrorAction SilentlyContinue

# Check logs
Receive-Job -Name Service1 -Keep | Select-Object -Last 30
```

---

## ✅ **Quick Verification Commands (Copy & Paste)**

```powershell
# Complete verification in one go
Write-Host "=== Checking Services ===" -ForegroundColor Cyan
Write-Host ""

# Check ports
Write-Host "1. Checking ports..." -ForegroundColor Yellow
netstat -ano | findstr ":3000 :3001 :3002" | findstr "LISTENING"

Write-Host ""
Write-Host "2. Testing endpoints..." -ForegroundColor Yellow

# Test API Gateway
try {
    $r = Invoke-WebRequest -Uri "http://localhost:3000/health" -UseBasicParsing -TimeoutSec 3
    Write-Host "✅ API Gateway (3000): RUNNING" -ForegroundColor Green
} catch {
    Write-Host "❌ API Gateway (3000): NOT RUNNING" -ForegroundColor Red
}

# Test Service1
try {
    $r = Invoke-WebRequest -Uri "http://localhost:3001/health" -UseBasicParsing -TimeoutSec 3
    Write-Host "✅ Service1 (3001): RUNNING" -ForegroundColor Green
} catch {
    Write-Host "❌ Service1 (3001): NOT RUNNING" -ForegroundColor Red
}

# Test Service2
try {
    $r = Invoke-WebRequest -Uri "http://localhost:3002/health" -UseBasicParsing -TimeoutSec 3
    Write-Host "✅ Service2 (3002): RUNNING" -ForegroundColor Green
} catch {
    Write-Host "❌ Service2 (3002): NOT RUNNING" -ForegroundColor Red
}

Write-Host ""
Write-Host "=== Check Complete ===" -ForegroundColor Cyan
```

---

## 🎯 **Summary**

**Services are RUNNING if:**
- ✅ Ports 3000, 3001, 3002 are listening
- ✅ Health endpoints return `200 OK`
- ✅ Logs show "running on port..." messages
- ✅ API Gateway can route to services

**Services are NOT RUNNING if:**
- ❌ Ports are not in use
- ❌ Health endpoints return connection errors
- ❌ No processes found
- ❌ Error messages in logs

---

**Quick Check:** Run `.\scripts\start-services.ps1` - it will check and start everything automatically!

