#Build Args
ARG OPENJDK_TAG=8-jre-slim

FROM openjdk:${OPENJDK_TAG}

LABEL maintainer="gs-w_eto_eb_federal_employees@usgs.gov"

ENV USER=spring
ENV HOME=/home/$USER
ENV requireSsl=true
ENV serverPort=443
ENV serverContextPath=/
ENV maxHeapSpace=300M
ENV springFrameworkLogLevel=info
ENV keystoreLocation=$HOME/localkeystore.pkcs12
ENV keystorePassword=changeme
ENV keystoreSSLKey=tomcat
ENV ribbonMaxAutoRetries=3
ENV ribbonConnectTimeout=1000
ENV ribbonReadTimeout=10000
ENV hystrixThreadTimeout=1500000
ENV SPRING_CLOUD_CONFIG_ENABLED=false
ENV TOMCAT_CERT_PATH=$HOME/tomcat-wildcard-ssl.crt
ENV TOMCAT_KEY_PATH=$HOME/tomcat-wildcard-ssl.key
ENV JAVA_KEYSTORE=$HOME/cacerts
ENV JAVA_STOREPASS=changeit
ENV HEALTH_CHECK_ENDPOINT=health
ENV HEALTHY_RESPONSE_CONTAINS='{"status":"UP"}'

RUN apt-get update && \
  apt-get install --no-install-recommends --no-upgrade curl -y && \
  rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos "" -u 1000 $USER

WORKDIR $HOME
COPY pull-from-artifactory.sh pull-from-artifactory.sh
COPY entrypoint.sh entrypoint.sh
COPY launch-app.sh launch-app.sh
RUN [ "chmod", "+x", "pull-from-artifactory.sh", "entrypoint.sh", "launch-app.sh" ]
RUN chown $USER:$USER pull-from-artifactory.sh entrypoint.sh launch-app.sh
USER $USER

ENTRYPOINT [ "./entrypoint.sh"]

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -k "https://127.0.0.1:${serverPort}${serverContextPath}${HEALTH_CHECK_ENDPOINT}" | grep -q ${HEALTHY_RESPONSE_CONTAINS} || exit 1
