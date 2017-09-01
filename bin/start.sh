#!/bin/bash

ps -fe|grep nginx |grep -v grep
if [ $? -ne 0 ]
then
  /usr/local/openresty/nginx/sbin/nginx  -t -p /Users/jasonzhao/workspace/LuaProjects/openresty-demo/ -c config/nginx.conf
  /usr/local/openresty/nginx/sbin/nginx -p /Users/jasonzhao/workspace/LuaProjects/openresty-demo/ -c config/nginx.conf
  "nginx start"
else
  /usr/local/openresty/nginx/sbin/nginx  -t -p /Users/jasonzhao/workspace/LuaProjects/openresty-demo/ -c config/nginx.conf
  /usr/local/openresty/nginx/sbin/nginx  -s reload -p /Users/jasonzhao/workspace/LuaProjects/openresty-demo/ -c config/nginx.conf
  "nginx reload"
fi
echo -e "===========================================\n\n"
tail -f ../logs/error.log
