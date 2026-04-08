pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    stages {

        stage ("Build Docker") {
            agent {
                label "dockermain"
            }

            steps {
                script {
                    sh '''
                    #!/bin/bash

                    docker build -t git.zontreck.com/packages/switchboard:builder docker/build-helper
                    docker push git.zontreck.com/packages/switchboard:builder

                    docker build -t git.zontreck.com/packages/switchboard:latest "$(pwd)"
                    docker push git.zontreck.com/packages/switchboard:latest

                    '''
                }
            }

            post {
                always {
                    cleanWs()
                }
            }
        }
        
        stage ("Build Linux") {
            agent {
                label 'dockermain'
            }

            steps {
                script {
                    sh '''
                    #!/bin/bash
                    chmod +x tools/build.sh
                    tools/build.sh || true

                    cd server
                    tar -cvf ../outputs/cdnserver.tgz .
                    cd ..
                    '''
                }
            }

            post {
                always {
                    archiveArtifacts artifacts: "outputs/*"
                    cleanWs()
                }
            }
        }

        stage ("Build Windows") {
            agent {
                label "windows"
            }

            steps {
                bat "flutter pub get"
                bat "flutter build windows"
                bat "mkdir outputs"
                dir ("build/windows/x64/runner/Release") {
                    bat "tar -cvf ../../../../../outputs/windows.tgz ."
                }
            }

            post {
                always {
                    archiveArtifacts artifacts: "outputs/*"
                    cleanWs()
                }
            }
        }

    }
}