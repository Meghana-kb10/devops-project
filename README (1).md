## 🌐 Live Website
👉 [Click here to view](https://yellow-mud-0f0a4e90f.7.azurestaticapps.net)



# 🚀 DevOps Project — Jenkins + Azure Deployment

A complete CI/CD pipeline that automatically deploys a website to **Microsoft Azure** using **Jenkins**.

---

## 📁 Project Structure

```
devops-project/
├── website/
│   └── index.html          ← The website
├── Dockerfile              ← Containerizes the website with Nginx
├── Jenkinsfile             ← CI/CD pipeline definition
├── azure/
│   └── azure-setup.sh      ← One-time Azure infrastructure setup
└── README.md               ← This file
```

---

## 🛠️ Prerequisites

Install these tools on your machine or Jenkins server:
- [Docker](https://docs.docker.com/get-docker/)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Jenkins](https://www.jenkins.io/doc/book/installing/) (with Docker Pipeline plugin)
- A [GitHub](https://github.com) account
- A [Microsoft Azure](https://azure.microsoft.com/free) account (free tier works!)

---

## 📋 Step-by-Step Setup

### Step 1 — Push Project to GitHub
```bash
git init
git add .
git commit -m "Initial commit: DevOps website project"
git remote add origin https://github.com/YOUR_USERNAME/devops-project.git
git push -u origin main
```

### Step 2 — Set Up Azure Infrastructure
```bash
chmod +x azure/azure-setup.sh
./azure/azure-setup.sh
```
This script creates:
- A Resource Group
- Azure Container Registry (ACR)
- App Service Plan

**Save the credentials it prints** — you'll need them in Step 3.

### Step 3 — Configure Jenkins Credentials

In Jenkins → **Manage Jenkins → Credentials → System → Global**:

| ID | Type | Details |
|----|------|---------|
| `acr-credentials` | Username + Password | ACR username & password from Step 2 |
| `azure-service-principal` | Username + Password + Secret | Service Principal from Step 2 |

### Step 4 — Create Jenkins Pipeline Job

1. New Item → **Pipeline**
2. Name it `devops-website`
3. Under **Pipeline**:
   - Definition: `Pipeline script from SCM`
   - SCM: `Git`
   - Repository URL: your GitHub repo URL
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
4. Save

### Step 5 — Set Up GitHub Webhook (Auto-trigger)

In your GitHub repo → **Settings → Webhooks → Add webhook**:
- Payload URL: `http://YOUR_JENKINS_IP:8080/github-webhook/`
- Content type: `application/json`
- Events: `Just the push event`

### Step 6 — Run the Pipeline!

Click **Build Now** in Jenkins — or push any code change to GitHub to trigger it automatically.

---

## 🌐 After Deployment

Your website will be live at:
```
https://devops-website.azurewebsites.net
```

---

## 🔄 How the CI/CD Pipeline Works

```
Git Push → GitHub Webhook → Jenkins Triggered
    ↓
Stage 1: Checkout code
    ↓
Stage 2: docker build (create image)
    ↓
Stage 3: Test (health check on port 8081)
    ↓
Stage 4: Push image to Azure Container Registry
    ↓
Stage 5: Deploy to Azure App Service
    ↓
✅ Website is LIVE on Azure!
```

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| Docker not found in Jenkins | Install Docker on Jenkins server, add jenkins user to docker group |
| Azure login fails | Check Service Principal credentials in Jenkins |
| ACR push fails | Verify ACR name is globally unique, check credentials |
| App not accessible | Check Azure App Service logs: `az webapp log tail --name devops-website --resource-group devops-rg` |

---

## 🧹 Cleanup (to avoid Azure charges)

```bash
az group delete --name devops-rg --yes --no-wait
```

---

## 👨‍💻 Team

Built as part of a DevOps assignment demonstrating Jenkins CI/CD + Azure Cloud deployment.
