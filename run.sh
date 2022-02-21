#!/bin/bash

docker rm -f test
docker build -t swtest .
#docker run -dti -p 1935:1935 -e PORT=1935 --name test -e STREAMS="rtmp://gopal.streamway.in/live/1474" -e LOCAL_STREAM=live swtest 
docker run -dti -p 1935:1935 --add-host alnr:host-gateway -e PORT=1935 --name test -e STREAMS="rtmp://gopal.streamway.in/live/1474" -e LOCAL_STREAM=live -e NGINX_RTMP_CTL_API_HOST=alnr:8000 -e UID='i1mAA4M9G2hxRCZZ3s83cQDjkit1' -e DENY_PULL=True swtest