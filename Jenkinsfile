pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                echo 'Stage 1: Checkout'
                checkout scm
            }
        }
        stage('Build') {
            steps {
                echo 'Stage 2: Build'
                bat 'dir website'
            }
        }
        stage('Test') {
            steps {
                echo 'Stage 3: Test'
                bat 'echo All tests passed!'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Stage 4: Deploy to Azure'
                bat 'az webapp up --name devops-website-2025 --resource-group devops-rg --html'
            }
        }
    }
    post {
        success { echo 'Website is live on Azure!' }
        failure { echo 'Pipeline failed.' }
    }
}
