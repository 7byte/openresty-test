local delay = 5
local handler
local testMysqlHandler

testMysqlHandler = function (premature)
    if premature then
        return
    end

    local testMysql = require("testMysql")
    local info, err = testMysql.getHelpTopic()
    if not info then
        ngx.log(ngx.ERR, "getHelpTopic err: "..err)
    else
        ngx.log(ngx.INFO, info)
    end
end

handler = function (premature)
    -- do some routine job in Lua just like a cron job
    if premature then
        return
    end
    local ok, err = ngx.timer.at(delay, testMysqlHandler)
    if not ok then
        ngx.log(ngx.ERR, "failed to create the timer: ", err)
        return
    end
end

ngx.log(ngx.INFO, "id = "..ngx.worker.id()..", count = "..ngx.worker.count())
if ngx.worker.id() ~= 0 then
    return
end
local ok, err = ngx.timer.at(delay, handler)
if not ok then
    ngx.log(ngx.ERR, "failed to create the timer: ", err)
    return
end