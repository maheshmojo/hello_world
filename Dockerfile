FROM openjdk:11
ADD build/libs/hello_world-0.0.1-SNAPSHOT.jar app2.jar

ENTRYPOINT ["java","-jar","app2.jar"]