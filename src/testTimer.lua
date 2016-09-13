local delay = 5
local handler
handler = function (premature)
    -- do some routine job in Lua just like a cron job
    if premature then
        return
    end
    ngx.log(ngx.ERR, "in function")
    local ok, err = ngx.timer.at(delay, handler)
    if not ok then
        ngx.log(ngx.ERR, "failed to create the timer: ", err)
        return
    end
end

ngx.log(ngx.ERR, "id = "..ngx.worker.id()..", count = "..ngx.worker.count())
if ngx.worker.id() ~= 0 then
    return
end
local ok, err = ngx.timer.at(delay, handler)
if not ok then
    ngx.log(ngx.ERR, "failed to create the timer: ", err)
    return
end