#!/bin/sh
#curl --include \
#     --no-buffer \
#     --header "Connection: Upgrade" \
#     --header "Upgrade: websocket" \
#     --header "Host: cdeville.42.fr" \
#     --header "Origin: https://cdeville.42.fr/goaccess" \
#     --header "Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==" \
#     --header "Sec-WebSocket-Version: 13" \
#     --insecure \
#     https://cdeville.42.fr/goaccess/ws
curl --include \
     --no-buffer \
     --header "Connection: Upgrade" \
     --header "Upgrade: websocket" \
     --header "Host: localhost" \
     --header "Origin: https:localhost/goaccess" \
     --header "Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==" \
     --header "Sec-WebSocket-Version: 13" \
     --insecure \
     https://localhost/goaccess/ws
