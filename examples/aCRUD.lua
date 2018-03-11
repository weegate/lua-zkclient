-- notice: 异步操作要清楚知道异步回调逻辑处理流程 by wuyong
require "zklua"
-- need cjson.so
local cjson = require "cjson"


--zh:就是我们创建连接之后的返回值,我试了下,发现好像指的是连接的一个索引值,以0开始
--type:事件类型,-1表示没有事件发生,1表示创建节点,2表示节点删除,3表示节点数据被改变,4表示子节点发生变化
--state:客户端的状态,0:断开连接状态,3:正常连接的状态,4认证失败,-112:过期啦
--path:这个状态就不用解释了,znode的路径
function zklua_init_watcher(zh, type, state, path, watcherctx)
    if type == zklua.ZOO_SESSION_EVENT then
        if state == zklua.ZOO_CONNECTED_STATE then
            print("Connected to zookeeper service successfully!\n");
        elseif (state == ZOO_EXPIRED_SESSION_STATE) then
            print("Zookeeper session expired!\n");
        end
    end
end


function zklua_exists_stat_completion(rc, stat, data)
    print("zklua_exists_stat_completion:")
    print("rc: "..rc.."\tstat: "..cjson.encode(stat).."\tdata: "..cjson.encode(data))
    if(0 ~= rc) then
        local acl = {}
        acl['scheme'] = "world"
        acl['id'] = "anyone"
        acl['perms'] = 0x1f --READ | WRITE | CREATE | DELETE | ADMIN (31)
        ret = zklua.acreate(zoo_handle, "/zklua", "create", {acl}, 0, zklua_create_stat_completion,"zklua acreate.")
        print("zklua.acreate ret: "..ret)
    end

end

function zklua_create_stat_completion(rc, stat, data)
    print("zklua_create_stat_completion:")
    print("rc: "..rc.."\tstat: "..type(stat).."\tdata: "..cjson.encode(data))
    version = data.version
end

function zklua_get_stat_completion(rc, stat, data)
    print("zklua_get_stat_completion:")
    print("rc: "..rc.."\tstat: "..stat.."\tdata: "..cjson.encode(data))
    version = data.version
    --set 不匹配上version时，返回fail, version为-1不比较版本直接upgrade
    ret = zklua.aset(zoo_handle, "/zklua", "set agian", version, zklua_set_stat_completion, "zklua aset.")
    print("zklua.aset ret: "..ret)
end

function zklua_set_stat_completion(rc, stat, data)
    print("zklua_set_stat_completion:")
    print("rc: "..rc.."\tstat: "..cjson.encode(stat).."\tdata: "..cjson.encode(data))
    
    if(0==rc and "table"==type(stat)) then
        version = stat.version
        print("version:"..version)
        --del 不匹配上version时，返回fail, version为-1不比较版本直接delete
        ret = zklua.adelete(zoo_handle, "/zklua", version, zklua_del_stat_completion, "zklua adelete.")
        --ret = zklua.adelete(zoo_handle, "/zklua", -1, zklua_del_stat_completion, "zklua adelete.")
        print("zklua.adelete: "..ret)
    end
end

function zklua_del_stat_completion(rc, stat, data)
    print("zklua_del_stat_completion:")
    print("rc: "..rc.."\tstat: "..stat.."\tdata: "..cjson.encode(data))
end

zklua.set_log_stream("zklua.log")

zoo_handle = zklua.init("127.0.0.1:2181,127.0.0.1:2182,127.0.0.1:2183", zklua_init_watcher, 10000)

local ret = nil
local watch = 1 --非0时,当watched server有变化通知client
local version = 0 --节点版本

ret = zklua.aexists(zoo_handle, "/zklua", watch, zklua_exists_stat_completion, "zklua aexists.")
print("zklua.aexists ret: "..ret)

ret = zklua.aget(zoo_handle, "/zklua", watch, zklua_get_stat_completion, "zklua aget.")
print("zklua.aget ret: "..ret)



print("hit any key to continue...")
io.read()

