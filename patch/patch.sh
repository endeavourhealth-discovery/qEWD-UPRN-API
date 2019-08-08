#!/bin/bash -xl
cd /tmp/
TMPDIR=$(mktemp -d)
cd $TMPDIR
cp /root/.yottadb/r1.26_x86_64/r/*.m .
mkdir /tmp/git
cd /tmp/git
rm *
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
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/EWEBRC4.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/ADDEXT.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/CURL.m
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/PS.m
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
wget https://raw.githubusercontent.com/endeavourhealth-discovery/qEWD-UPRN-API/master/mumps/_WHOME.m
service MSTU stop
cp -u *.m /root/.yottadb/r1.26_x86_64/r/
service MSTU start
