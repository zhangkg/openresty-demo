--
-- User: Mr. yrzx404
-- Date: 2016/11/23 14:22
-- Description: ${TODO}
--

--加载Lua模块库
local template = require("resty.template")
--local productData = require("product.product_data");

-- 是否缓存解析后的模板，默认true
template.caching(true)
-- 渲染模板需要的上下文(数据)
local context = {content = " 渲染模板需要的上下文" }
-- 渲染模板
template.render("product.html", context)

ngx.say("<br/>")

--1、获取请求参数中的商品ID
local skuId = ngx.var.skuId;
--2、调用相应的服务获取数据
--local data = productData.getData(skuId)
local data = nil

if data == nil then
    data = {content = "调用相应的服务获取数据" }
end

ngx.log(ngx.ERR,data.content)

--3、渲染模板
local func = template.compile("product.html")
local content = func(data)
--4、通过ngx API输出内容
ngx.say(content)

