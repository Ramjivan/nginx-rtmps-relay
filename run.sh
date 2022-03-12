#!/bin/bash

docker rm -f test
docker build -t swtest .
docker run -dti -p 1935:1935 --name test -e PORT=1935 -e STREAMS="rtmp://gopal.streamway.in/live/1474" -e NGINX_RTMP_CTL_API_HOST='' -e AUTH_TOKEN="token" -e ON_PUBLISH_AUTH=True -e UID="8pigHPlupmOt24hmcEfdTONqLTq2" -e DENY_PULL=True -e LOCAL_STREAM=CfgmnOqUIYXXgTmF3NOX  swtest 
