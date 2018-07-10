#!/bin/sh
echo "Using default /launch-app.sh.."

if [ -f "/app.jar" ]; then
    java -Xmx$maxHeapSpace -Djava.security.egd=file:/dev/./urandom -jar -DkeystorePassword=$keystorePassword app.jar $@
else
    echo "No /app.jar found. Exiting."
    exit 1
fi