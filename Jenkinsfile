#! /usr/bin/env groovy
pipeline{
     agent any
     tools {
        maven 'maven-3.6'
     }
     environment{
        DOCKER_REPO_SERVER = '823359858998.dkr.ecr.us-east-1.amazonaws.com'
        DOCKER_REPO = "${DOCKER_REPO_SERVER}/oncode-payment"
        AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key')
        APP_NAME = 'oncodepayment'
     }
     stages{
        stage("increment version"){
            steps{
                script{
                    echo 'incrementing the app version...'
                    sh 'mvn build-helper:parse-version versions:set \
                    -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                    versions:commit'
                    def newpom_matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = newpom_matcher[1][1]
                    echo env.IMAGE_NAME
                    env.IMAGE_NAME = "$version-$BUILD_NUMBER"
                }
            }
        }
        stage("build jar"){
            steps{
                script{
                    echo "building the application"
                    sh 'mvn clean package'
                }
                }
        }
        stage("build image"){
            steps{
                script{
                    echo "building the docker image"
                    withCredentials([usernamePassword(credentialsId: 'ecr-credentials', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]){
                        sh "docker build -t ${DOCKER_REPO}:${IMAGE_NAME} ."
                        sh "echo $PASSWORD | docker login -u $USERNAME --password-stdin ${DOCKER_REPO_SERVER}"
                        sh "docker push ${DOCKER_REPO}:${IMAGE_NAME}"
                    }
                }
                }
        }
        stage("deploy"){
            steps{
                script{
                    echo "deploying the application..."
                    sh 'envsubst < Kubernetes/deployment.yaml | kubectl apply -f -'
                    sh 'envsubst < Kubernetes/service.yaml | kubectl apply -f -'
                }
            }
        }
        stage("commit version update"){
            steps{
                script{
                    withCredentials([usernamePassword(credentialsId: 'github-credentials', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]){
                        sh 'git config --global user.email "jenkins@oncode.com"'
                        sh 'git config --global user.name "jenkins"'

                        sh 'git status'
                        sh 'git branch'
                        sh 'git config --list'
                         
                        sh "git remote set-url origin https://${PASSWORD}@github.com/DNinjaDev07/oncodepayment.git"

                        sh 'git commit -am "ci: version update"'
                        sh 'git push origin HEAD:master'
                }
            }
        }
     }
}
}
