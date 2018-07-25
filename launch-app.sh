#!/bin/bash

JAVA_OPTIONS=${JAVA_OPTIONS:-"-server"}
JAVA_ARGUMENTS="${JAVA_ARGUMENTS:-""}"

echo "Using default /launch-app.sh.."

if [ -f "$HOME/app.jar" ]; then
    java $JAVA_OPTIONS $JAVA_ARGUMENTS -jar $HOME/app.jar "$@"
elif [ -f "$HOME/app.war" ]; then
    java $JAVA_OPTIONS $JAVA_ARGUMENTS -jar $HOME/app.war "$@"
else
    echo "No $HOME/app.jar and no $HOME/app.war found. Exiting."
    exit 1
fi
