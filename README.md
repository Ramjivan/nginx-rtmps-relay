# build cmd
docker build -t jivanjangid/streamx-relay .

# run command for debug
docker run -dti -p 1935:1935 --name=relay -e PORT=1935 -e NGINX_RTMP_CTL_API_HOST='localhost:8000' -e UID='firebase_user_id' --add-host=host.docker.internal:host-gateway -e LOCAL_STREAM=live -e STREAMS='rtmp://gopal.streamway.in/live/47'   jivanjangid/sw-relay


uk-london-1.ocir.io/lrqqxehccngb/streamway-injest:v1


# nginx-rtmps
Docker image for Nginx + Stunnel to enable streaming to multiple RTMP(S) services. This was created to allow OBS Streaming to multiple services, including Facebook which requires RTMPS.

# extention 
entrypoint.sh is further extended to add authentication and more events like on_done exec_publish


# Quick Start
The image requires the following environment variables to be set and all are mendatory. 

* PORT - port number that NGINX will listen on for RTMP stream. This should normalily be set to 1935.
```
PORT=1935
```

* STREAMS - space separated list of RTMP(S) URLs. 
```
STREAMS="rtmp://a.rtmp.youtube.com/live2/[put_your_key_here] rtmps://live-api-s.facebook.com:443/rtmp/[put_your_key_here]" 
```

* LOCAL_STREAM - name of the local stream that OBS will point to. This value is arbitrary and you just need to ensure that this name matches what you entered into OBS.
```

* NGINX_RTMP_CTL_API_HOST - api endpoint for auth apis - on_publish, on_done, exec_on_publish, exec_on_publish_done.
```

## Run the container
Map the container's port 1935 to a port on your server.
```
docker run -p 1935:1935
```

## OBS Setup
In Settings/Stream, set the server to:
```
rtmp://[your container IP address]:[port]/[name_of_your_local_stream]
```

Changlog
V1 - restreaming with stunnal forked from parki/nginx-rtmps[https://github.com/parki/nginx-rtmps]
     requires at least one destination url to push to

V2 - added optional auth with env  NGINX_RTMP_CTL_API_HOST 
     added optional UID query parameter in every request like on_publish & on_done
     added optional DENY_PULL_BOOL to deny all play or pull requests from container, makeing it truly push only relay
     any non empty string value assigned to DENY_PULL_BOOL will make it true [not a boolean actually] 
