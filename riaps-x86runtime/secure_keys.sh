#arg1 oldprivatekey
#arg2 newprivatekey
#arg3 newpublickey
#arg4 bbbipaddress 

set -e
#change permission of old key to 600
chmod 600 $1
#change permission of new key to 600
chmod 600 $2
scp -i $1 $2 riaps@$4:~/.ssh/id_rsa.key
scp -i $1 $3 riaps@$4:~/.ssh/id_rsa.pub
ssh -i $1 -l riaps  $4  'cp ~/.ssh/authorized_keys ~/.ssh/authorized_keys.bak; cp ~/.ssh/id_rsa.key.pub ~/.ssh/authorized_keys'
