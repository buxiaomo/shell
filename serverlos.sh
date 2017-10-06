#!/bin/bash

function StandardOutput {
	echo -e "\033[32m$1\033[0m"
}

for services in `docker service ls | grep -vE "0/0|dce|dcx|ID" | awk '{print $2}' | grep nev | grep -Ev $1`
do
    # services=nev-vehicle-import_mysql
    StandardOutput "${services}"
    HOST=`docker service ps ${services} | grep Running | awk '{print $4}'`
    NAME=`docker service ps ${services} | grep Running | awk '{print $1}'`
    HOST_NAME=`ssh root@${HOST} -a "docker ps | grep ${NAME}"`
    HOST_NAME=`echo ${HOST_NAME} | awk '{print \$1}'`
    ssh root@${HOST} -a "docker logs --tail 50 ${HOST_NAME}"
    # TXT=`ssh root@${HOST} -a "docker inspect ${HOST_NAME}"`
    # echo ${TXT} | jq .[0].LogPath
    StandardOutput "Please input some char to see next service logs..."
    read TMP
done



# docker service ls | grep -vE "0/0|dce|dcx|ID" | awk '{print $2}'
# docker service ps nev-data-parse_nev-data-parse-login | grep Running | awk '{print $4}'
# docker ps | grep dw7qx6nysxw9 | awk '{print $1}'
# docker logs --tail 50 f9795618a472
# ssh root@evm-paas06 -a "docker ps"