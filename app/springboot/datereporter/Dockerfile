FROM openjdk:17-jdk-alpine

WORKDIR /app

COPY build/libs/datereporter-0.0.1-SNAPSHOT.jar datereporter.jar

ENTRYPOINT [ "java", "-jar", "datereporter.jar" ]
