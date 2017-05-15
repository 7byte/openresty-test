local MYSQL = require("resty.mysql")

local mysql_server_ip                       =   "127.0.0.1"
local mysql_server_port                     =   3306
local mysql_databases                       =   "mysql"
local mysql_user_name                       =   "7byte"
local mysql_user_pass                       =   "oi&ARXhrN65S%hYd"
local mysql_max_packet_size                 =   1024 * 1024

local conn = {}

function conn.getMysql()
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

function conn.releaseConn(mysqlConn)
    --local ok = true
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
            err = "MySQL.Error ( "..(err or "null").." ) "
        end
    end 
    return ok, db_type, err
end

return conn
