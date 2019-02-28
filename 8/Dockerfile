FROM maven:3.6.0-jdk-8-alpine AS build

WORKDIR /build

COPY pom.xml pom.xml

COPY src /build/src

COPY .git .git

RUN mvn clean package

FROM openjdk:8-jre-slim

ARG DEFAULT_JAVA_OPTIONS="-Xmx300M -server"

LABEL maintainer="gs-w_eto_eb_federal_employees@usgs.gov"

ENV artifact_version=0.0.1-SNAPSHOT

ENV USER=spring
ENV HOME=/home/$USER
ENV SPRING_CLOUD_CONFIG_ENABLED=false
ENV TOMCAT_CHAIN_PATH=$HOME/tomcat-wildcard-ssl.chain
ENV TOMCAT_CERT_PATH=$HOME/tomcat-wildcard-ssl.crt
ENV TOMCAT_KEY_PATH=$HOME/tomcat-wildcard-ssl.key
ENV JAVA_TRUSTSTORE=$HOME/cacerts
ENV JAVA_TRUSTSTORE_PASS=changeit
ENV JAVA_OPTIONS=$DEFAULT_JAVA_OPTIONS
ENV HEALTH_CHECK_ENDPOINT=actuator/health
ENV HEALTHY_RESPONSE_CONTAINS={"status":"UP"}
ENV springFrameworkLogLevel=info
ENV SECURITY_REQUIRESSL=true
ENV SERVER_PORT=8443
ENV serverContextPath=/
ENV SERVER_SSL_KEYSTORE=$HOME/localkeystore.pkcs12
ENV SERVER_SSL_KEYSTOREPASSWORD=changeme
ENV SERVER_SSL_KEYALIAS=tomcat
ENV LAUNCH_APP_SCRIPT=$HOME/launch-app.sh

RUN apt-get update && \
  apt-get install --no-install-recommends --no-upgrade curl netcat -y && \
  rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos "" -u 1000 $USER

WORKDIR $HOME
COPY --chown=1000:1000 entrypoint.sh entrypoint.sh
COPY --chown=1000:1000 launch-app.sh $LAUNCH_APP_SCRIPT
COPY --chown=1000:1000 java.security.properties java.security.properties
COPY --chown=1000:1000 pull-from-artifactory.sh pull-from-artifactory.sh
COPY --chown=1000:1000 --from=build /build/target/spring-boot-sample*.jar app.jar
RUN chmod +x pull-from-artifactory.sh entrypoint.sh $LAUNCH_APP_SCRIPT

USER $USER

# This is used for downstream containers that may need this scripting in order to
# orchestrate container startups.
# See: https://github.com/eficode/wait-for
RUN curl -o ./wait-for.sh https://raw.githubusercontent.com/eficode/wait-for/f71f8199a0dd95953752fb5d3f76f79ced16d47d/wait-for && \
  chmod +x ./wait-for.sh

CMD [ "./entrypoint.sh"]

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -k "https://127.0.0.1:${SERVER_PORT}${serverContextPath}${HEALTH_CHECK_ENDPOINT}" | grep -q ${HEALTHY_RESPONSE_CONTAINS} || exit 1

ONBUILD RUN echo "Removing sample app.jar..." && rm app.jar
# Spring Boot 2.x moved the health check endpoint to actuator/health. We should keep the default at /health until most of our downstream services update.
ONBUILD ENV HEALTH_CHECK_ENDPOINT=health
