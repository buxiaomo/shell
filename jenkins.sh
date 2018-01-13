#!/bin/bash
Registry_URL=hub.xmitd.com
Registry_NAME=swarm

docker build -t ${Registry_URL}/${Registry_NAME}/${JOB_NAME}:${GIT_BRANCH##*/}-${GIT_COMMIT:0:7} ./${JOB_NAME}/
docker push ${Registry_URL}/${Registry_NAME}/${JOB_NAME}:${GIT_BRANCH##*/}-${GIT_COMMIT:0:7}
docker rmi ${Registry_URL}/${Registry_NAME}/${JOB_NAME}:${GIT_BRANCH##*/}-${GIT_COMMIT:0:7}
