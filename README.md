# build cmd
docker build -t jivanjangid/streamx-relay .

# run command for debug
docker run -dti -p 1935:1935 --name=relay -e PORT=1935 -e INJEST_API_HOST='localhost:8000' --add-host=host.docker.internal:host-gateway -e LOCAL_STREAM=live -e STREAMS='rtmp://gopal.streamway.in/live/47'   jivanjangid/sw-relay


uk-london-1.ocir.io/lrqqxehccngb/streamway-injest:v1


# nginx-rtmps
Docker image for Nginx + Stunnel to enable streaming to multiple RTMP(S) services. This was created to allow OBS Streaming to multiple services, including Facebook which requires RTMPS.

# Quick Start
The image requires the following environment variables to be set.

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
LOCAL_STREAM=[name_of_your_local_stream]
```

* INJEST_API_HOST - api endpoint for auth apis - on_publish, on_done, exec_on_publish, exec_on_publish_done.
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
