local _M = {}

-- alternatively: local lrucache = require "resty.lrucache.pureffi"
local lrucache = require "resty.lrucache"

-- we need to initialize the cache on the Lua module level so that
-- it can be shared by all the requests served by each nginx worker process:
local c = lrucache.new(200)  -- allow up to 200 items in the cache
if not c then
	ngx.log(ngx.ERR, "failed to create the cache: " .. (err or "unknown"))
    return error("failed to create the cache: " .. (err or "unknown"))
end

function _M.go()
    c:set("dog", 32)
    c:set("cat", 56)
    ngx.say("dog: ", c:get("dog"))
    ngx.say("cat: ", c:get("cat"))

    c:set("dog", { age = 10 }, 0.1)  -- expire in 0.1 sec
    c:delete("dog")
end


function _M.getFromCache( key )
    if not key then
        return nil
    end
    return c:get(key)
end

function _M.setToCache( key, value, exptime )
    if not key or not value or not exptime then
        return nil
    end
    return c:set(key, value, exptime)
end

return _M