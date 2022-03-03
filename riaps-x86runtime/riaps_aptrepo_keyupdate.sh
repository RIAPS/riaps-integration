#!/usr/bin/env bash

echo "get riaps public key"
wget -q https://riaps.isis.vanderbilt.edu/keys/riapspublic.key
echo "adding riaps public key"
sudo apt-key add riapspublic.key
rm riapspublic.key
sudo apt-get update
echo "riaps aptrepo setup"
sudo apt-get install 'riaps-*'
echo "updated riaps packages"
