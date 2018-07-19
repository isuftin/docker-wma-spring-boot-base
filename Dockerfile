FROM openjdk:8-jdk-alpine

LABEL maintaner="gs-w_eto@usgs.gov"

#Default ENV Values
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

RUN apk update && \
  apk upgrade && \
  apk --no-cache add openssl curl && \
  rm -rf /var/cache/apk/*

RUN adduser -D -u 1000 $USER

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
