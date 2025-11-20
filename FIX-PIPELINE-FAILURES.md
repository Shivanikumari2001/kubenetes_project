# Fix GitLab CI/CD Pipeline Failures

## 🔍 Why Your Pipelines Are Failing

Based on your GitLab CI/CD setup, here are the most common reasons and how to fix them:

---

## 🚨 Common Failure Reasons

### 1. Missing CI/CD Variables (MOST COMMON)

**Symptoms:**
- Pipeline fails at "build" stage
- Error: "Cannot connect to Docker daemon" or "authentication required"

**Fix:**
1. Go to GitLab project → **Settings** → **CI/CD** → **Variables** → **Expand**
2. Add these variables:

| Key | Value | Protected | Masked |
|-----|-------|-----------|--------|
| `DOCKER_HUB_USER` | `wrakash` | ❌ No | ❌ No |
| `DOCKER_HUB_TOKEN` | `your-docker-hub-token` | ✅ Yes | ✅ Yes |

**To get Docker Hub Token:**
- Go to: https://hub.docker.com/settings/security
- Click "New Access Token"
- Copy the token and paste it as `DOCKER_HUB_TOKEN` value

---

### 2. Test Stage Failing

**Symptoms:**
- Pipeline fails at "test" stage
- Error: "npm run lint failed" or "npm run test failed"

**Fix:**
```bash
# Test locally first
cd api-gateway
npm run lint
npm run test

# Fix any errors, then commit and push
```

**Quick fix (if tests are not critical):**
- Comment out test stage temporarily in `.gitlab-ci.yml`:
```yaml
# test:
#   stage: test
#   ...
```

---

### 3. Wrong .gitlab-ci.yml Location

**Symptoms:**
- Pipeline doesn't run at all, or runs but can't find files

**Fix:**
Your `.gitlab-ci.yml` files are in each service directory, but GitLab looks for it in the **root** of the repository.

**Option A: Move to root (Recommended for monorepo)**
```bash
# Create a root-level .gitlab-ci.yml that handles all services
# See example below
```

**Option B: Keep per-service (Requires separate GitLab projects)**
- Each service needs its own GitLab repository
- Push each service to its own GitLab project

---

### 4. Docker Build Errors

**Symptoms:**
- Build stage fails
- Error: "Dockerfile not found" or build errors

**Fix:**
```bash
# Test Docker build locally
cd api-gateway
docker build -t test-image .

# If it works locally, the issue might be:
# - Missing files in git (check .gitignore)
# - Docker context issues
```

---

### 5. Missing Dependencies

**Symptoms:**
- "npm ci" fails
- "package.json not found"

**Fix:**
- Make sure `package.json` and `package-lock.json` are committed
- Check `.gitignore` doesn't exclude necessary files

---

## 🔧 Step-by-Step Fix

### Step 1: Check Pipeline Logs

1. Go to GitLab → **CI/CD** → **Pipelines**
2. Click on a failed pipeline
3. Click on the failed job (red X)
4. Read the error message

**Common errors you'll see:**

```
Error: Cannot connect to Docker daemon
→ Missing DOCKER_HUB_TOKEN variable

Error: npm ERR! code ENOENT
→ Missing package.json or wrong directory

Error: docker: 'login' requires 1 argument
→ Missing DOCKER_HUB_USER or DOCKER_HUB_TOKEN

Error: denied: requested access to the resource is denied
→ Wrong Docker Hub credentials or token expired
```

### Step 2: Fix Based on Error

**If error is about Docker login:**
- Add `DOCKER_HUB_USER` and `DOCKER_HUB_TOKEN` variables

**If error is about npm:**
- Check if `package.json` exists in the service directory
- Make sure you're in the right directory in the CI script

**If error is about file not found:**
- Check if `.gitlab-ci.yml` is in the root or service directory
- Verify all necessary files are committed to git

### Step 3: Test Locally

```bash
# Test the build process locally
cd api-gateway

# Test npm install
npm ci

# Test Docker build
docker build -t test-image .

# Test Docker login
docker login -u wrakash -p YOUR_TOKEN
docker push wrakash/sky-gateway:test
```

