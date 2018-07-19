#!/bin/ash
# shellcheck shell=dash

keystoreLocation=${keystoreLocation:-""}
keystoreSSLKey=${keystoreSSLKey:-"tomcat"}

if [ -z "$keystoreLocation" ]; then
  echo "Location of keystore not supplied. Exiting."
  exit 1
fi

if [ -z "${KEYSTORE_PASSWORD_FILE}" ]; then
  echo "Keystore password file not specified. Exiting."
  exit 1
elif [ ! -f "${KEYSTORE_PASSWORD_FILE}" ]; then
  echo "Keystore password file @ ${KEYSTORE_PASSWORD_FILE} not found. Exiting."
  exit 1
fi

if [ -n "${TOMCAT_CERT_PATH}" ] && [ -n "${TOMCAT_KEY_PATH}" ] && [ -f "${TOMCAT_CERT_PATH}" ] && [ -f "${TOMCAT_KEY_PATH}" ]; then
  # If the previous keystore location exists, remove it as I will create a new
  # file there
  if [ -f $keystoreLocation ]; then
    rm $keystoreLocation
  fi
  # Grab the keystore password from a file
  keystorePassword=`cat $KEYSTORE_PASSWORD_FILE`
  # Because I am the root user, I cannot write to the system java keystore.
  # Therefore I copy the Java keystore to a local area. The source location
  # for the Java keystore is /etc/ssl/certs/java/cacerts for this image
  # (openjdk:8-jdk-alpine) but may differ on other images
  keytool -importkeystore -srckeystore /etc/ssl/certs/java/cacerts -srcstorepass $JAVA_STOREPASS -destkeystore $JAVA_KEYSTORE -deststorepass $JAVA_STOREPASS
  openssl pkcs12 -export -in $TOMCAT_CERT_PATH -inkey $TOMCAT_KEY_PATH -name $keystoreSSLKey -out tomcat.pkcs12 -password pass:$keystorePassword
  keytool -v -importkeystore -deststorepass $keystorePassword -destkeystore $keystoreLocation -deststoretype PKCS12 -srckeystore tomcat.pkcs12 -srcstorepass $keystorePassword -srcstoretype PKCS12 -noprompt
fi

if [ -n "${CERT_IMPORT_DIRECTORY}" ] && [ -d "${CERT_IMPORT_DIRECTORY}" ]; then
  for c in $CERT_IMPORT_DIRECTORY/*.crt; do
    FILENAME="${c}"

    echo "Checking for certificate $FILENAME already existing  in Java keystore."
    keytool -list -keystore $JAVA_KEYSTORE -alias $FILENAME -storepass $JAVA_STOREPASS
    if [ $? -eq 0 ]; then
      echo "Alias ${FILENAME} already exists in keystore. Skipping."
    else
      echo "Importing ${FILENAME}"
      keytool -importcert -noprompt -trustcacerts -file $FILENAME -alias $FILENAME -keystore $JAVA_KEYSTORE -storepass $JAVA_STOREPASS -noprompt;
    fi

  done
fi

launch_app="${HOME}/launch_app.sh"
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
