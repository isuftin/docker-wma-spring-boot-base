#!/bin/bash

echo "Using default /launch-app.sh.."

if [ -f "$HOME/app.jar" ]; then
    ARTIFACT="$HOME/app.jar"
elif [ -f "$HOME/app.war" ]; then
    ARTIFACT="$HOME/app.war"
else
    echo "No $HOME/app.jar and no $HOME/app.war found. Exiting."
    exit 1
fi

java $JAVA_OPTIONS \
  -Djava.security.egd=file:/dev/./urandom \
  -Djava.security.properties="${HOME}/java.security.properties" \
  -Djavax.net.ssl.trustStore="${JAVA_TRUSTSTORE}" \
  -Djavax.net.ssl.trustStorePassword="${JAVA_TRUSTSTORE_PASS}" \
  -jar "${ARTIFACT}" \
  "$@"
