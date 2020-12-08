FROM openjdk:11-jre-slim
COPY build/libs/spring-music-1.0.jar /app/
COPY dd-java-agent.jar /app/
EXPOSE 8080:8080
WORKDIR /app

CMD java -javaagent:dd-java-agent.jar -jar spring-music-1.0.jar
