pipeline{
     agent any
     tools {
        maven 'maven-3.6'
     }
     stages{
        stage("build jar"){
            steps{
                script{
                    echo "building the application"
                    sh 'mvn package'

                }
                }
        }
        stage("build image"){
            steps{
                script{
                    echo "building the docker image"
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]){
                        sh 'docker build -t danieloncode/oncodepayment:2.1 .'
                        sh "echo $PASSWORD | docker login -u $USERNAME --password-stdin"
                        sh 'docker push danieloncode/oncodepayment:2.1'
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
