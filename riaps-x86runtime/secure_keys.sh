#!/usr/bin/env bash
set -e

#MM TODO:  allow user to add -H hostname for fab command

#save old keys and certs
if [ -f /home/riaps/.ssh/id_rsa.pub ]; then
    ssh-add -d /home/riaps/.ssh/id_rsa.pub
    mv /home/riaps/.ssh/id_rsa.pub /home/riaps/.ssh/id_rsa.pub.old
fi

if [ -f /home/riaps/.ssh/id_rsa.key ]; then
    mv /home/riaps/.ssh/id_rsa.key /home/riaps/.ssh/id_rsa.key.old
fi

if [ -f /home/riaps/.ssh/riaps-sys.cert ]; then
    mv /home/riaps/.ssh/riaps-sys.cert /home/riaps/.ssh/riaps-sys.cert.old
fi

if [ -f /home/riaps/.ssh/x509.pem ]; then
    mv /home/riaps/.ssh/x509.pem /home/riaps/.ssh/x509.pem.old
fi

if [ -f /home/riaps/.ssh/riaps.key ]; then
    mv /home/riaps/.ssh/riaps.key /home/riaps/.ssh/riaps.key.old
fi

#generate new keys and certs
riaps_gen_cert -o /home/riaps/.ssh
chmod 600 /home/riaps/.ssh/id_rsa.key
chmod 600 /home/riaps/.ssh/riaps-sys.cert
chmod 600 /home/riaps/.ssh/riaps.key

#add private key to ssh agent for immediate use
ssh-add /home/riaps/.ssh/id_rsa.key

#copy keys and certs to riaps/keys location
sudo cp /home/riaps/.ssh/id_rsa.pub /usr/local/riaps/keys/.
sudo chmod 600 /usr/local/riaps/keys/id_rsa.pub
sudo cp /home/riaps/.ssh/id_rsa.key /usr/local/riaps/keys/.
sudo chmod 600 /usr/local/riaps/keys/id_rsa.key
sudo cp /home/riaps/.ssh/riaps-sys.cert /usr/local/riaps/keys/.
sudo chmod 600 /usr/local/riaps/keys/riaps-sys.cert
sudo cp /home/riaps/.ssh/x509.pem /usr/local/riaps/keys/.
sudo chmod 600 /usr/local/riaps/keys/x509.pem

#use fabric to configure
riaps_fab riaps.updateBBBKey

echo "rekeyed beaglebones with newly generated keys and certificates."
