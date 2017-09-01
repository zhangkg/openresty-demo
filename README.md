# Openresty学习实例

## 它是什么？

Openresty = Nginx + ngxhttp\_lua\_module + lua_resty\*

## 常见的利用场景有哪些？

### 1.动态负载均衡

- 普通流量走一致性哈希，提升命中率；热点流量走轮训减少单服务器压力。
- 根据请求特征将流量分配到不同分组并限流（爬虫、或者流量大的IP）。
- 动态流量（动态增加upstream或者减少upstream或者动态负载均衡）可以使用balancer_by_lua或者微博开源的upsync。

### 2.防火墙（DDOS、IP/URL/UserAgent/Referer黑名单、防盗链等）

- 非法请求过滤，比如应该有Referer却没有，或者应该带着Cookie却没有Cookie。
- 请求头过滤，比如有些业务是不需要请求头的，因此可以在往业务Nginx转发时把这些数据过滤掉。

### 3.防止DDOS限流

- 可以将请求日志推送到实时计算集群，然后将需要限流的IP推送到核心Nginx进行限流。
- 按照接口特征和接口吞吐量来实现动态限流，比如后端服务快扛不住了，那我们就需要进行限流，被限流的请求作为降级请求处理；通过lua-resty-limit-traffic可以通过编程实现更灵活的降级逻辑，如根据用户、根据URL等等各种规则，如降级了是让用户请求等待（比如sleep 100ms，这样用户请求就慢下来了，但是服务还是可用）还是返回降级内容。

### 4.服务端请求聚合

Nginx会在服务端把Nginx并发的请求并把结果聚合然后一次性吐出。

### 5.多级缓存模式

对于读服务会使用大量的缓存来提升性能，我们在设计时主要有如下缓存应用：首先读取Nginx本地缓存 Shared Dict或者Nginx Proxy Cache，如果有直接返回内容给用户；如果本地缓存不命中，则会读取分布式缓存如Redis，如果有直接返回；如果还是不命中则回源到Tomcat应用读取DB或调用服务获取数据。另外我们会按照维度进行数据的缓存。

### 6.降级

如果请求量太大扛不住了，那我们需要主动降级；如果后端挂了或者被限流了或者后端超时了，那我们需要被动降级。

### 7.AB测试/灰度发布

比如要上一个新的接口，可以通过在业务Nginx通过Lua写复杂的业务规则实现不同的人看到不同的版本。

### 8.服务质量监控

我们可以记录请求响应时间、缓存响应时间、反向代理服务响应时间来详细了解到底哪块服务慢了；另外记录非200状态码错误来了解服务的可用率。

## 怎么安装？

[openresty下载地址](https://openresty.org/en/download.html)

本例子只是说明在非windows平台的安全，windows平台直接下载相应的安装包就ok了。

### 安装依赖

```
# ubuntu
apt-get install libreadline-dev libncurses5-dev libpcre3-dev libssl-dev perl make build-essential curl
# centos
yum install readline-devel pcre-devel openssl-devel gcc curl
# mac
brew update
brew install pcre openssl curl
```

### 下载

```
wget https://openresty.org/download/ngx_openresty-1.9.7.2.tar.gz
tar zxvf ngx_openresty-1.9.7.2.tar.gz
```

### 安装LuaJIT

```
cd ngx_openresty-1.9.7.2/bundle/LuaJIT-2.1-20160108/
make clean && make && make install
ln -sf luajit-2.1.0-alpha /usr/local/bin/luajit
```

### 安装其它模块

位于ngx_openresty-1.9.7.2/bundle目录下。

> ngx_cache_purge:清理nginx缓存

```
wget http://labs.frickle.com/files/ngx_cache_purge-2.3.tar.gz
```

> nginx_upstream_check_module:ustream健康检查

```
wget http://nginx.org/download/nginx-1.0.14.tar.gz
```


### 安装ngx_openresty


```
cd /usr/local/bar/ngx_openresty-1.9.7.2
./configure –with-openssl=/usr/local/Cellar/openssl/1.0.2j --prefix=/usr/local/openresty --with-http_realip_module --without-http_redis2_module  --with-pcre  --with-luajit -j2
make && make install
```

> 查看帮助

```
--help to see more options
```

### 验证是否安装成功？

到/usr/local/bar目录下，会出现很多新的目录。

luajit：luajit环境；lua是一种解释语言，通过luajit可以即时编译lua代码到机器代码，得到很好的性能。
lualib：lua库。
nginx：安装的nginx。

我们可以通过/usr/local/bar/nginx/sbin/nginx -h来查看帮助信息。

## 怎么配置开发环境？

主要配置此文件（/usr/local/bar/nginx/conf/nginx.conf）。

> 添加lua库依赖

```
lua_package_path "/usr/local/bar/lualib/?.lua;;";
lua_package_cpath "/usr/local/bar/lualib/?.so;;";
```

> 测试配置是否正确

```
nginx/sbin/nginx -t
```

> 重启nginx

```
nginx/sbin/nginx -s reload
```

> 关闭nginx

```
nginx/sbin/nginx -s quit
```

## 常见lua插件

- Http客户端(OpenResty默认没有提供Http客户端，需要使用第三方提供):[lua-resty-http](https://github.com/pintsized/lua-resty-http)

- Mysql客户端(默认自带):[lua-resty-mysql](https://github.com/openresty/lua-resty-mysql)

- Redis客户端(默认自带):[lua-resty-redis](https://github.com/openresty/lua-resty-redis)

- 实时监控Nginx域名请求:[ngx_lua_reqstatus](https://github.com/zheng-ji/ngx_lua_reqstatus)

- cache(每Worker进程共享):[lua-resty-lrucache](https://github.com/openresty/lua-resty-lrucache)

- CJSON:[Lua CJSON](https://www.kyne.com.au/~mark/software/lua-cjson-manual.html)

- dkjson:[dkjson](http://dkolf.de/src/dkjson-lua.fsl/home)

- Lua UTF-8库:[luautf8](https://github.com/starwing/luautf8)

- 模板渲染:[lua-resty-template](https://github.com/bungle/lua-resty-template)

- waf:[ngx_lua_waf](https://github.com/loveshell/ngx_lua_waf)

- 静态文件合并:[nginx-lua-static-merger](https://github.com/grasses/nginx-lua-static-merger)

- 动态检测后端服务节点的状态:[lua-resty-upstream-healthcheck](https://github.com/openresty/lua-resty-upstream-healthcheck)
