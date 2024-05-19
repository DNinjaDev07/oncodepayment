# Jenkins deployment for CI/CD

The Jenkins file in [Jenkinsfile](/Jenkinsfile) has 4 stages.

- Increment version 
- Build java jar
- Build docker image and push to docker hub.
- Recommit pom.xml to Github that has updated version.
