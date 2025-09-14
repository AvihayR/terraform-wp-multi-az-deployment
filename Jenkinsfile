pipeline {
    agent any


    stages {

            stage('Hello Jenkins') { 
                when { 
                    branch 'cicd' 
                } 
                steps { 
                     sh '''
                        ls -l
                        echo Hello Jenkins
                     '''
                } 
            } 
        }
}