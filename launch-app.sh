#!/bin/bash
# NOTE: This is needed because if JAVA_OPTIONS are overidden via docker-compose (either
# with an ENV file or ENV section in the compose file) and you want to include references
# to environment variables within the container then you need to escape those with double
# $$ which ends up putting your variables as strings into $JAVA_OPTIONS so we need to use
# eval to subtitute in the proper values once the container is running.
if [ -z "$JAVA_OPTIONS" ]; then
    JAVA_OPTIONS=$(eval echo $JAVA_OPTIONS)
else
    JAVA_OPTIONS=""
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
