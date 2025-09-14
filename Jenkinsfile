pipeline {
    agent any


    stages {

            stage('Hello Jenkins') { 
                when { 
                    branch 'cicd' 
                } 
                steps { 
                    script { 
                        ls 
                        echo hello world
                    } 
                } 
            } 
        }
}