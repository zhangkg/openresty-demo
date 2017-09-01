local redis = require "resty.redis"
local cjson = require "cjson"
local function close_redis(red)
    if not red then
        return nil
    end
    local ok, err = red:close()
    if not ok then
        ngx.log(ngx.ERR, "close redis error : ", err)
    end
    return nil
end


function getData(skuId)
    local ok = true
    local resp = nil

    --连接redis
    local red = redis:new()
    red:set_timeout(1000) -- 1 sec
    local ok, err = red:connect("127.0.0.1", 6379)
    if not ok then
        ngx.log(ngx.ERR, "connect to redis error : ", err)
        return close_redis(red)
    end

    -- auth 的调用过程
    local count
    count,err = red:get_reused_times()
    if count == 0 then
        ok,err = red:auth("123456")
        if not ok then
            ngx.log(ngx.ERR,"failed to authenticate: ", err)
            return close_redis(red)
        end
    elseif err then
        ngx.log(ngx.ERR,"failed to get reused times: ",err)
        return close_redis(red)
    end

    -- 调用API设置数据
    ok,err = red.set("dog","an animal")
    if not ok then
        ngx.log(ngx.ERR,"set info error:",err)
        return close_redis(red)
    end

    -- 连接池大小是100个，并且设置最大的空闲时间是 10 秒
    local ok, err = red:set_keepalive(10000, 100)
    if not ok then
        ngx.say("failed to set keepalive: ", err)
        return close_redis(red)
    end

    --调用API获取数据   
    resp, err = red:get(skuId)
    if not ok then
        ngx.log(ngx.ERR, "get sku info error : ", err)
        return close_redis(red)
    end

    --得到的数据为空处理  
    if resp == ngx.null then
        resp = nil --比如默认值
    end

    --释放redis连接 
    close_redis(red)

    if resp then
        resp = cjson.decode(resp)
    end

    return resp
end


local _M = {
    getData = getData
}

return _M


