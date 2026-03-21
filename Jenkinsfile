pipeline {
    agent any

    options {
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }

    stages {
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