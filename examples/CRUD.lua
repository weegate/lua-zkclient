--同步执行 by wuyong :  madness c library
require "zklua"
-- need cjson.so
local cjson = require "cjson"

function zklua_init_watcher(zh, type, state, path, watcherctx)
    if type == zklua.ZOO_SESSION_EVENT then
        if state == zklua.ZOO_CONNECTED_STATE then
            print("Connected to zookeeper service successfully!\n");
        elseif (state == ZOO_EXPIRED_SESSION_STATE) then
            print("Zookeeper session expired!\n");
        end
    end
end

zklua.set_log_stream("lua-zkclient.log")
zoo_handle = zklua.init("127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183", zklua_init_watcher, 10000)

local acl = {}
local ret = nil
local version = 0

ret,stat=zklua.exists(zoo_handle,"/zklua",1)
print("exists ret:\t"..ret.."\tstat:\t"..cjson.encode(stat))

if(0~=ret) then
    acl['scheme'] = "world"
    acl['id'] = "anyone"
    acl['perms'] = 0x1f --READ | WRITE | CREATE | DELETE | ADMIN (31)
    ret,data = zklua.create(zoo_handle,"/zklua","create",{acl},0)
    --print("create ret:\t"..ret.."\tdata:\t"..cjson.encode(data))
end

ret,_,stat = zklua.get(zoo_handle,"/zklua",1)
--print("get ret:\t"..ret.."\tdata:\t"..cjson.encode(data).."\tstat:\t"..cjson.encode(stat))
version = stat.version

if(0==ret) then
    local val = {}
    val['method'] = "set"
    val['key'] = "2312"
    val['value'] = "set again"
    ret = zklua.set(zoo_handle,"/zklua",cjson.encode(val),version)
    --print("set ret:\t"..cjson.encode(ret))
end

if(0==ret) then
    ret,data,stat = zklua.get(zoo_handle,"/zklua",1)
    print("get ret:\t"..ret.."\tdata:\t"..cjson.encode(data).."\tstat:\t"..cjson.encode(stat))
    version = stat.version
    if(0==ret) then
        ret = zklua.delete(zoo_handle,"/zklua",version)
        --print("delete ret:\t"..cjson.encode(ret))
    end
end

