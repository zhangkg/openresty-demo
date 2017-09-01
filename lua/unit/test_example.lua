--
-- User: Mr. yrzx404
-- Date: 2016/11/25 13:50
-- Description: 单元测试demo
--
local tb = require "resty.iresty_test"
local test = tb.new({ unit_name = "bench_example" })

function tb:init()
    self:log("init complete")
end

function tb:test_00001()
    error("invalid input")
end

function tb:atest_00002()
    self:log("never be called")
end

function tb:test_00003()
    self:log("ok")
end

-- units test
test:run()

-- bench test(total_count, micro_count, parallels)
test:bench_run(100000, 25, 20)