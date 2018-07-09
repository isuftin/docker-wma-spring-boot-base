FROM openjdk:8-jdk-alpine

RUN set -x & \
  apk update && \
  apk upgrade && \
  apk add --no-cache curl && \
  apk --no-cache add openssl

ADD pull-from-artifactory.sh pull-from-artifactory.sh
RUN ["chmod", "+x", "pull-from-artifactory.sh"]

ADD entrypoint.sh entrypoint.sh
RUN ["chmod", "+x", "entrypoint.sh"]

ADD health-check.sh health-check.sh
RUN ["chmod", "+x", "health-check.sh"]

ADD launch-app.sh launch-app.sh
RUN ["chmod", "+x", "launch-app.sh"]

#Default ENV Values
ENV requireSsl=true
ENV serverPort=443
ENV serverContextPath=/
ENV maxHeapSpace=300M
ENV springFrameworkLogLevel=info
ENV keystoreLocation=/localkeystore.pkcs12
ENV keystorePassword=changeme
ENV keystoreSSLKey=tomcat
ENV ribbonMaxAutoRetries=3
ENV ribbonConnectTimeout=1000
ENV ribbonReadTimeout=10000
ENV hystrixThreadTimeout=1500000
ENV SPRING_CLOUD_CONFIG_ENABLED=false
ENV TOMCAT_CERT_PATH=/tomcat-wildcard-ssl.crt
ENV TOMCAT_KEY_PATH=/tomcat-wildcard-ssl.key
ENV JAVA_KEYSTORE=/etc/ssl/certs/java/cacerts
ENV JAVA_STOREPASS=changeit
ENV HEALTH_CHECK_ENDPOINT=health
ENV HEALTHY_RESPONSE_CONTAINS='{"status":"UP"}'

ENTRYPOINT [ "/entrypoint.sh"]

HEALTHCHECK CMD /health-check.sh