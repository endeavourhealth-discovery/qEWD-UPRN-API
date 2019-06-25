# qEWD-UPRN-API

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