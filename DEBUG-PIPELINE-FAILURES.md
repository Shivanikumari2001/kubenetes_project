# Debug Pipeline Failures - Step by Step

## 🔍 Step 1: Check the Actual Error

**In GitLab:**
1. Go to **CI/CD** → **Pipelines**
2. Click on the **failed pipeline** (red X)
3. Click on the **failed job** (it will show which job failed)
4. **Scroll down** to see the error message
5. **Copy the error message** - this tells us exactly what's wrong

## 🚨 Common Errors and Fixes

### Error 1: "DOCKER_HUB_USER: variable is undefined"
**Fix:** Add CI/CD variables (see Step 2 below)

### Error 2: "Cannot connect to Docker daemon"
**Fix:** This is normal in GitLab CI - the Docker service should handle this. Check if `services: - docker:24-dind` is present.

### Error 3: "denied: requested access to the resource is denied"
**Fix:** Wrong Docker Hub credentials or token expired

### Error 4: "YAML syntax error"
**Fix:** There's a typo in `.gitlab-ci.yml` - check the file

### Error 5: "No stages/jobs for this pipeline"
**Fix:** The `only:` section might not match your branch name

## ✅ Step 2: Add CI/CD Variables (REQUIRED)

**This is the most common issue!**

1. Go to: **Settings** → **CI/CD** → **Variables** → **Expand**
2. Click **Add variable**
3. Add these two variables:

**Variable 1:**
- Key: `DOCKER_HUB_USER`
- Value: `wrakash`
- Type: Variable
- Environment scope: All
- Flags: ❌ Protected, ❌ Masked

**Variable 2:**
- Key: `DOCKER_HUB_TOKEN`
- Value: (get from https://hub.docker.com/settings/security)
- Type: Variable
- Environment scope: All
- Flags: ✅ Protected, ✅ Masked

**To get Docker Hub Token:**
1. Go to: https://hub.docker.com/settings/security
2. Click **"New Access Token"**
3. Name it: "GitLab CI"
4. Copy the token (you'll only see it once!)
5. Paste it as `DOCKER_HUB_TOKEN` value

## 🔄 Step 3: Push Updated .gitlab-ci.yml

I've updated the file to handle missing variables better. Push it:

```bash
git add .gitlab-ci.yml
git commit -m "fix: improve error handling in CI/CD"
git push origin main
```

## 🧪 Step 4: Test with Minimal Pipeline

If it still fails, let's test with a minimal pipeline first:

Create a simple test:

```yaml
test-pipeline:
  stage: build
  image: alpine:latest
  script:
    - echo "Pipeline is working!"
    - echo "DOCKER_HUB_USER is: ${DOCKER_HUB_USER:-NOT SET}"
```

This will at least show if GitLab can parse your YAML.

## 📊 Step 5: Check Pipeline Logs

**What to look for in logs:**

1. **At the top:** Job name and stage
2. **In the middle:** Commands being executed
3. **At the bottom:** The actual error (this is what matters!)

**Common log patterns:**
- `$ docker login` → Docker authentication issue
- `npm ERR!` → npm/dependency issue
- `YAML syntax error` → File format issue
- `variable is undefined` → Missing CI/CD variable

## 🎯 Quick Checklist

Before asking for help, check:

- [ ] Did you add `DOCKER_HUB_USER` variable?
- [ ] Did you add `DOCKER_HUB_TOKEN` variable?
- [ ] Did you push the updated `.gitlab-ci.yml`?
- [ ] Did you check the actual error message in pipeline logs?
- [ ] Is your branch name `main` or `master`? (pipeline only runs on these)

## 🆘 Still Not Working?

**Share this information:**
1. Screenshot of the pipeline failure page
2. The error message from the failed job logs
3. Whether you added the CI/CD variables
4. Your branch name

This will help identify the exact issue!

