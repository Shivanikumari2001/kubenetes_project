# How to Verify Your CI/CD Pipeline is Working

This guide will help you check if your GitLab CI/CD pipeline is working correctly.

---

## 🔍 Quick Verification Checklist

### Step 1: Check if Code is Pushed to GitLab

```bash
# Check if you have a GitLab remote
cd E:\kube
git remote -v

# If you see a GitLab URL, you're good. If not, you need to add it:
# git remote add origin https://gitlab.com/your-username/your-repo-name.git
```

### Step 2: Check GitLab CI/CD Variables

Your pipeline needs these variables configured in GitLab:

**Required Variables:**
1. Go to your GitLab project
2. Navigate to: **Settings** → **CI/CD** → **Variables** → **Expand**
3. Make sure these variables exist:

| Variable Name | Value | Protected | Masked |
|--------------|-------|-----------|--------|
| `DOCKER_HUB_USER` | `wrakash` | No | No |
| `DOCKER_HUB_TOKEN` | `your-docker-hub-token` | Yes | Yes |
| `CI_REGISTRY_USER` | `wrakash` (optional) | No | No |
| `CI_REGISTRY_PASSWORD` | `your-docker-hub-password` (optional) | Yes | Yes |

**To get Docker Hub Token:**
1. Go to https://hub.docker.com/settings/security
2. Click "New Access Token"
3. Give it a name (e.g., "GitLab CI")
4. Copy the token and use it as `DOCKER_HUB_TOKEN`

### Step 3: Check Pipeline Status in GitLab

**Via GitLab UI:**
1. Go to your GitLab project
2. Click **CI/CD** → **Pipelines** in the left sidebar
3. You should see:
   - ✅ **Green checkmarks** = Pipeline is working
   - ❌ **Red X** = Pipeline failed (check logs)
   - ⏸️ **Paused** = Pipeline is waiting for manual trigger
   - ⏳ **Running** = Pipeline is currently executing

**Via Command Line:**
```bash
# Check if you have GitLab CLI installed (optional)
# If not, use the web UI method above
```

### Step 4: Test the Pipeline

**Make a test change and push:**

```bash
# Navigate to any service (e.g., api-gateway)
cd E:\kube\api-gateway

# Make a small change
echo "// CI/CD test" >> src/main.ts

# Commit and push
git add .
git commit -m "test: trigger CI/CD pipeline"
git push origin main
```

**What should happen:**
1. GitLab detects the push
2. Pipeline automatically starts
3. You'll see it in GitLab → CI/CD → Pipelines

### Step 5: Monitor Pipeline Execution

**In GitLab UI:**
1. Go to **CI/CD** → **Pipelines**
2. Click on the latest pipeline
3. You should see these stages:

   **Stage 1: Test** (runs on merge requests, main, master, develop)
   - Runs `npm run lint`
   - Runs `npm run test`
   
   **Stage 2: Build** (runs on main, master, develop, tags)
   - Builds Docker image
   - Tags image with commit SHA
   - Pushes to Docker Hub as `wrakash/sky-gateway:latest` and `wrakash/sky-gateway:<commit-sha>`
   
   **Stage 3: Deploy** (manual, runs on main/master)
   - `deploy` job: Deploys to Kubernetes (requires KUBECONFIG)
   - `update-helm-chart` job: Updates Helm chart values.yaml

### Step 6: Verify Docker Images Were Pushed

**Check Docker Hub:**
1. Go to https://hub.docker.com/u/wrakash
2. You should see these repositories:
   - `wrakash/sky-gateway` (API Gateway)
   - `wrakash/sky-service1` (Service1)
   - `wrakash/sky-service2` (Service2)
3. Check if images have been pushed recently

**Via Command Line:**
```bash
# Check if you can pull the image (requires docker login)
docker pull wrakash/sky-gateway:latest

# Or check via Docker Hub API (requires authentication)
curl -u wrakash:your-token https://hub.docker.com/v2/repositories/wrakash/sky-gateway/tags/
```

---

## 🚨 Common Issues and Solutions

