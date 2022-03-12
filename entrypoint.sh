#!/bin/sh
STUN_PORT=1936
NGINX_RTMP_CTL_API_HOST=${NGINX_RTMP_CTL_API_HOST}
UID=${UID-None}
DENY_PULL=${DENY_PULL}
ON_PUBLISH_AUTH=${ON_PUBLISH_AUTH}
AUTH_TOKEN=${AUTH_TOKEN}

if [ "x${DENY_PULL}" = "x" ]; then
    DENY_PULL_BOOL="false"
else
    DENY_PULL_BOOL="true"
fi

if [ "x${ON_PUBLISH_AUTH}" = "x" ]; then
    ON_PUBLISH_AUTH_BOOL="false"
else
    ON_PUBLISH_AUTH_BOOL="true"
fi
 
genStunnelConf() {
  echo "[$1]"
  echo "client = yes"
  echo "accept = 127.0.0.1:$2"
  echo "connect = $1"
  echo "verifyChain = no"
  echo  
}

genNginxConf() {
  echo "daemon off;"
  echo "worker_processes auto;"
  echo "rtmp_auto_push on;"
  echo "events {}"
  echo "http {"
  echo "  server {"
  echo "    listen 8334;"
  echo "    server_name 127.0.0.1;"
  echo "    location /on_publish {"
  echo "      proxy_buffering off;"
  echo "      proxy_set_header X-UID ${UID};"
  echo "      proxy_set_header X-Auth_token ${AUTH_TOKEN};"
  echo "      proxy_pass ${NGINX_RTMP_CTL_API_HOST}/on_publish;"
echo "      }"
  echo "    location /on_done {"
  echo "      proxy_buffering off;"
  echo "      proxy_set_header X-UID ${UID};"
  echo "      proxy_set_header X-Auth_token ${AUTH_TOKEN};"
  echo "      proxy_pass ${NGINX_RTMP_CTL_API_HOST}/on_done;"
echo "      }"
echo "    location /exec_publish {"
  echo "      proxy_buffering off;"
  echo "      proxy_set_header X-UID ${UID};"
  echo "      proxy_set_header X-Auth_token ${AUTH_TOKEN};"
  echo "      proxy_pass ${NGINX_RTMP_CTL_API_HOST}/exec_publish;"
echo "      }"
echo "    location /exec_publish_done {"
  echo "      proxy_buffering off;"
  echo "      proxy_set_header X-UID ${UID};"
  echo "      proxy_set_header X-Auth_token ${AUTH_TOKEN};"
  echo "      proxy_pass ${NGINX_RTMP_CTL_API_HOST}/exec_publish_done;"
echo "      }"

  echo "  }"
  echo "}"
  echo "rtmp {"
  echo "    server {"
  echo "        listen $PORT;"
  echo "        listen [::]:$PORT ipv6only=on;"
  echo ""
  echo "        application $LOCAL_STREAM {"
  echo "            live on;"
  echo "            record off;"
  if [ "${DENY_PULL_BOOL}" = "true" ]; then
  echo "            deny play all;"
  DENY_PULL_BOOL="false"
  fi
  if [ "${ON_PUBLISH_AUTH_BOOL}" = "true" ]; then
  echo "            on_publish http://127.0.0.1:8334/on_publish;"
  echo "            on_done http://127.0.0.1:8334/on_done;"
  ON_PUBLISH_AUTH_BOOL="false"
  fi
  echo "            exec_publish curl http://127.0.0.1:8334/exec_publish;"
  echo "            exec_publish_done curl http://127.0.0.1:8334/exec_publish_done;"
  echo ""
  for U in $@; do
  echo "            push $U;"
  done
  echo "        }"
  echo "    }"
  echo "}"
}

if [ -z "$NGINX_RTMP_CTL_API_HOST" ]; then
  echo "NGINX_RTMP_CTL_API_HOST=[value] variable is required"
  exit 0
fi

if [ -z "$UID" ]; then
  echo "UID=[value] variable is required"
  exit 0
fi

if [ -z "$PORT" ]; then
  echo "PORT=[value] variable is required"
  exit 0
fi

if [ -z "$LOCAL_STREAM" ]; then
  echo "LOCAL_STREAM=[value] variable is required"
  exit 0
fi

if [ -z "$STREAMS" ]; then
  echo "STREAMS=[value] variable is required"
  exit 0
fi

TUNNELS=""
URLS=""
CMD=""
for A in $STREAMS; do
  if [ -n "$(echo "$A" | grep "rtmps://")" ]; then
    #handle RTMPS URL
    HOST=$(echo "$A" | cut -d/ -f3)
    if [ -n "$HOST" ]; then
      echo "$(genStunnelConf "$HOST" $STUN_PORT "$(echo "$A" | cut -d/ -f4-)")" >> /etc/stunnel/stunnel.conf

      URLS="$URLS rtmp://127.0.0.1:$STUN_PORT/$(echo "$A" | cut -d/ -f4-) "
      STUN_PORT=$(($STUN_PORT + 1))
    fi
  elif [ -n "$(echo "$A" | grep "rtmp://")" ]; then
    #handle RTMP URL
    URLS="$URLS $A "
  fi
done

genNginxConf "$URLS" > /usr/local/nginx/conf/nginx.conf

#start stunnel daemon
stunnel

exec "$@"