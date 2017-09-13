@echo off
echo "nginx is starting on port 80"
nginx -t -p D:/my/openresty-demo/ -c config/nginx-dev.conf
nginx -p D:/my/openresty-demo/ -c config/nginx-dev.conf