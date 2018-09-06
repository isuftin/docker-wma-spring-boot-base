#!/bin/bash

# Most of the content pulled from https://raymii.org/s/tutorials/OpenSSL_command_line_Root_and_Intermediate_CA_including_OCSP_CRL%20and_revocation.html

SUBJ=${SUBJ:-/C=US/ST=Wisconsin/L=Middleon/O=US Geological Survey/OU=WMA/CN=*}
rm -rf ./root
rm -rf ./intermediate1
mkdir ./root
mkdir ./intermediate1
cp openssl-root.conf ./root/openssl.conf
cp openssl-intermediate.conf ./intermediate1/openssl.conf
cd root
PWD=$(pwd)

touch certindex
echo 1000 > certserial
echo 1000 > crlnumber

echo "Generating RSA private key @ ${PWD}/rootca.key ..."
openssl genrsa -out rootca.key 8192

echo "Generating self-signed root CA @ ${PWD}/rootca.crt ..."
openssl req -sha256 -new -x509 -days 9999 -key rootca.key -out rootca.crt -subj "$SUBJ"

echo "Generating the intermediate CA's private key @ ${PWD}/intermediate1.key ..."
openssl genrsa -out intermediate1.key 4096

echo "Generating the intermediate1 CA's CSR @ ${PWD}/intermediate1.csr ..."
openssl req -new -sha256 -key intermediate1.key -out intermediate1.csr -subj "$SUBJ"

echo "Signing the intermediate1 CSR with the Root CA, outputting to ${PWD}/intermediate1.crt ..."
openssl ca -batch -config openssl.conf -notext -in intermediate1.csr -out intermediate1.crt

echo "Generating the CRL (both in PEM and DER) @ ${PWD}/rootca.crl.pem and ${PWD}/rootca.crl respectively ..."
openssl ca -config openssl.conf -gencrl -keyfile rootca.key -cert rootca.crt -out rootca.crl.pem
openssl crl -inform PEM -in rootca.crl.pem -outform DER -out rootca.crl

cd ..

cp root/intermediate1.key intermediate1/
cp root/intermediate1.crt intermediate1/
cp root/rootca.crt intermediate1/
cp root/rootca.key intermediate1/

cd intermediate1
mkdir ./end_user_certs

PWD=$(pwd)
touch certindex
echo 1000 > certserial
echo 1000 > crlnumber

echo "Generating an empty CRL (both in PEM and DER) @ ${PWD}/rootca.crl.pem and ${PWD}/rootca.crl respectively ..."
openssl ca -config openssl.conf -gencrl -keyfile rootca.key -cert rootca.crt -out rootca.crl.pem
openssl crl -inform PEM -in rootca.crl.pem -outform DER -out rtca.crl

echo "Generating end user RSA key @ ${PWD}/end_user_certs/tomcat-wildcard.key"
openssl genrsa -out end_user_certs/tomcat-wildcard.key 4096 -subj "$SUBJ"
echo "Generating end user certificate signing request @ ${PWD}/end_user_certs/tomcat-wildcard.csr"
openssl req -new -sha256 -key end_user_certs/tomcat-wildcard.key -out end_user_certs/tomcat-wildcard.csr -subj "$SUBJ"
echo "Signing end user CSR with intermediate certificate, putting output certificate @ ${PWD}/end_user_certs/tomcat-wildcard.crt"
openssl ca -batch -config openssl.conf -notext -in end_user_certs/tomcat-wildcard.csr -out end_user_certs/tomcat-wildcard.crt

echo "Generating the CRL (both in PEM and DER) @ ${PWD}/intermediate1.crl.pem and ${PWD}/intermediate1.crl respectively"
openssl ca -config openssl.conf -gencrl -keyfile intermediate1.key -cert intermediate1.crt -out intermediate1.crl.pem
openssl crl -inform PEM -in intermediate1.crl.pem -outform DER -out intermediate1.crl

echo "Creating chain certificate @ ${PWD}/end_user_certs/tomcat-wildcard.chain ..."
cat ../root/rootca.crt intermediate1.crt > end_user_certs/tomcat-wildcard.chain

cp ${PWD}/end_user_certs/* ..
