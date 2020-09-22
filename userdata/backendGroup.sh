#!/bin/bash
while true
do
echo -e "HTTP/1.1 200 OK\n\nHello World - cloud is AWS - Node is $(hostname) - Auto Scaling Group" | nc -N -l -p 80
done
