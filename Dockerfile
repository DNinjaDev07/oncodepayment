FROM openjdk:17
ADD target/oncodepayment-*.jar app.jar
EXPOSE 8098
ENTRYPOINT ["java","-jar", "/app.jar"]