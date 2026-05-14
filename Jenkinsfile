pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    stages {
        stage("Clean") {
            agent {
                label 'linux'
            }

            steps {
                script {
                    sh '''
                    '''
                }
            }

            post {
                always {
                    cleanWs()
                }
            }
        }

        stage ("Build Docker") {
            agent {
                label "dockermain"
            }

            steps {
                script {
                    sh '''
                    #!/bin/bash

                    docker system prune -a -f

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
                label 'linux'
            }

            tools {
                jdk 'jdk17'
            }

            steps {
                script {
                    sh '''
                    #!/bin/bash
                    chmod +x localbuild.sh
                    RELEASE=1 ./localbuild.sh || true

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

                bat "dart compile exe -o outputs/server-x86_64-win.exe bin/server.dart"
                bat "dart compile exe -o outputs/dlocto.exe bin/backupOctocon.dart"
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