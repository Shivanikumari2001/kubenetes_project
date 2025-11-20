# Quick Reference: Essential Commands

This is a quick reference guide with the most commonly used commands. For detailed explanations, see `COMPLETE-SETUP-GUIDE.md`.

---

## 🚀 Quick Start Commands

### Start Minikube
```bash
minikube start --nodes 3
eval $(minikube docker-env)  # Point Docker to Minikube
```

### Build Docker Images
```bash
cd service1 && docker build -t wrakash/service1:latest .
cd service2 && docker build -t wrakash/service2:latest .
cd api-gateway && docker build -t wrakash/api-gateway:latest .
```

### Push to Docker Hub
```bash
docker login
docker push wrakash/service1:latest
docker push wrakash/service2:latest
docker push wrakash/api-gateway:latest
```

### Deploy with Helm
```bash
helm install service1 ./service1/helm
helm install service2 ./service2/helm
helm install api-gateway ./api-gateway/helm
```

### Deploy with ArgoCD
```bash
kubectl apply -f service1/argocd/application.yaml
kubectl apply -f service2/argocd/application.yaml
kubectl apply -f api-gateway/argocd/application.yaml
```

---

## 📋 Daily Operations

### Check Status
```bash
# Pods
kubectl get pods

# Services
kubectl get svc

# Deployments
kubectl get deployments

# ArgoCD Apps
argocd app list
```

### View Logs
```bash
# Pod logs
kubectl logs <pod-name>

# Follow logs
kubectl logs -f <pod-name>

# Previous container logs
kubectl logs <pod-name> --previous
```

### Port Forwarding
```bash
# API Gateway
kubectl port-forward svc/api-gateway 3000:3000

# Service1
kubectl port-forward svc/service1 3001:3001

# Service2
kubectl port-forward svc/service2 3002:3002

# ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### Update Deployment
```bash
# Update Helm values
helm upgrade service1 ./service1/helm --set image.tag=v1.0.1

# ArgoCD will auto-sync if configured
argocd app sync service1
```

---

## 🔧 Troubleshooting

### Pod Issues
```bash
# Describe pod
kubectl describe pod <pod-name>

# Get pod events
kubectl get events --sort-by='.lastTimestamp'

# Execute into pod
kubectl exec -it <pod-name> -- /bin/sh
```

### Service Issues
```bash
# Check service endpoints
kubectl get endpoints

# Describe service
kubectl describe svc <service-name>

# Check service selector matches pods
kubectl get pods --show-labels
```

### ArgoCD Issues
```bash
# Check app status
argocd app get <app-name>

# Check repository
argocd repo list

# Force sync
argocd app sync <app-name> --force
```

### Minikube Issues
```bash
# Restart Minikube
minikube stop && minikube start --nodes 3

# Check status
minikube status

# View dashboard
minikube dashboard
```

---

## 🗑️ Cleanup

### Delete Helm Releases
```bash
helm uninstall service1
helm uninstall service2
helm uninstall api-gateway
```

### Delete ArgoCD Apps
```bash
kubectl delete application service1 -n argocd
kubectl delete application service2 -n argocd
kubectl delete application api-gateway -n argocd
```

### Delete Everything
```bash
# Delete all resources in default namespace
kubectl delete all --all

# Delete ArgoCD
kubectl delete namespace argocd

# Stop Minikube
minikube stop
minikube delete
```

---

## 📝 GitLab CI/CD

### Manual Pipeline Trigger
```bash
# Push code to trigger pipeline
git add .
git commit -m "Update service"
git push

# Or trigger via GitLab UI: CI/CD → Pipelines → Run Pipeline
```

### Check Pipeline Status
```bash
# Via GitLab UI: CI/CD → Pipelines
# Or via API
curl --header "PRIVATE-TOKEN: <your-token>" \
  "https://gitlab.com/api/v4/projects/<project-id>/pipelines"
```

---

## 🔐 Secrets Management

### Create Docker Registry Secret
```bash
kubectl create secret docker-registry regcred \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=wrakash \
  --docker-password=<password> \
  --docker-email=<email>
```

### Create Generic Secret
```bash
kubectl create secret generic my-secret \
  --from-literal=username=admin \
  --from-literal=password=secret123
```

---

## 📊 Monitoring

### Resource Usage
```bash
# Node resources
kubectl top nodes

# Pod resources
kubectl top pods

# All namespaces
kubectl top pods --all-namespaces
```

### Get ArgoCD Admin Password
```bash
# Linux/macOS
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Windows PowerShell
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | ForEach-Object { [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($_)) }
```

---

## 🌐 Access URLs

After port forwarding:
- **API Gateway:** http://localhost:3000
- **Service1 Health:** http://localhost:3000/service1/health
- **Service2 Health:** http://localhost:3000/service2/health
- **ArgoCD UI:** https://localhost:8080 (username: `admin`)

---

## 📚 Useful Aliases (Optional)

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Kubernetes aliases
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgd='kubectl get deployments'
alias kdp='kubectl describe pod'
alias kl='kubectl logs'
alias kpf='kubectl port-forward'

# Helm aliases
alias hls='helm list'
alias hst='helm status'
alias hup='helm upgrade'
alias hun='helm uninstall'

# ArgoCD aliases
alias al='argocd app list'
alias ag='argocd app get'
alias as='argocd app sync'
```

---

**Tip:** Bookmark this page for quick access to common commands!

