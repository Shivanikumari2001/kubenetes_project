#!/bin/bash

# Script to configure ArgoCD with GitHub credentials from config.yaml

set -e

echo "🔐 Configuring ArgoCD GitHub Access..."
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}✗${NC} kubectl is not installed or not in PATH"
    exit 1
fi

# Check if we can connect to Kubernetes cluster
if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}✗${NC} Cannot connect to Kubernetes cluster"
    echo "Please ensure kubectl is configured correctly"
    exit 1
fi

# Check if config.yaml exists
if [ ! -f "config.yaml" ]; then
    echo -e "${RED}✗${NC} config.yaml not found"
    echo "Please ensure config.yaml exists in the current directory"
    exit 1
fi

# Read credentials from config.yaml
echo -e "${BLUE}Reading credentials from config.yaml...${NC}"

# Extract GitHub username and PAT from config.yaml
GITHUB_USERNAME=$(grep -A 2 "^github:" config.yaml | grep "username:" | sed 's/.*username: *"\([^"]*\)".*/\1/')
GITHUB_PAT=$(grep -A 2 "^github:" config.yaml | grep "pat:" | sed 's/.*pat: *"\([^"]*\)".*/\1/')

if [ -z "$GITHUB_USERNAME" ] || [ -z "$GITHUB_PAT" ]; then
    echo -e "${RED}✗${NC} Could not extract GitHub credentials from config.yaml"
    exit 1
fi

echo -e "${GREEN}✓${NC} Found GitHub username: $GITHUB_USERNAME"
echo -e "${GREEN}✓${NC} Found GitHub PAT: ${GITHUB_PAT:0:10}..."
echo ""

# Extract repository URLs from config.yaml
echo -e "${BLUE}Extracting repository URLs from config.yaml...${NC}"
API_GATEWAY_REPO=$(grep -A 1 "api-gateway:" config.yaml | grep "repo:" | sed 's/.*repo: *"\([^"]*\)".*/\1/')
SERVICE1_REPO=$(grep -A 1 "service1:" config.yaml | grep "repo:" | sed 's/.*repo: *"\([^"]*\)".*/\1/')
SERVICE2_REPO=$(grep -A 1 "service2:" config.yaml | grep "repo:" | sed 's/.*repo: *"\([^"]*\)".*/\1/')

if [ -z "$API_GATEWAY_REPO" ] || [ -z "$SERVICE1_REPO" ] || [ -z "$SERVICE2_REPO" ]; then
    echo -e "${RED}✗${NC} Could not extract repository URLs from config.yaml"
    exit 1
fi

echo -e "${GREEN}✓${NC} Found repositories:"
echo "   - $API_GATEWAY_REPO"
echo "   - $SERVICE1_REPO"
echo "   - $SERVICE2_REPO"
echo ""

# Check if secrets already exist
EXISTING_SECRETS=$(kubectl get secrets -n argocd -l argocd.argoproj.io/secret-type=repository -o name 2>/dev/null | wc -l | tr -d ' ')
if [ "$EXISTING_SECRETS" -gt 0 ]; then
    echo -e "${YELLOW}⚠${NC} Existing repository secrets found ($EXISTING_SECRETS)"
    read -p "Do you want to update them? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kubectl delete secrets -n argocd -l argocd.argoproj.io/secret-type=repository
        echo -e "${GREEN}✓${NC} Deleted existing repository secrets"
    else
        echo "Keeping existing secrets. Exiting."
        exit 0
    fi
fi

# Create individual ArgoCD repository secrets for each service
echo -e "${BLUE}Creating GitHub repository secrets in ArgoCD...${NC}"

# API Gateway repository secret
kubectl -n argocd create secret generic github-repo-api-gateway \
  --from-literal=type=git \
  --from-literal=url=$API_GATEWAY_REPO \
  --from-literal=username=$GITHUB_USERNAME \
  --from-literal=password=$GITHUB_PAT

kubectl -n argocd label secret github-repo-api-gateway \
  argocd.argoproj.io/secret-type=repository

# Service1 repository secret
kubectl -n argocd create secret generic github-repo-service1 \
  --from-literal=type=git \
  --from-literal=url=$SERVICE1_REPO \
  --from-literal=username=$GITHUB_USERNAME \
  --from-literal=password=$GITHUB_PAT

kubectl -n argocd label secret github-repo-service1 \
  argocd.argoproj.io/secret-type=repository

# Service2 repository secret
kubectl -n argocd create secret generic github-repo-service2 \
  --from-literal=type=git \
  --from-literal=url=$SERVICE2_REPO \
  --from-literal=username=$GITHUB_USERNAME \
  --from-literal=password=$GITHUB_PAT

kubectl -n argocd label secret github-repo-service2 \
  argocd.argoproj.io/secret-type=repository

# Also create a general secret for any other repositories under the user
kubectl -n argocd create secret generic github-creds \
  --from-literal=type=git \
  --from-literal=url=https://github.com/$GITHUB_USERNAME \
  --from-literal=username=$GITHUB_USERNAME \
  --from-literal=password=$GITHUB_PAT

kubectl -n argocd label secret github-creds \
  argocd.argoproj.io/secret-type=repository

echo -e "${GREEN}✓${NC} All GitHub repository secrets created"
echo ""

# Restart ArgoCD components to pick up new credentials
echo -e "${BLUE}Restarting ArgoCD components...${NC}"
kubectl rollout restart deployment argocd-repo-server -n argocd
kubectl rollout restart deployment argocd-server -n argocd

echo -e "${GREEN}✓${NC} ArgoCD components restarted"
echo ""

# Wait for pods to be ready
echo -e "${BLUE}Waiting for ArgoCD components to be ready...${NC}"
kubectl wait --for=condition=available --timeout=120s \
  deployment/argocd-repo-server -n argocd 2>/dev/null || true
kubectl wait --for=condition=available --timeout=120s \
  deployment/argocd-server -n argocd 2>/dev/null || true

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ GitHub Access Configured Successfully"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "ArgoCD can now access your private GitHub repositories!"
echo ""
echo "Next steps:"
echo "1. Apply updated ArgoCD applications:"
echo -e "   ${BLUE}./apply-argocd.sh${NC}"
echo ""
echo "2. Access ArgoCD UI:"
echo -e "   ${BLUE}./access-argocd-ui.sh${NC}"
echo ""
echo "3. Verify application sync status:"
echo -e "   ${BLUE}kubectl get applications -n argocd${NC}"
echo ""

