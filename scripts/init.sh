#!/bin/bash

set -e

CA_USER=$1
CA_UID=$2
DIR_CA_WORKING_DIR=$3

# make directory and link easy-rsa scripts
mkdir -p "${DIR_CA_WORKING_DIR}"
ln -s /usr/share/easy-rsa/* "${DIR_CA_WORKING_DIR}"

# generate encryption key
openssl rand -base64 128 > /opt/easy-ca-server/enc.key

# setup easy-rsa pki
cd "${DIR_CA_WORKING_DIR}"
./easyrsa init-pki
cp /opt/easy-ca-server/vars ./
cp /opt/easy-ca-server/random/$((16#$(openssl rand -hex 1))) ./pki/.rnd
cp /opt/easy-ca-server/random/$((16#$(openssl rand -hex 1))) ./pki/.rand

# create ca
yes "" | ./easyrsa build-ca nopass

chmod -R 700 /opt/easy-ca-server/
chmod -R 700 "${DIR_CA_WORKING_DIR}"
adduser --disabled-password --uid ${CA_UID} ${CA_USER}
chown -R ${CA_USER}:${CA_USER} "${DIR_CA_WORKING_DIR}"
#su - ${CA_USER}
#gpg --quick-gen-key