# UPRN

The software is split into two solutions.

The UPRN software can be implemented using a set of microservices written in QEWD and hosted in docker.

Alternatively, the UPRN software can be implemented using Sam Habiel's M Web Server (https://github.com/shabiel/M-Web-Server).

Both solutions provide users with the same ?getinfo REST interface.

The M Web Server interface supports Basic Authentication.


# M Web Server

Install:

sudo chmod +x install_uprn.sh

sudo ./install_uprn.sh

To Add a User:

```
cd /usr/local/lib/yottadb/r126
./ydb

set ^ICONFIG("KEY")="endeavour"
set ^BUSER("USER","psimon")=$$TORCFOUR^EWEBRC4("dls1tg",^ICONFIG("KEY"))
```

https://192.168.59.134:9080/api/getinfo?adrec=Crystal Palace football club, SE25 6PU

The MSTU service runs the web service by default over TLS (see /mumps/START.m).

If you want to run the web service over http do START^VPRJREQ(9080).

job START^VPRJREQ(9080) to run the web service in the background.



# qEWD

Install docker!

sudo docker pull rtweed/qewd-server:yottadb_1.24

sudo docker network create qewd-net

```
docker run -it --name orchestrator --rm --net qewd-net -p 8080:8080 -v /home/ubuntu/UPRN:/opt/qewd/mapped rtweed/qewd-server:yottadb_1.24
```

```
docker run -it --name login_service --rm --net qewd-net -v /home/ubuntu/UPRN:/opt/qewd/mapped -e microservice="login_service" rtweed/qewd-server:yottadb_1.24
```

```
docker run -it --name info_service --rm --net qewd-net -v /home/ubuntu/UPRN:/opt/qewd/mapped -v /home/ubuntu/UPRN/mumps:/root/.yottadb/r/ -v /home/ubuntu/g:/root/.yottadb/r1.24_x86_64/g/ -v /home/ubuntu/files:/tmp/files -e microservice="info_service" rtweed/qewd-server:yottadb_1.24
```

To shut down the microservices press CTRL-C

To get to a Yotta/M prompt:

docker exec -it info_service bash

./ydb