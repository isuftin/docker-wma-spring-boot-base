#!/bin/bash

echo "Using default /launch-app.sh.."

# NOTE: This is needed because if Java Options are set from the DEFAULT_JAVA_OPTIONS
# build ARG we need to have any container environment references in the ARG escaped
# since the environment variables they reference aren't defined until further down in
# the Dockerfile. Thus we need to evalute those escaped environment references now.
if [ -z "$JAVA_OPTIONS" ]; then
    JAVA_OPTIONS="-server -Djava.security.egd=file:/dev/./urandom"
else
    echo "Evaluating Java run options: $JAVA_OPTIONS"
    JAVA_OPTIONS=$(eval echo $JAVA_OPTIONS)
fi

JAVA_ARGUMENTS="${JAVA_ARGUMENTS:-""}"

if [ -f "$HOME/app.jar" ]; then
    java $JAVA_OPTIONS -jar $HOME/app.jar "$@"
elif [ -f "$HOME/app.war" ]; then
    java $JAVA_OPTIONS -jar $HOME/app.war "$@"
else
    echo "No $HOME/app.jar and no $HOME/app.war found. Exiting."
    exit 1
fi
