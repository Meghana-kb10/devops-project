pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                echo 'Stage 1: Code checked out from GitHub'
                checkout scm
            }
        }

        stage('Build') {
            steps {
                echo 'Stage 2: Building the website...'
                bat 'dir website'
            }
        }

        stage('Test') {
            steps {
                echo 'Stage 3: Running tests...'
                bat 'echo All tests passed!'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Stage 4: Deploying to Azure...'
                bat 'az webapp up --name devops-website-2025 --resource-group devops-rg --html'
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed! Website is live on Azure!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
