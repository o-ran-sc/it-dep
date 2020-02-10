#!/bin/sh

#   Copyright (c) 2019 AT&T Intellectual Property.
#   Copyright (c) 2019 Nokia.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

dnBase=${CERT_DN:-'/C=US/O=O-RAN Alliance/OU=O-RAN Software Community'}
keyBits=${KEY_BITS:-4096}

CAHome=${CA_DIR:-'/pki'}
CADays=${CA_CERT_EXPIRY:-9125}
CAKey=${CAHome}/${CA_KEY_NAME:-ca.key.pem}
CACert=${CAHome}/${CA_CERT_NAME:-ca.cert.pem}
#
CertHome=${CERT_DIR:-$CAHome}
#
TillerDays=${TILLER_CERT_EXPIRY:-3650}
TillerKey=${CertHome}/${TILLER_KEY_NAME:-tiller.key.pem}
TillerCert=${CertHome}/${TILLER_CERT_NAME:-tiller.cert.pem}
TillerCN=${TILLER_CN:-tiller}
#
HelmDays=${HELM_CERT_EXPIRY:-3650}
HelmKey=${CertHome}/${HELM_KEY_NAME:-helm.key.pem}
HelmCert=${CertHome}/${HELM_CERT_NAME:-helm.cert.pem}
HelmCN=${HELM_CN:-helm}

# 1. CA
if [ ! -d ${CAHome} ]; then
  mkdir -p ${CAHome}
fi
if [ ! -f ${CAKey} ]; then
  openssl genrsa -out ${CAKey} ${keyBits}
fi
if [ ! -f ${CACert} ]; then
 openssl req -new -x509 -extensions v3_ca -sha256 -days ${CADays} \
  -key ${CAKey} \
  -out ${CACert} \
  -subj "${dnBase}" 
fi

# 2. tiller server cert
if [ ! -f ${TillerKey} ]; then
 openssl genrsa -out ${TillerKey} ${keyBits}
fi
if [ ! -f ${TillerCert} ]; then
 CSR=`mktemp`
 openssl req -new -sha256 \
  -key ${TillerKey} \
  -out ${CSR} \
  -subj "${dnBase}/CN=${TillerCN}"
 openssl x509 -req -CAcreateserial -days ${TillerDays} \
  -CA ${CACert} \
  -CAkey ${CAKey} \
  -in ${CSR} \
  -out ${TillerCert}
fi

# 3. helm client cert
if [ ! -f ${HelmKey} ]; then
 openssl genrsa -out ${HelmKey} ${keyBits}
fi
if [ ! -f ${HelmCert} ]; then
 CSR=`mktemp`
 openssl req -new -sha256 \
  -key ${HelmKey} \
  -out ${CSR} \
  -subj "${dnBase}/CN=${HelmCN}"
 openssl x509 -req -CAcreateserial -days ${HelmDays} \
  -CA ${CACert} \
  -CAkey ${CAKey} \
  -in ${CSR} \
  -out ${HelmCert}
fi
