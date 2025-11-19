# 🚀 Quick Guide: Push to Single GitHub Repository

**Repository:** https://github.com/Shivanikumari2001/my-devops-project.git

---

## ✅ **What I've Done**

1. ✅ Updated all ArgoCD configs to point to single repo
2. ✅ Added `config.yaml` to `.gitignore` (contains sensitive data)
3. ✅ Created push guide

---

## 🎯 **Quick Push Commands**

### **Step 1: Set Remote (if not already set)**

```powershell
cd E:\kube

# Remove existing remote (if any)
git remote remove origin 2>$null

# Add your GitHub repo
git remote add origin https://github.com/Shivanikumari2001/my-devops-project.git

# Verify
git remote -v
```

### **Step 2: Remove Sensitive Files from Git**

```powershell
# Remove config.yaml from staging (already in .gitignore now)
git rm --cached config.yaml
```

### **Step 3: Commit Everything**

```powershell
# Add all files (respects .gitignore)
git add .

# Check what will be committed
git status

# Commit
git commit -m "Initial commit: Complete microservices project with CI/CD and ArgoCD"
```

### **Step 4: Push to GitHub**

```powershell
# Push to main branch
git branch -M main
git push -u origin main
```

**When prompted:**
- **Username:** `Shivanikumari2001`
- **Password:** Use a [Personal Access Token](https://github.com/settings/tokens)

---

## 🔐 **Get GitHub Personal Access Token**

1. Go to: https://github.com/settings/tokens
2. Click **"Generate new token"** → **"Generate new token (classic)"**
3. Name: `devops-project`
4. Select scopes: ✅ `repo` (Full control)
5. Click **"Generate token"**
6. **Copy the token** - use it as your password

---

## ✅ **Verify After Push**

Visit: https://github.com/Shivanikumari2001/my-devops-project

You should see:
- ✅ `service1/` folder
- ✅ `service2/` folder
- ✅ `api-gateway/` folder
- ✅ `scripts/` folder
- ✅ All documentation files
- ❌ NO `config.yaml` (protected by .gitignore)

---

## 📋 **What Will Be Pushed**

✅ **Included:**
- All source code
- Dockerfiles
- Helm charts
- ArgoCD configs
- CI/CD configs (.gitlab-ci.yml)
- Scripts
- Documentation

❌ **Excluded (via .gitignore):**
- `node_modules/`
- `dist/`
- `config.yaml` (sensitive)
- Database files (`.db`)
- IDE files

---

## 🔄 **Future Updates**

```powershell
git add .
git commit -m "Your commit message"
git push origin main
```

---

## 🎉 **Done!**

After pushing, ArgoCD will automatically detect and sync all three services from the single repository!

**Full guide:** See `SINGLE-REPO-PUSH-GUIDE.md` for detailed instructions.

