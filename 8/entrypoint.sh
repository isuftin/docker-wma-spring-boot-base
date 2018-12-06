#!/bin/bash

keystoreLocation=${keystoreLocation:?}
keystoreSSLKey=${keystoreSSLKey:?}
keystorePassword=${keystorePassword:?}

# Because I am the root user, I cannot write to the system java keystore.
# Therefore I copy the Java keystore to a local area. The source location
# for the Java keystore is /etc/ssl/certs/java/cacerts for this image
# (openjdk:8-jdk-alpine) but may differ on other images
keytool -importkeystore -srckeystore /etc/ssl/certs/java/cacerts -srcstorepass $JAVA_TRUSTSTORE_PASS -destkeystore $JAVA_TRUSTSTORE -deststorepass $JAVA_TRUSTSTORE_PASS

if [ -n "${TOMCAT_CERT_PATH}" ] && [ -n "${TOMCAT_KEY_PATH}" ] && [ -f "${TOMCAT_CERT_PATH}" ] && [ -f "${TOMCAT_KEY_PATH}" ]; then
  # If the previous keystore location exists, remove it as I will create a new file there
  if [ -f $keystoreLocation ]; then
    rm $keystoreLocation
  fi

  # Build PEM file
  cat ${TOMCAT_KEY_PATH} > $HOME/tomcat.pem
  cat ${TOMCAT_CERT_PATH} >> $HOME/tomcat.pem
  if [ -n "${TOMCAT_CHAIN_PATH}" ] && [ -f "${TOMCAT_CHAIN_PATH}" ]; then
    echo "Found intermediate cert, including in PEM creation."
    cat ${TOMCAT_CHAIN_PATH} >> $HOME/tomcat.pem
  fi

  # Import the PEM
  openssl pkcs12 -export -in $HOME/tomcat.pem -inkey $TOMCAT_KEY_PATH -name $keystoreSSLKey -out $HOME/tomcat.pkcs12 -password pass:$keystorePassword
  keytool -v -importkeystore -deststorepass $keystorePassword -destkeystore $keystoreLocation -deststoretype PKCS12 -srckeystore $HOME/tomcat.pkcs12 -srcstorepass $keystorePassword -srcstoretype PKCS12 -noprompt
else
  echo "WARNING: Tomcat cert and/or key not found at '$TOMCAT_CERT_PATH' and/or '$TOMCAT_KEY_PATH'. Keystore: '$keystoreLocation' will not be created."
fi

if [ -n "${CERT_IMPORT_DIRECTORY}" ] && [ -d "${CERT_IMPORT_DIRECTORY}" ]; then
  for c in $CERT_IMPORT_DIRECTORY/*.crt; do
    FILENAME="${c}"

    echo "Checking for certificate $FILENAME already existing  in Java keystore."
    keytool -list -keystore $JAVA_TRUSTSTORE -alias $FILENAME -storepass $JAVA_TRUSTSTORE_PASS
    if [ $? -eq 0 ]; then
      echo "Alias ${FILENAME} already exists in keystore. Skipping."
    else
      echo "Importing ${FILENAME}"
      keytool -importcert -noprompt -trustcacerts -file $FILENAME -alias $FILENAME -keystore $JAVA_TRUSTSTORE -storepass $JAVA_TRUSTSTORE_PASS -noprompt;
    fi

  done
else
  echo "WARNING: Cert import directory not found at '$CERT_IMPORT_DIRECTORY'. No additional certs will be imported into '$JAVA_TRUSTSTORE'."
fi

# NOTE: This is needed because if Java Options are set from the DEFAULT_JAVA_OPTIONS
# build ARG we need to have any container environment references in the ARG escaped
# since the environment variables they reference aren't defined until further down in
# the Dockerfile. Thus we need to evalute those escaped environment references now.
if [ -z "$JAVA_OPTIONS" ]; then
    JAVA_OPTIONS="-server"
else
    echo "Evaluating Java run options: $JAVA_OPTIONS"
    JAVA_OPTIONS=$(eval echo $JAVA_OPTIONS)
fi

# Look for and execute the launch-app script.
if [ -f "${LAUNCH_APP_SCRIPT}" ]; then
  if [ ! -x "${LAUNCH_APP_SCRIPT}" ]; then
    chmod +x $LAUNCH_APP_SCRIPT
  fi
  $LAUNCH_APP_SCRIPT "$@"

  if [ $? -eq 0 ]; then
    exit 0;
  else
    echo "An error occurred while attempting to run ${LAUNCH_APP_SCRIPT}. Exiting."
  fi
else
  echo "No executable ${LAUNCH_APP_SCRIPT} found. Exiting."
fi
exit 1
