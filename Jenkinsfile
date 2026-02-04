def version = "0.8.9" 
pipeline {
    options {
        buildDiscarder(logRotator(numToKeepStr: "10")) // Retain history on the last 10 builds
        //slva 1 and 2: old docker version
        //slave4: no docker installed, only alias to podman
        gitLabConnection('gitlab-connection')
    }
    agent { label 'Jenkins-slave4' }
    stages {
        stage('Show Agent Info') {
            steps {
                script {
                    echo "Running on agent: ${env.NODE_NAME}"
                }
            }
        }
        stage('Build Docker Image') {
            when {
                anyOf {
                    branch 'prod';
                    branch 'develop';
                }
            }
            steps {
                script {
                    if (env.BRANCH_NAME == 'develop') {
                        version = "${version}-SNAPSHOT"
                    }

                    sh 'docker rm -f otd-dashboard-front || true'
                    sh "docker build -t otd-dashboard-front:${version} . -f Dockerfile"
                }
            }
        }

        stage('Push Docker Image') {
            when {
                anyOf {
                    branch 'prod';
                    branch 'develop';
                }
            }
            steps {
                script {
                    docker.withRegistry("https://registry.udd.attijariwafa.net", "otd-dashboard") {
                        sh "echo pushing image"
                        sh "docker tag otd-dashboard-front:${version} registry.udd.attijariwafa.net/otd-labs/otd-dashboard-front:${version}"
                        sh "docker push registry.udd.attijariwafa.net/otd-labs/otd-dashboard-front:${version}"
                        sh "docker rmi registry.udd.attijariwafa.net/otd-labs/otd-dashboard-front:${version}"
                    }
                }
            }
        }
        stage('Deploy to Openshift Dev') {
            when {
                anyOf {
                    branch 'develop';
                }
            }
            steps {
                script {
                    sh "echo deploy"
                    // deployToOpenshift("dev-otd-labs-services", "otd-dashboard-front", version)
                }
            }
        }
    }
    post {
        success {
            echo "Success"
            mail to: 'b.malki@attijariwafa.com',
                 subject: "Pipeline Success: ${currentBuild.fullDisplayName}",
                 body: """
                 The pipeline ${currentBuild.fullDisplayName} Completed Successfully (Took ${currentBuild.durationString}).
                 For more infos see: ${env.BUILD_URL}
                """
        }
        unstable {
            echo "Unstable"
            mail to: 'b.malki@attijariwafa.com',
                 subject: "Unstable Pipeline: ${currentBuild.fullDisplayName}",
                 body: """
                 The pipeline ${currentBuild.fullDisplayName} is Unstable (Took ${currentBuild.durationString}).
                 For more infos see: ${env.BUILD_URL}
                """
        }
        failure {
            echo 'Failed'
            mail to: 'b.malki@attijariwafa.com',
                 subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
                 body: """
                 Something is wrong with Job: ${currentBuild.fullDisplayName}, Build Num: ${env.BUILD_NUMBER} (Took ${currentBuild.durationString}).
                 For more infos see: ${env.BUILD_URL}
                 """
        }
    }
}

def deployToOpenshift(appName, imageName, imageVersion) {
    withCredentials([string(credentialsId: "jenkins-argocd-llm-poc-18-07-2023", variable: 'ARGOCD_AUTH_TOKEN')]) {
        docker.withRegistry("https://registry.udd.attijariwafa.net:443", "otd-dashboard") {
            sh "docker pull registry.udd.attijariwafa.net:443/otd-labs/${imageName}:${imageVersion}"
        }
        IMAGE_DIGEST = sh(
            script: "docker image inspect registry.udd.attijariwafa.net:443/otd-labs/${imageName}:${imageVersion} -f '{{join .RepoDigests \",\"}}'",
            returnStdout: true
        ).trim()
        sh "docker rmi registry.udd.attijariwafa.net:443/otd-labs/${imageName}:${imageVersion}"
        echo IMAGE_DIGEST
        // sh "ARGOCD_SERVER=awb-argocd-server-argocd.apps.ocpdev.attijariwafa.net argocd --grpc-web app set ${appName} --kustomize-image ${IMAGE_DIGEST} --insecure"
        // sh "ARGOCD_SERVER=awb-argocd-server-argocd.apps.ocpdev.attijariwafa.net argocd --grpc-web app sync ${appName} --prune --force --insecure"
    }
}
