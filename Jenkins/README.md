# Jenkins deployment for CI/CD

The Jenkins file in [Jenkinsfile](/Jenkinsfile) has 4 stages.

- Increment pom.xml version 
- Build JAR file
- Build docker image and push to AWS Elastic Container Registry (ECR).
- Recommit pom.xml to Github that has updated version.
- Deploy to AWS EKS Cluster
