// ============================================================
// Jenkinsfile — Declarative Pipeline
// Deploys website to Azure App Service via Docker
// ============================================================

pipeline {

    agent any

    environment {
        // --- Azure Configuration ---
        AZURE_RESOURCE_GROUP = 'devops-rg'
        AZURE_APP_NAME       = 'devops-website'
        AZURE_LOCATION       = 'eastus'

        // --- Docker / ACR Configuration ---
        ACR_NAME             = 'devopsregistry'
        IMAGE_NAME           = 'devops-website'
        IMAGE_TAG            = "${env.BUILD_NUMBER}"

        // --- Credentials (configured in Jenkins Credentials Manager) ---
        AZURE_CREDENTIALS    = credentials('azure-service-principal')
        ACR_CREDENTIALS      = credentials('acr-credentials')
    }

    stages {

        // ----------------------------------------------------------
        // STAGE 1: Checkout source code
        // ----------------------------------------------------------
        stage('Checkout') {
            steps {
                echo '📥 Checking out source code from GitHub...'
                checkout scm
            }
        }

        // ----------------------------------------------------------
        // STAGE 2: Build Docker Image
        // ----------------------------------------------------------
        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"
                sh """
                    docker build \
                        -t ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG} \
                        -t ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:latest \
                        .
                """
            }
        }

        // ----------------------------------------------------------
        // STAGE 3: Test
        // ----------------------------------------------------------
        stage('Test') {
            steps {
                echo '🧪 Running tests...'
                sh """
                    # Start container for testing
                    docker run -d --name test-container -p 8081:80 \
                        ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}
                    
                    # Wait for container to be ready
                    sleep 5
                    
                    # Health check: verify the site responds with HTTP 200
                    STATUS=\$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081)
                    echo "HTTP Status: \$STATUS"
                    
                    if [ "\$STATUS" -ne 200 ]; then
                        echo "❌ Health check failed! Status: \$STATUS"
                        docker stop test-container && docker rm test-container
                        exit 1
                    fi
                    
                    echo "✅ Health check passed!"
                    docker stop test-container && docker rm test-container
                """
            }
        }

        // ----------------------------------------------------------
        // STAGE 4: Push to Azure Container Registry (ACR)
        // ----------------------------------------------------------
        stage('Push to ACR') {
            steps {
                echo "📤 Pushing image to Azure Container Registry..."
                sh """
                    # Login to ACR
                    echo ${ACR_CREDENTIALS_PSW} | docker login \
                        ${ACR_NAME}.azurecr.io \
                        -u ${ACR_CREDENTIALS_USR} \
                        --password-stdin
                    
                    # Push both tags
                    docker push ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:latest
                    
                    echo "✅ Image pushed to ACR successfully"
                """
            }
        }

        // ----------------------------------------------------------
        // STAGE 5: Deploy to Azure App Service
        // ----------------------------------------------------------
        stage('Deploy to Azure') {
            steps {
                echo "🚀 Deploying to Azure App Service..."
                sh """
                    # Login to Azure using Service Principal
                    az login --service-principal \
                        -u ${AZURE_CREDENTIALS_USR} \
                        -p ${AZURE_CREDENTIALS_PSW} \
                        --tenant ${AZURE_CREDENTIALS_TENANT}
                    
                    # Create Resource Group (if it doesn't exist)
                    az group create \
                        --name ${AZURE_RESOURCE_GROUP} \
                        --location ${AZURE_LOCATION} || true
                    
                    # Create App Service Plan (if it doesn't exist)
                    az appservice plan create \
                        --name devops-plan \
                        --resource-group ${AZURE_RESOURCE_GROUP} \
                        --sku B1 \
                        --is-linux || true
                    
                    # Create or update Web App with the new Docker image
                    az webapp create \
                        --resource-group ${AZURE_RESOURCE_GROUP} \
                        --plan devops-plan \
                        --name ${AZURE_APP_NAME} \
                        --deployment-container-image-name \
                            ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG} || \
                    az webapp config container set \
                        --name ${AZURE_APP_NAME} \
                        --resource-group ${AZURE_RESOURCE_GROUP} \
                        --docker-custom-image-name \
                            ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG} \
                        --docker-registry-server-url \
                            https://${ACR_NAME}.azurecr.io \
                        --docker-registry-server-user ${ACR_CREDENTIALS_USR} \
                        --docker-registry-server-password ${ACR_CREDENTIALS_PSW}
                    
                    echo "✅ Deployment complete!"
                    echo "🌐 Live at: https://${AZURE_APP_NAME}.azurewebsites.net"
                """
            }
        }
    }

    // ----------------------------------------------------------
    // Post-build actions
    // ----------------------------------------------------------
    post {
        success {
            echo """
            ╔══════════════════════════════════════════════╗
            ║  ✅  BUILD & DEPLOY SUCCESSFUL               ║
            ║  🌐  https://${AZURE_APP_NAME}.azurewebsites.net  ║
            ╚══════════════════════════════════════════════╝
            """
        }
        failure {
            echo '❌ Pipeline failed! Check logs above for details.'
        }
        always {
            // Clean up local Docker images to save disk space
            sh """
                docker rmi ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG} || true
                docker rmi ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:latest || true
            """
            echo '🧹 Cleanup complete.'
        }
    }
}
