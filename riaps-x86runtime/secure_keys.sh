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

#generate new keys and certs
riaps_gen_cert -o /home/riaps/.ssh
chmod 400 /home/riaps/.ssh/id_rsa.key

#add private key to ssh agent for immediate use
ssh-add /home/riaps/.ssh/id_rsa.key

#generate public key from private key, riaps_gen_cert creates a PEM/PKCS8 formated public key
#  which does not work well with ssh-add
rm /home/riaps/.ssh/id_rsa.pub
ssh-keygen -y -f /home/riaps/.ssh/id_rsa.key > /home/riaps/.ssh/id_rsa.pub

#copy keys and certs to riaps/keys location
sudo cp /home/riaps/.ssh/id_rsa.key /usr/local/riaps/keys/.
sudo chown root:riaps /usr/local/riaps/keys/id_rsa.key
sudo chmod 440 /usr/local/riaps/keys/id_rsa.key
sudo cp /home/riaps/.ssh/riaps-sys.cert /usr/local/riaps/keys/.
sudo chown root:riaps /usr/local/riaps/keys/riaps-sys.cert
sudo chmod 440 /usr/local/riaps/keys/riaps-sys.cert
sudo cp /home/riaps/.ssh/x509.pem /usr/local/riaps/keys/.
sudo chown root:riaps /usr/local/riaps/keys/x509.pem
sudo chmod 440 /usr/local/riaps/keys/x509.pem

#use fabric to configure
riaps_fab riaps.updateBBBKey

#remove unnecessary keys from ~/.ssh
rm /home/riaps/.ssh/riaps-sys.cert
rm /home/riaps/.ssh/x509.pem
rm /home/riaps/.ssh/riaps.key

echo "rekeyed beaglebones with newly generated keys and certificates."
