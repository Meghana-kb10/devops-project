// ============================================================
// Jenkinsfile — Declarative Pipeline
// Deploys website to Azure App Service via Docker
// ============================================================

pipeline {

    agent any

    environment {
        // --- Docker / ACR Configuration ---
        ACR_NAME             = 'devopsregistry'
        IMAGE_NAME           = 'devops-website'
        IMAGE_TAG            = "${env.BUILD_NUMBER}"

        // --- Credentials (configured in Jenkins Credentials Manager) ---
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
        // STAGE 5: Cleanup
        // ----------------------------------------------------------
        stage('Cleanup Images') {
            steps {
                echo "🧹 Cleaning up local Docker images..."
                sh """
                    docker rmi ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG} || true
                    docker rmi ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:latest || true
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
            ║  ✅  BUILD SUCCESSFUL!                        ║
            ║  🐳 Image: ${ACR_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG} ║
            ║  📤 Pushed to ACR                             ║
            ╚══════════════════════════════════════════════╝
            """
        }
        failure {
            echo '❌ Pipeline failed! Check logs above for details.'
        }
    }
}
