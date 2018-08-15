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

  openssl pkcs12 -export -in $TOMCAT_CERT_PATH -inkey $TOMCAT_KEY_PATH -name $keystoreSSLKey -out $HOME/tomcat.pkcs12 -password pass:$keystorePassword
  keytool -v -importkeystore -deststorepass $keystorePassword -destkeystore $keystoreLocation -deststoretype PKCS12 -srckeystore $HOME/tomcat.pkcs12 -srcstorepass $keystorePassword -srcstoretype PKCS12 -noprompt
else
  echo "WARNING: Tomcat cert and/or key not found at '$TOMCAT_CERT_PATH' and/or '$TOMCAT_KEY_PATH'."
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

launch_app="${HOME}/launch-app.sh"
if [ -f "${launch_app}" ]; then
  if [ ! -x "${launch_app}" ]; then
    chmod +x $launch_app
  fi
  $launch_app "$@"

  if [ $? -eq 0 ]; then
    exit 0;
  else
    echo "An error occurred while attempting to run ${launch_app}"
  fi
else
  echo "No executable ${launch_app} found. Exiting."
fi
exit 1
