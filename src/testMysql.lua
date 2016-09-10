local MYSQL = require("resty.mysql")
local JSON  = require("cjson")

local mysql_server_ip                       =   "127.0.0.1"
local mysql_server_port                     =   3306
local mysql_databases                       =   "mysql"
local mysql_user_name                       =   "7byte"
local mysql_user_pass                       =   "oi&ARXhrN65S%hYd"
local mysql_max_packet_size                 =   1024 * 1024

function getMysql()
    local mysql = MYSQL:new()
    mysql:set_timeout(1000)
    local ok, err, errno, sqlstate = mysql:connect{
        host = mysql_server_ip,
        port = mysql_server_port,
        database = mysql_databases,
        user = mysql_user_name,
        password = mysql_user_pass,
        max_packet_size = mysql_max_packet_size,
        charset=utf8 }
    if not ok then
        return nil, err, errno, sqlstate
    end
    return mysql,nil,nil,sqlstate
end

function releaseConn(mysqlConn)
    local ok = true
    local db_type = 0
    local err = ""
    if mysqlConn then
        local res, err, errno, sqlstate = mysqlConn:read_result()
        while err == "again" do
            res, err, errno, sqlstate = mysqlConn:read_result()
        end
        local ok, err = mysqlConn:set_keepalive(0, 1000)
        if not ok then
            mysqlConn:close()
            ok = false
            db_type = db_type + mysql_type
            err = "MySQL.Error ( "..(err or "null").." ) "
        end
    end 
    return ok, db_type, err
end

function response_success_jsonp(info, callback)
    local nsp               = {}
    nsp["status"]           = 0
    nsp["data"]             = info
    local rsp               = JSON.encode(nsp)
    if not callback or callback == ngx.null then
        ngx.header.content_type = "application/json;charset=utf8"
        ngx.say(rsp)
    else
        ngx.header.content_type = "application/javascript;charset=utf8"
        ngx.say(callback,"(", rsp,");")
    end
    ngx.exit(ngx.HTTP_OK)
    return
end

local mysql, err = getMysql()
if not mysql then
    ngx.say(err)
else
    local sql = "SELECT help_topic_id, name, help_category_id, example, url FROM help_topic"
    local res1, err, errno, sqlstate = mysql:query(sql)
    ngx.log(ngx.ERR, "get_reused_times: "..mysql:get_reused_times())
    if not res1 then
        ngx.say(JSON.encode({"query failed!"}))
    else
        ngx.say(JSON.encode(res1))
    end
    releaseConn(mysql)
    ngx.exit(ngx.HTTP_OK)
    return
end