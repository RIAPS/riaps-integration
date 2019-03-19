#!/usr/bin/env bash
set -e

function rekey_VM {
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

    #generate new keys and certs
    riaps_gen_cert -o /home/riaps/.ssh
    chmod 400 /home/riaps/.ssh/id_rsa.key

    #never used key
    rm /home/riaps/.ssh/riaps.key

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
    sudo cp /home/riaps/.ssh/id_rsa.pub /usr/local/riaps/keys/.
    sudo chown root:riaps /usr/local/riaps/keys/id_rsa.pub
    sudo chmod 440 /usr/local/riaps/keys/id_rsa.pub
    sudo cp /home/riaps/.ssh/riaps-sys.cert /usr/local/riaps/keys/.
    sudo chown root:riaps /usr/local/riaps/keys/riaps-sys.cert
    sudo chmod 440 /usr/local/riaps/keys/riaps-sys.cert
    sudo cp /home/riaps/.ssh/x509.pem /usr/local/riaps/keys/.
    sudo chown root:riaps /usr/local/riaps/keys/x509.pem
    sudo chmod 440 /usr/local/riaps/keys/x509.pem

    echo "rekeyed development machine with newly generated keys and certificates."
}

riaps_fab_opts=""

if [ "$1" == "-H" ]; then
    riaps_fab_opts="-H $2"
    echo "rekeying hostname(s): $2"
    rekey_VM
elif [ "$1" == "-f" ]; then
    riaps_fab_opts="-f $2"
    echo "rekeying hostname(s): $2"
    rekey_VM
elif [ "$1" == "-A" ]; then
    riaps_fab_opts="-H $2"
    echo "rekeying hostname(s): $2"
else
    rekey_VM
    echo "rekeying hostname(s) from /usr/local/riaps/etc/riaps_hosts.conf"
fi

#use fabric to configure remote RIAPS nodes
riaps_fab riaps.updateBBBKey $riaps_fab_opts

echo "rekeyed beaglebones with development machine keys and certificates."
