FROM openjdk:11
ADD build/libs/hello_world-0.0.1-SNAPSHOT.jar hello_world.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","hello_world.jar"," --server.port=8080"]
