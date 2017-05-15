local JSON  = require("cjson")
local Mysql = require("connection")

local testMysql = {}

function testMysql.getHelpTopic()
    local mysql, err = Mysql.getMysql()
    if not mysql then
        return nil, err
    else
        local info = ""
        local sql = "SELECT * FROM help_topic limit 1"
        local res1, err, errno, sqlstate = mysql:query(sql)
        ngx.log(ngx.INFO, "get_reused_times: "..mysql:get_reused_times())
        if not res1 then
            ngx.log(ngx.ERR, "mysql error: ", err)
        else
            info = JSON.encode(res1)
        end
        Mysql.releaseConn(mysql)
        return info, nil
    end
end

-- local info, err = testMysql.getHelpTopic()
-- if info then
--     ngx.say(info)
-- else
--     ngx.say(err)
-- end
-- ngx.exit(ngx.HTTP_OK)

return testMysql
