FROM mcr.microsoft.com/openjdk/jdk:17-ubuntu
VOLUME /tmp
ARG JAR_FILE
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]