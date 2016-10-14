function get_from_cache(key)
    local cache_ngx = ngx.shared.my_cache
    local value = cache_ngx:get(key)
    return value
end

function set_to_cache(key, value, exptime)
    if not exptime then
        exptime = 0
    end

    local cache_ngx = ngx.shared.my_cache
    local succ, err, forcible = cache_ngx:set(key, value, exptime)
    return succ
end

local res = get_from_cache("abc")
if res then
	ngx.say(res)
	ngx.exit(ngx.HTTP_OK)
end

res = "zhangzhiqi"
set_to_cache("abc", res, 60)
ngx.say(res)
ngx.exit(ngx.HTTP_OK)