### Issue 1: Pipeline Not Running

**Symptoms:**
- No pipelines appear in GitLab
- Push doesn't trigger pipeline

**Solutions:**
1. **Check if `.gitlab-ci.yml` exists:**
   ```bash
   ls -la api-gateway/.gitlab-ci.yml
   ls -la service1/.gitlab-ci.yml
   ls -la service2/.gitlab-ci.yml
   ```

2. **Check branch name:**
   - Pipeline runs on: `main`, `master`, `develop`, `merge_requests`, `tags`
   - If you're on a different branch, it won't run

3. **Check GitLab CI/CD is enabled:**
   - Go to **Settings** → **CI/CD** → **General pipelines**
   - Make sure "CI/CD" is enabled

### Issue 2: Build Stage Fails

**Symptoms:**
- Pipeline runs but build job fails
- Error: "Cannot connect to Docker daemon"

**Solutions:**
1. **Check Docker Hub credentials:**
   - Verify `DOCKER_HUB_USER` and `DOCKER_HUB_TOKEN` are set correctly
   - Token must have write permissions

2. **Check image name:**
   - In `.gitlab-ci.yml`, verify `IMAGE_NAME` matches your Docker Hub username
   - For API Gateway: `wrakash/sky-gateway`
   - For Service1: `wrakash/sky-service1`
   - For Service2: `wrakash/sky-service2`

### Issue 3: Test Stage Fails

**Symptoms:**
- Lint or test commands fail

**Solutions:**
1. **Run tests locally first:**
   ```bash
   cd api-gateway
   npm run lint
   npm run test
   ```

2. **Fix any errors locally before pushing**

### Issue 4: Deploy Stage Fails

**Symptoms:**
- Build succeeds but deploy fails
- Error: "KUBECONFIG not set"

**Solutions:**
1. **Deploy stage is manual** - you need to trigger it manually in GitLab UI
2. **KUBECONFIG is optional** - if not set, deploy job will skip (this is OK)
3. **For automatic deployment, use ArgoCD instead** (recommended)

---

## ✅ Success Indicators

Your CI/CD is working when:

- [x] **Pipelines appear in GitLab** after pushing code
- [x] **Test stage passes** (green checkmark)
- [x] **Build stage passes** and creates Docker image
- [x] **Docker images appear on Docker Hub** with correct tags
- [x] **No errors in pipeline logs**

---

## 🧪 Quick Test Script

Run this to quickly test your CI/CD:

```bash
# Navigate to project root
cd E:\kube

# Make a test change to API Gateway
cd api-gateway
echo "// CI/CD test - $(date)" >> src/main.ts

# Commit and push
git add .
git commit -m "test: verify CI/CD pipeline"
git push origin main

# Then go to GitLab and watch the pipeline run!
```

**Expected Timeline:**
- 0-30 seconds: Pipeline starts
- 1-2 minutes: Test stage completes
- 3-5 minutes: Build stage completes (Docker build + push)
- Check Docker Hub: New image should appear

---

## 📊 Pipeline Status Commands

**Check recent commits:**
```bash
git log --oneline -5
```

**Check if code is pushed:**
```bash
git status
git log origin/main..HEAD  # Shows unpushed commits
```

**View pipeline in browser:**
```bash
# Get your GitLab project URL
git remote get-url origin

# Then open in browser and go to: <url>/-/pipelines
```

---

## 🔗 Useful Links

- **GitLab Pipelines:** `https://gitlab.com/your-username/your-repo/-/pipelines`
- **Docker Hub:** `https://hub.docker.com/u/wrakash`
- **GitLab CI/CD Docs:** https://docs.gitlab.com/ee/ci/

---

## 🎯 Next Steps After Verification

Once your CI/CD is working:

1. **Set up ArgoCD** for automatic deployment (see `COMPLETE-SETUP-GUIDE.md`)
2. **Configure webhooks** for faster sync
3. **Add more tests** to catch issues early
4. **Set up notifications** (Slack, email) for pipeline status

---

**Need Help?** Check the pipeline logs in GitLab for detailed error messages!

