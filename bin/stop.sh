#!/bin/bash

/usr/local/openresty/nginx/sbin/nginx  -t -p /Users/jasonzhao/workspace/LuaProjects/openresty-demo/ -c config/nginx.conf
/usr/local/openresty/nginx/sbin/nginx  -s quit -p /Users/jasonzhao/workspace/LuaProjects/openresty-demo/ -c config/nginx.conf

echo "nginx stop"
echo -e "===========================================\n\n"
tail -f ../logs/error.log
