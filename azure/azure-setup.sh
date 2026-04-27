#!/bin/bash
# =============================================================
# azure-setup.sh
# One-time Azure infrastructure setup script
# Run this ONCE before your first Jenkins deployment
# =============================================================

set -e  # Exit on any error

# ---- CONFIGURATION (edit these) ----
RESOURCE_GROUP="devops-rg"
LOCATION="eastus"
ACR_NAME="devopsregistry"        # Must be globally unique!
APP_NAME="devops-website"        # Must be globally unique!
APP_PLAN="devops-plan"
# ------------------------------------

echo "🔐 Step 1: Login to Azure"
az login

echo ""
echo "📦 Step 2: Create Resource Group"
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION

echo ""
echo "🐳 Step 3: Create Azure Container Registry (ACR)"
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic \
  --admin-enabled true

# Get ACR credentials (save these for Jenkins!)
echo ""
echo "🔑 ACR Credentials (save these in Jenkins → Credentials):"
ACR_USER=$(az acr credential show --name $ACR_NAME --query username -o tsv)
ACR_PASS=$(az acr credential show --name $ACR_NAME --query passwords[0].value -o tsv)
echo "  ACR Login Server : ${ACR_NAME}.azurecr.io"
echo "  Username         : $ACR_USER"
echo "  Password         : $ACR_PASS"

echo ""
echo "📋 Step 4: Create App Service Plan"
az appservice plan create \
  --name $APP_PLAN \
  --resource-group $RESOURCE_GROUP \
  --sku B1 \
  --is-linux

echo ""
echo "🌐 Step 5: Create Azure Service Principal for Jenkins"
echo "  (This lets Jenkins deploy to Azure automatically)"
SP_OUTPUT=$(az ad sp create-for-rbac \
  --name "jenkins-devops-sp" \
  --role contributor \
  --scopes /subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP)

echo ""
echo "🔑 Service Principal Credentials (save in Jenkins → Credentials):"
echo $SP_OUTPUT | python3 -m json.tool

echo ""
echo "✅ Azure setup complete!"
echo ""
echo "📋 SUMMARY:"
echo "  Resource Group : $RESOURCE_GROUP"
echo "  ACR            : ${ACR_NAME}.azurecr.io"
echo "  App Name       : ${APP_NAME}.azurewebsites.net"
echo ""
echo "📌 NEXT STEPS:"
echo "  1. Save the ACR credentials in Jenkins → Manage Jenkins → Credentials"
echo "     ID: 'acr-credentials'"
echo "  2. Save the Service Principal in Jenkins → Credentials"
echo "     ID: 'azure-service-principal'"
echo "  3. Push your code to GitHub"
echo "  4. Create a Jenkins Pipeline job pointing to your repo"
echo "  5. Run the pipeline!"
