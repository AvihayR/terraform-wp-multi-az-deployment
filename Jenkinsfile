pipeline {
    agent any


    stages {

            stage('Build Docker Image') { 
                when { 
                    branch 'cicd' 
                } 
                steps { 
                     sh 'docker build -t avihayr/multi-az-wp:$GIT_COMMIT .'
                } 
            } 
        }
}