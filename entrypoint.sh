#!/bin/sh

if [ -f "$keystoreLocation" ]; then
  rm $keystoreLocation
fi

if [ -z "${keystorePassword}" ]; then
  echo "Keystore password not provided"
  exit 1
fi

if [ -n "${TOMCAT_CERT_PATH}" ] && [ -n "${TOMCAT_KEY_PATH}" ]; then
  openssl pkcs12 -export -in $TOMCAT_CERT_PATH -inkey $TOMCAT_KEY_PATH -name $keystoreSSLKey -out tomcat.pkcs12 -password pass:$keystorePassword
  keytool -v -importkeystore -deststorepass $keystorePassword -destkeystore $keystoreLocation -deststoretype PKCS12 -srckeystore tomcat.pkcs12 -srcstorepass $keystorePassword -srcstoretype PKCS12 -noprompt
fi

if [ -d "${CERT_IMPORT_DIRECTORY}" ]; then
  for c in $CERT_IMPORT_DIRECTORY/*.crt; do
    FILENAME="${c}"

    keytool -list -keystore $JAVA_KEYSTORE -alias $FILENAME -storepass $JAVA_STOREPASS
    if [ $? -eq 0 ]; then
      echo "Alias ${FILENAME} already exists in keystore. Skipping."
    else
      echo "Importing ${FILENAME}"
      keytool -importcert -noprompt -trustcacerts -file $FILENAME -alias $FILENAME -keystore $JAVA_KEYSTORE -storepass $JAVA_STOREPASS -noprompt;
    fi

  done
fi

if [ -f "/launch-app.sh" ]; then
  if [ ! -x "/launch-app.sh" ]; then
    chmod +x /launch-app.sh;
  fi

  /launch-app.sh $@

  if [ $? -eq 0 ]; then
    exit 0;
  else
    echo "An error occurred while attempting to run /launch-app.sh"
  fi
else
  echo "No executable /launch-app.sh found. Exiting."
fi
exit 1
