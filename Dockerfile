FROM openjdk:17
ADD target/oncodepayment-*.jar app.jar
ENTRYPOINT ["java","-jar", "/app.jar"]