pipeline {
    agent any


    stages {
        // stage('Checkout') {
        //         dir('wordpress') {
        //             git branch: 'main', url: 'git@github.com:me/wordpress-app.git'
        //         }
        //     }

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