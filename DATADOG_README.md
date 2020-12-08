# build spring-music app
./gradlew clean assemble

# edit dockerfile to reflect path of spring-music.jar and version of jdk, etc

```
FROM openjdk:11-jre-slim
COPY build/libs/spring-music-1.0.jar /app/
COPY dd-java-agent.jar /app/
EXPOSE 8080:8080
WORKDIR /app
CMD java -javaagent:dd-java-agent.jar -jar spring-music-1.0.jar
```

# create image from dockerfile

docker build -t test/spring-music .

# create network
docker network create <NETWORK_NAME>

# run agent w/ apm enabled logging and debug enabled
docker run -d --name datadog-agent \
        --network <NETWORK_NAME> \
        -v /var/run/docker.sock:/var/run/docker.sock:ro \
        -v /proc/:/host/proc/:ro \
        -v /sys/fs/cgroup/:/host/sys/fs/cgroup:ro \
        -e DD_API_KEY="<YOUR_API_KEY>" \
        -e DD_APM_ENABLED=true \
        -e DD_APM_NON_LOCAL_TRAFFIC=true \
        -e DD_LOGS_ENABLED=true \
        -e DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL=true \
        -e DD_LOG_LEVEL="debug" \
        -p 8126:8126 \
        gcr.io/datadoghq/agent:latest

# run spring-music w/ env vars for agent host and port
docker run -d --name app \
              --network <NETWORK_NAME> \
              -p 8080:8080 \
              -e DD_AGENT_HOST="datadog-agent" \
              -e DD_TRACE_AGENT_PORT=8126 \
              test/spring-music:latest
