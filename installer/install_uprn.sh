#!/bin/bash -xl

##########################
## Change node hostname ##
##########################
#export AWS_DEFAULT_REGION=eu-west-2
#INSTANCE_ID=$(ec2metadata --instance-id)
#SHORT_NODE_NAME=$(aws ec2 describe-tags --filter "Name=resource-id,Values=$INSTANCE_ID" | jq -r '.Tags[] | select(.Key == "Name") | .Value')
#NODE_DNS_NAME="$SHORT_NODE_NAME"
#echo $NODE_DNS_NAME > /etc/hostname
#echo "127.0.0.1 $NODE_DNS_NAME" >> /etc/hosts
#hostname $NODE_DNS_NAME

###################
## Install Yotta ##
###################

#cd ~
#wget https://raw.githubusercontent.com/robtweed/qewd/master/installers/install_yottadb.sh
#source install_yottadb.sh

mkdir /tmp/mumps
cd /tmp/mumps

wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/G.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/LIB.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/NUPRN.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/NUPRN.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRN.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRN1.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRN2.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRN3.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRN4.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRN5.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNA.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNHOOK.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNHOOK2.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNL.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNL1.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNMGR.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNONS.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNU.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNUI.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNW.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UPRNX.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/UTILS.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/ZOS.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/START.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/BASE64.m

# M web-server routines
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJREQ.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJRSP.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJRUT.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJSON.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJSOND.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJSONE.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJUJ01.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJUJ02.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJUJD.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/VPRJUJE.m

# tls-config
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/tls/gtmcrypt_config.libconfig

mkdir /opt/apiuprn
mkdir /opt/apiuprn/certs

cp gtmcrypt_config.libconfig /opt/apiuprn

cp /tmp/mumps/*.m /root/.yottadb/r1.24_x86_64/r/

cd /usr/local/lib/yottadb/r124/plugin/gtmcrypt
tar x < source.tar
apt-get install libgpgme11-dev
apt-get install libgcrypt11-dev libgcrypt20-dev
apt-get install libconfig-dev
make && make install && make clean

uuidgen > /tmp/uuid.txt
uuid=$(cat '/tmp/uuid.txt')

./maskpass <<< $uuid > '/tmp/monkey.txt'

cut -d':' -f2- /tmp/monkey.txt > /tmp/monkey2.txt
cut -d' ' -f2- /tmp/monkey2.txt > /tmp/monkey3.txt

monkey=$(cat '/tmp/monkey3.txt')

export gtmtls_passwd_dev=$monkey
export gtmcrypt_config="/opt/apiuprn/gtmcrypt_config.libconfig"

openssl genrsa -aes128 -passout pass:$uuid -out /opt/apiuprn/certs/mycert.key 2048
openssl req -new -key /opt/apiuprn/certs/mycert.key -passin pass:$uuid -subj '/C=UK/ST=Yorkshire/L=Leeds/CN=dummy' -out /opt/apiuprn/certs/mycert.csr
openssl req -x509 -days 3660 -sha256 -in /opt/apiuprn/certs/mycert.csr -key /opt/apiuprn/certs/mycert.key -passin pass:$uuid -out /opt/apiuprn/certs/mycert.pem

export ydb_dist=/usr/local/lib/yottadb/r124
export ydb_gbldir=/root/.yottadb/r1.24_x86_64/g/yottadb.gld
export ydb_dir=/root/.yottadb
export ydb_rel=r1.24_x86_64

$ydb_dist/mupip SET -NULL_SUBSCRIPTS=true -region DEFAULT

$ydb_dist/mupip set - journal=off -region '*'

cd /root/.yottadb/r1.24_x86_64/r/;/usr/local/lib/yottadb/r124/mumps -run ^START

#reboot