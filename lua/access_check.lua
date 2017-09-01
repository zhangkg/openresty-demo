--
-- User: Mr. yrzx404
-- Date: 2016/11/24 13:42
-- Description: 检查拦截
--

ngx.log(ngx.ERR, "参数检查...")
local iputils = require("resty.iputils")
iputils.enable_lrucache()

local whitelist_ips = {
    "127.0.0.1",
    "192.168.0.0/16",
}

whitelist = iputils.parse_cidrs(whitelist_ips)

if not iputils.ip_in_cidrs(ngx.var.remote_addr, whitelist) then
    return ngx.exit(ngx.HTTP_FORBIDDEN)
else
    ngx.log(ngx.ERR, "ip是白名单 ")
end