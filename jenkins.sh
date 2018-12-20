#!/bin/bash
Registry_URL=hub.xmitd.com
Registry_NAME=public
Image_NAME=ngrok
Image_Tag=1.7.1
Image_URL=${Registry_URL}/${Registry_NAME}/${Image_NAME}:${Image_Tag}

docker build -t static:${GIT_BRANCH##*/}-${GIT_COMMIT:0:7} .

https://ci.example.com/jenkins/github-webhook/