### Step 4: Update .gitlab-ci.yml Location

**If your repo structure is:**
```
my-devops-project/
├── api-gateway/
│   ├── .gitlab-ci.yml  ← This won't work!
│   └── ...
├── service1/
│   └── ...
└── service2/
    └── ...
```

**You need a root-level `.gitlab-ci.yml`:**

Create `E:\kube\.gitlab-ci.yml`:

```yaml
stages:
  - test
  - build
  - deploy

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: "/certs"

# API Gateway
api-gateway:test:
  stage: test
  image: node:20-alpine
  before_script:
    - cd api-gateway
    - npm ci
  script:
    - npm run lint
    - npm run test
  only:
    - main
    - master
    - develop

api-gateway:build:
  stage: build
  image: docker:24-dind
  services:
    - docker:24-dind
  before_script:
    - cd api-gateway
    - |
      if [ -z "$CI_REGISTRY" ]; then
        docker login -u $DOCKER_HUB_USER -p $DOCKER_HUB_TOKEN
      fi
  script:
    - export IMAGE_TAG=${CI_COMMIT_SHORT_SHA:-latest}
    - export IMAGE_NAME=wrakash/sky-gateway
    - docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
    - docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
    - docker push ${IMAGE_NAME}:${IMAGE_TAG}
    - docker push ${IMAGE_NAME}:latest
  only:
    - main
    - master
    - develop

# Repeat for service1 and service2...
```

---

## ✅ Quick Fix Checklist

- [ ] **Add CI/CD Variables:**
  - [ ] `DOCKER_HUB_USER` = `wrakash`
  - [ ] `DOCKER_HUB_TOKEN` = (your Docker Hub token)

- [ ] **Check .gitlab-ci.yml location:**
  - [ ] If monorepo: Move to root or create root-level file
  - [ ] If separate repos: Each service needs its own GitLab project

- [ ] **Verify files are committed:**
  - [ ] `package.json` exists
  - [ ] `Dockerfile` exists
  - [ ] `.gitlab-ci.yml` exists

- [ ] **Test locally:**
  - [ ] `npm ci` works
  - [ ] `docker build` works
  - [ ] `docker login` works

---

## 🎯 Most Likely Fix for Your Case

Based on your setup, **the most likely issue is missing CI/CD variables**.

**Do this now:**

1. **Go to GitLab:**
   - Project → Settings → CI/CD → Variables

2. **Add these variables:**
   ```
   DOCKER_HUB_USER = wrakash
   DOCKER_HUB_TOKEN = [get from https://hub.docker.com/settings/security]
   ```

3. **Trigger a new pipeline:**
   ```bash
   # Make a small change
   echo "// test" >> api-gateway/src/main.ts
   git add .
   git commit -m "test: fix CI/CD"
   git push origin main
   ```

4. **Watch the pipeline:**
   - Go to CI/CD → Pipelines
   - Click on the new pipeline
   - It should pass now!

---

## 📊 How to Read Pipeline Logs

1. **Click on failed pipeline** → Click on **failed job** (red X)
2. **Scroll to the bottom** - the error is usually at the end
3. **Look for keywords:**
   - "Cannot connect" → Docker/network issue
   - "authentication required" → Missing credentials
   - "not found" → Missing file
   - "npm ERR" → npm/dependency issue
   - "docker: error" → Docker build issue

---

## 🆘 Still Failing?

1. **Copy the exact error message** from pipeline logs
2. **Check which stage fails:**
   - Test stage? → Fix code/tests
   - Build stage? → Fix Docker/credentials
   - Deploy stage? → Usually optional, can skip

3. **Try minimal .gitlab-ci.yml:**
   ```yaml
   build:
     image: docker:24-dind
     services:
       - docker:24-dind
     before_script:
       - docker login -u $DOCKER_HUB_USER -p $DOCKER_HUB_TOKEN
     script:
       - cd api-gateway
       - docker build -t wrakash/sky-gateway:test .
       - docker push wrakash/sky-gateway:test
   ```

---

**Next Step:** Add the CI/CD variables and try again! 🚀

