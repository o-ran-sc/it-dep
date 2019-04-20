#!/bin/sh
# subject of cert will be "${dnBase}/CN=<namespace>-<user>".
dnBase='/C=US/O=O-RAN Alliance/OU=O-RAN Software Community'
pkiDir='/opt/helm-pki'
keyBits=4096
certDays=3650

if [ $# -ne 2 ]; then
 echo "USAGE: $0 <tiller-namespace> <user>"
else
 namespace=`echo $1|sed 's/[^a-zA-Z0-9\-\.]//g'`
 u=`echo $2|sed 's/[^a-zA-Z0-9\-\.]//g'`
 dest="${pkiDir}/${namespace}"
 
 if [ ! -d "${pkiDir}/${namespace}" ]; then
  echo "No CA found for ${namespace}.  Creating it."
  ${pkiDir}/bin/certgen.sh ${namespace}
 fi
 
 openssl genrsa -out ${dest}/${namespace}.${u}.key.pem ${keyBits}
 openssl req -new -days ${certDays} -sha256 \
  -key ${dest}/${namespace}.${u}.key.pem \
  -out ${dest}/${namespace}.${u}.csr.pem \
  -subj "${dnBase}/CN=${namespace}-${u}"
 openssl x509 -req -CAcreateserial -days ${certDays} \
  -CA ${dest}/${namespace}.ca.cert.pem \
  -CAkey ${dest}/${namespace}.ca.key.pem \
  -in ${dest}/${namespace}.${u}.csr.pem \
  -out ${dest}/${namespace}.${u}.cert.pem 
fi

