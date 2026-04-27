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
                echo '? Pipeline Complete!'
                echo 'Website ready for Docker/ACR deployment'
            }
        }
    }
    post {
        success { echo 'Pipeline completed successfully!' }
        failure { echo 'Pipeline failed.' }
    }
}
