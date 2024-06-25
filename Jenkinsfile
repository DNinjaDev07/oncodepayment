#! /usr/bin/env groovy
pipeline{
     agent any
     tools {
        maven 'maven-3.6'
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
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]){
                        sh "docker build -t danieloncode/oncodepayment:${IMAGE_NAME} ."
                        sh "echo $PASSWORD | docker login -u $USERNAME --password-stdin"
                        sh "docker push danieloncode/oncodepayment:${IMAGE_NAME}"
                    }
                }
                }
        }
        stage("deploy"){
            steps{
                script{
                    echo "deploying the application..."
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
                         
                        sh "git remote set-url origin https://${USERNAME}:${PASSWORD}@https://github.com/DNinjaDev07/oncodepayment.git"
                        sh 'git commit -am "ci: version update"'
                        sh 'git push origin HEAD:master'
                }
            }
        }
     }
}
}
