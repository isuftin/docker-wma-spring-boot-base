#!/bin/sh

if [ -f "$keystoreLocation" ]; then
  rm $keystoreLocation
fi

if [ -n "${KEYSTORE_PASSWORD_FILE}" ] && [ -f "${KEYSTORE_PASSWORD_FILE}" ]; then
  keystorePassword=`cat $KEYSTORE_PASSWORD_FILE`
elif [ -n "${KEYSTORE_PASSWORD_FILE}" ]; then
  echo "Keystore Password File specified as ${KEYSTORE_PASSWORD_FILE} not found. Exiting."
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

if [ -f "/launch-app.sh" ] && [ -x "/launch-app.sh" ]; then
  /launch-app.sh $@
  
  if [ $? -eq 0 ]; then
    exit 0;
  else
    echo "An error occurred while attempting to run /launch-app.sh"
    exit 1
  fi
else
  echo "No executable /launch-app.sh found. Exiting."
  exit 1
fi

exec env "$@"