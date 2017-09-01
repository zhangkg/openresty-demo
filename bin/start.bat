@echo off
echo "nginx is starting on port 8000"
nginx -t -p D:/my/openresty-demo/ -c config/nginx.conf
nginx -p D:/my/openresty-demo/ -c config/nginx.conf