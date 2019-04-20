#!/bin/sh
dnBase='/C=US/O=O-RAN Alliance/OU=O-RAN Software Community'
pkiDir='/opt/helm-pki'
keyBits=4096
CADays=9125
certDays=3650

while [ $# -gt 0 ]; do
 namespace=`echo $1|sed 's/[^a-zA-Z0-9\-\.]//g'`
 dest="${pkiDir}/${namespace}"
 mkdir ${dest}

 # CA
 openssl genrsa -out ${dest}/${namespace}.ca.key.pem ${keyBits}
 openssl req -new -x509 -extensions v3_ca -sha256 -days ${CADays} \
  -key ${dest}/${namespace}.ca.key.pem \
  -out ${dest}/${namespace}.ca.cert.pem \
  -subj "${dnBase}/CN=${namespace}"
 # tiller server cert
 openssl genrsa -out ${dest}/${namespace}.tiller.key.pem ${keyBits}
 openssl req -new -days ${certDays} -sha256 \
  -key ${dest}/${namespace}.tiller.key.pem \
  -out ${dest}/${namespace}.tiller.csr.pem \
  -subj "${dnBase}/CN=${namespace}-tiller"
 openssl x509 -req -CAcreateserial -days ${certDays} \
  -CA ${dest}/${namespace}.ca.cert.pem \
  -CAkey ${dest}/${namespace}.ca.key.pem  \
  -in ${dest}/${namespace}.tiller.csr.pem \
  -out ${dest}/${namespace}.tiller.cert.pem 
 # helm client cert
 openssl genrsa -out ${dest}/${namespace}.helm.key.pem ${keyBits}
 openssl req -new -days ${certDays} -sha256 \
  -key ${dest}/${namespace}.helm.key.pem \
  -out ${dest}/${namespace}.helm.csr.pem \
  -subj "${dnBase}/CN=${namespace}-helm"
 openssl x509 -req -CAcreateserial -days ${certDays} \
  -CA ${dest}/${namespace}.ca.cert.pem \
  -CAkey ${dest}/${namespace}.ca.key.pem \
  -in ${dest}/${namespace}.helm.csr.pem \
  -out ${dest}/${namespace}.helm.cert.pem 

 # helpful: serviceaccout/role
 sed s/__NAMESPACE__/${namespace}/g < /opt/helm-pki/skel/tiller-svcacct.yaml.skel > ${dest}/${namespace}-tiller-svcacct.yaml

 echo 
 echo Certificates created.  To install helm, issue the following commands:
 echo
 echo kubectl create namespace ${namespace}
 echo kubectl apply -f ${dest}/${namespace}-tiller-svcacct.yaml
 echo helm init --tiller-tls --tiller-tls-verify \
  --service-account ${namespace}-tiller --tiller-namespace ${namespace} \
  --tls-ca-cert ${dest}/${namespace}.ca.cert.pem \
  --tiller-tls-cert ${dest}/${namespace}.tiller.cert.pem \
  --tiller-tls-key ${dest}/${namespace}.tiller.key.pem 
 echo
 echo 'Optionally, expose tiller on nodePort <P>':
 echo
 echo kubectl -n ${namespace} patch service tiller-deploy \
  -p \''{"spec": {"ports": [ {"name": "tiller", "port": 44134, "nodePort": <P>} ], "type": "NodePort"}}'\'
 echo
 echo Example helm client command:
 echo
 echo helm version --tls \
  --tls-ca-cert ${dest}/${namespace}.ca.cert.pem \
  --tls-cert ${dest}/${namespace}.helm.cert.pem \
  --tls-key ${dest}/${namespace}.helm.key.pem 
 shift
done 
