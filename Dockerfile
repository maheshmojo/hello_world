FROM openjdk:11
EXPOSE 9090
COPY build/libs/hello_world-0.0.1-SNAPSHOT.jar /demo.jar
CMD ["java","-jar","demo.jar"]
