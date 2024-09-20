FROM mcr.microsoft.com/openjdk/jdk:17-ubuntu
VOLUME /tmp
COPY target/email-processor.jar app.jar
COPY target/agent/applicationinsights-agent.jar applicationinsights-agent.jar
ENTRYPOINT ["java", "-javaagent:applicationinsights-agent.jar", "-jar", "/app.jar"]
