#!/bin/bash

JAVA_OPTIONS=${JAVA_OPTIONS:-"-Xmx300M -server -Djava.security.egd=file:/dev/./urandom -Djavax.net.ssl.trustStore=${JAVA_TRUSTSTORE} -Djavax.net.ssl.trustStorePassword=${JAVA_TRUSTSTORE_PASS}"}
JAVA_ARGUMENTS="${JAVA_ARGUMENTS:-""}"

echo "Using default /launch-app.sh.."
echo "Running with options: $JAVA_OPTIONS"

if [ -f "$HOME/app.jar" ]; then
    java $JAVA_OPTIONS -jar $HOME/app.jar "$@"
elif [ -f "$HOME/app.war" ]; then
    java $JAVA_OPTIONS -jar $HOME/app.war "$@"
else
    echo "No $HOME/app.jar and no $HOME/app.war found. Exiting."
    exit 1
fi
