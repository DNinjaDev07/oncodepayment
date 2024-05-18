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
                    -DnewVersion=\\\${parsedVersion.nextMajorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.incrementalVersion} \
                    versions:commit'
                    def newpom_matcher = readFile('pom.xml') =~ '<version>(.+)</version>'
                    def version = newpom_matcher[0][1]
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
     }
}
