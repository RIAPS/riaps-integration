#arg1 oldprivatekey
#arg2 newprivatekey
#arg3 newpublickey
#arg4 bbbipaddress 
set -e

if [ "$#" -ne 4 ]; then
    echo "usage :$0 oldprivatekey newprivatekey newpublickey bbbipaddress"
    exit 1
fi
error=0
if [ -f "$1" ]
then
    echo ""
else
    echo "old private key $1 not found."
    error=1
fi
if [ -f "$2" ]
then
    echo ""
else
    echo "new private key $2 not found."
    error=1
fi
if [ -f "$3" ]
then
    echo ""
else
    echo "new private key $3 not found."
    error=1
fi

if [ $error -eq 1 ]; then
    exit 1
fi

#change permission of old key to 600
chmod 600 $1
#change permission of new key to 600
chmod 600 $2
scp -i $1 $2 riaps@$4:~/.ssh/id_rsa.key
scp -i $1 $3 riaps@$4:~/.ssh/id_rsa.pub
ssh -i $1 -l riaps  $4  'cp ~/.ssh/authorized_keys ~/.ssh/authorized_keys.bak; cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys'
echo "rekeyed beaglebone $4. use the key $2 to connect to the bone from now on"
