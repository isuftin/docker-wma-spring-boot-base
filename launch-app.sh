#!/bin/bash
if [ -z "$JAVA_OPTIONS" ]; then
    JAVA_OPTIONS=$(eval echo $JAVA_OPTIONS)
else
    JAVA_OPTIONS="-Xmx300M -server -Djava.security.egd=file:/dev/./urandom"
fi

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
