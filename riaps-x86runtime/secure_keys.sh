#!/usr/bin/env bash
set -e

#MM TODO:  allow user to add -H hostname for fab command

#save old keys and certs
if [ -f /home/riaps/.ssh/id_rsa.pub ]; then
    mv /home/riaps/.ssh/id_rsa.pub /home/riaps/.ssh/id_rsa.pub.old

if [ -f /home/riaps/.ssh/id_rsa.key ]; then
    mv /home/riaps/.ssh/id_rsa.key /home/riaps/.ssh/id_rsa.key.old

if [ -f /home/riaps/.ssh/riaps-sys.cert ]; then
    mv /home/riaps/.ssh/riaps-sys.cert /home/riaps/.ssh/riaps-sys.cert.old

if [ -f /home/riaps/.ssh/x509.pem ]; then
    mv /home/riaps/.ssh/x509.pem /home/riaps/.ssh/x509.pem.old

#generate new keys and certs
riaps_gen_cert -o /home/riaps/.ssh
chmod 600 /home/riaps/.ssh/id_rsa.key
chmod 600 /home/riaps/.ssh/riaps-sys.cert

#add private key to ssh agent for immediate use
sudo ssh-add /home/riaps/.ssh/id_rsa.key

#copy keys and certs to riaps/keys location
sudo cp /home/riaps/.ssh/id_rsa.pub /usr/local/riaps/keys/.
sudo cp /home/riaps/.ssh/id_rsa.key /usr/local/riaps/keys/.
sudo cp /home/riaps/.ssh/riaps-sys.cert /usr/local/riaps/keys/.
sudo cp /home/riaps/.ssh/x509.pem /usr/local/riaps/keys/.

#use fabric to configure
riaps_fab riaps.updateBBBKey

echo "rekeyed beaglebones with newly generated keys and certificates."
